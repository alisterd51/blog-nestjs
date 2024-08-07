###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.6.0-alpine3.20@sha256:bde9463199e46232b188b70c2d34bb7e9da0fa6d0a649609004674636a2ee98a As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.6.0-alpine3.20@sha256:bde9463199e46232b188b70c2d34bb7e9da0fa6d0a649609004674636a2ee98a As build

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

FROM node:22.6.0-alpine3.20@sha256:bde9463199e46232b188b70c2d34bb7e9da0fa6d0a649609004674636a2ee98a As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
