###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.3.0-alpine3.20@sha256:546ca3e666432a162c1065a58ae7a2e50a18b15e2759a6dfe52bbeaeec0f555c As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.3.0-alpine3.20@sha256:546ca3e666432a162c1065a58ae7a2e50a18b15e2759a6dfe52bbeaeec0f555c As build

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .

RUN npm run build

ENV NODE_ENV production

RUN npm ci --omit=dev && npm cache clean --force

USER node

###################
# PRODUCTION
###################

FROM node:22.3.0-alpine3.20@sha256:546ca3e666432a162c1065a58ae7a2e50a18b15e2759a6dfe52bbeaeec0f555c As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
