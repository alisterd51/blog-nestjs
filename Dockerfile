###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.4.0-alpine@sha256:34556ba78497768394c896cca78c490f620e624ddacd4ebe47380c52e3e5cf79 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.4.0-alpine@sha256:34556ba78497768394c896cca78c490f620e624ddacd4ebe47380c52e3e5cf79 As build

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

FROM node:21.4.0-alpine@sha256:34556ba78497768394c896cca78c490f620e624ddacd4ebe47380c52e3e5cf79 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
