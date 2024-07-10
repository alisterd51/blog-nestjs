###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.4.1-alpine3.20@sha256:ba898e86c2cc720c8cf2ae05f8d2d4697fe0c8ca3e920d6fbf14a6cbf50bb9ca As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.4.1-alpine3.20@sha256:ba898e86c2cc720c8cf2ae05f8d2d4697fe0c8ca3e920d6fbf14a6cbf50bb9ca As build

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

FROM node:22.4.1-alpine3.20@sha256:ba898e86c2cc720c8cf2ae05f8d2d4697fe0c8ca3e920d6fbf14a6cbf50bb9ca As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
