###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.2.0-alpine3.20@sha256:7d8c63b806921fb240b3eacb74a8b13fb76e797f9b3983f068e62ce5f9a90f1d As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.2.0-alpine3.20@sha256:7d8c63b806921fb240b3eacb74a8b13fb76e797f9b3983f068e62ce5f9a90f1d As build

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

FROM node:22.2.0-alpine3.20@sha256:7d8c63b806921fb240b3eacb74a8b13fb76e797f9b3983f068e62ce5f9a90f1d As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
