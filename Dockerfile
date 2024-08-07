###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.6.0-alpine3.20@sha256:6523b4b97a41a3779ad9ad877668392f8f73250fdf27ea749faebea5581a5d65 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.6.0-alpine3.20@sha256:6523b4b97a41a3779ad9ad877668392f8f73250fdf27ea749faebea5581a5d65 As build

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

FROM node:22.6.0-alpine3.20@sha256:6523b4b97a41a3779ad9ad877668392f8f73250fdf27ea749faebea5581a5d65 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
