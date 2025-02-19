###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.14.0-alpine3.20@sha256:40be979442621049f40b1d51a26b55e281246b5de4e5f51a18da7beb6e17e3f9 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.14.0-alpine3.20@sha256:40be979442621049f40b1d51a26b55e281246b5de4e5f51a18da7beb6e17e3f9 As build

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

FROM node:22.14.0-alpine3.20@sha256:40be979442621049f40b1d51a26b55e281246b5de4e5f51a18da7beb6e17e3f9 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
