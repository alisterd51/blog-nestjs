###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.2.0-alpine3.20@sha256:dac1e6f32c179a4b0aa6cc45b5d96ce4bcf592f987932313c804797b24b85ebc As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.2.0-alpine3.20@sha256:dac1e6f32c179a4b0aa6cc45b5d96ce4bcf592f987932313c804797b24b85ebc As build

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

FROM node:22.2.0-alpine3.20@sha256:dac1e6f32c179a4b0aa6cc45b5d96ce4bcf592f987932313c804797b24b85ebc As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
