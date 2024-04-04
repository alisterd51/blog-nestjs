###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.7.2-alpine@sha256:530e67fa4197af700b9f5da6715352b698aae183b086532e4d800ea5f61496c9 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.7.2-alpine@sha256:530e67fa4197af700b9f5da6715352b698aae183b086532e4d800ea5f61496c9 As build

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

FROM node:21.7.2-alpine@sha256:530e67fa4197af700b9f5da6715352b698aae183b086532e4d800ea5f61496c9 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
