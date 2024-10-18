###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.10.0-alpine3.20@sha256:cbc651c639bb55165ead780ae1028c0fb31cd04831d58a65c4e125a949606378 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.10.0-alpine3.20@sha256:cbc651c639bb55165ead780ae1028c0fb31cd04831d58a65c4e125a949606378 As build

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

FROM node:22.10.0-alpine3.20@sha256:cbc651c639bb55165ead780ae1028c0fb31cd04831d58a65c4e125a949606378 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
