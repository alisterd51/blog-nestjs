###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.6.0-alpine@sha256:cd5cb604273b8727a7dd7e3ff626647106ef7f930002a819f602cee6a7938b83 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.6.0-alpine@sha256:cd5cb604273b8727a7dd7e3ff626647106ef7f930002a819f602cee6a7938b83 As build

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

FROM node:21.6.0-alpine@sha256:cd5cb604273b8727a7dd7e3ff626647106ef7f930002a819f602cee6a7938b83 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
