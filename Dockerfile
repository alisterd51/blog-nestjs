###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.14.0-alpine3.20@sha256:09a7e3779ab7bf5ee2e1909feef786ee5d2845a7690c4514c9170af4a5c19b9f As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.14.0-alpine3.20@sha256:09a7e3779ab7bf5ee2e1909feef786ee5d2845a7690c4514c9170af4a5c19b9f As build

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

FROM node:22.14.0-alpine3.20@sha256:09a7e3779ab7bf5ee2e1909feef786ee5d2845a7690c4514c9170af4a5c19b9f As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
