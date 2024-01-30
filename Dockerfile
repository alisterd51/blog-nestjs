###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.6.1-alpine@sha256:d543f4c83b3212118f487c881570efe4e045b43a0b1dc7172e8b5101d44842b7 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.6.1-alpine@sha256:d543f4c83b3212118f487c881570efe4e045b43a0b1dc7172e8b5101d44842b7 As build

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

FROM node:21.6.1-alpine@sha256:d543f4c83b3212118f487c881570efe4e045b43a0b1dc7172e8b5101d44842b7 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
