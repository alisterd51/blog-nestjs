###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.10.0-alpine3.20@sha256:c02c668be1cd096d0e7fdd65512570157aec90f98aed917989a0bc9c3609267a As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.10.0-alpine3.20@sha256:c02c668be1cd096d0e7fdd65512570157aec90f98aed917989a0bc9c3609267a As build

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

FROM node:22.10.0-alpine3.20@sha256:c02c668be1cd096d0e7fdd65512570157aec90f98aed917989a0bc9c3609267a As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
