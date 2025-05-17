###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.15.1-alpine3.20@sha256:224173ad6a700ec322c7117f616836d0dc6cadd8d6baac57703ccc2eb418a73f As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.15.1-alpine3.20@sha256:224173ad6a700ec322c7117f616836d0dc6cadd8d6baac57703ccc2eb418a73f As build

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

FROM node:22.15.1-alpine3.20@sha256:224173ad6a700ec322c7117f616836d0dc6cadd8d6baac57703ccc2eb418a73f As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
