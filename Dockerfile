###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.3.0-alpine3.20@sha256:df46071ae175bc2c0468ae58e32f00ed6c9779eb70112cdf0d2ccf85035bc7ff As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.3.0-alpine3.20@sha256:df46071ae175bc2c0468ae58e32f00ed6c9779eb70112cdf0d2ccf85035bc7ff As build

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

FROM node:22.3.0-alpine3.20@sha256:df46071ae175bc2c0468ae58e32f00ed6c9779eb70112cdf0d2ccf85035bc7ff As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
