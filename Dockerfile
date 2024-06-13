###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.3.0-alpine3.20@sha256:21d994f448b6416a8859653d6ae4957b22003df66d381151725065ae0e25ee78 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.3.0-alpine3.20@sha256:21d994f448b6416a8859653d6ae4957b22003df66d381151725065ae0e25ee78 As build

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

FROM node:22.3.0-alpine3.20@sha256:21d994f448b6416a8859653d6ae4957b22003df66d381151725065ae0e25ee78 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
