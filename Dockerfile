###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.5.1-alpine3.20@sha256:a5b9a7e61337e37c8b6985a661d214f519d92d13c4f01becbe8d2947935fa0da As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.5.1-alpine3.20@sha256:a5b9a7e61337e37c8b6985a661d214f519d92d13c4f01becbe8d2947935fa0da As build

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

FROM node:22.5.1-alpine3.20@sha256:a5b9a7e61337e37c8b6985a661d214f519d92d13c4f01becbe8d2947935fa0da As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
