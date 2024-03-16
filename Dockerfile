###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.7.1-alpine@sha256:0befea5a1c79ec5d4f04c86bea59a78f6ad6c7861fce388d6c1d9bf543705ca2 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.7.1-alpine@sha256:0befea5a1c79ec5d4f04c86bea59a78f6ad6c7861fce388d6c1d9bf543705ca2 As build

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

FROM node:21.7.1-alpine@sha256:0befea5a1c79ec5d4f04c86bea59a78f6ad6c7861fce388d6c1d9bf543705ca2 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
