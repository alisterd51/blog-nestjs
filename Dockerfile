###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.8.0-alpine3.20@sha256:f91ead25f3a98d9c873e5447a23407d7b28e98a0d1e82008415618261470f12a As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.8.0-alpine3.20@sha256:f91ead25f3a98d9c873e5447a23407d7b28e98a0d1e82008415618261470f12a As build

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

FROM node:22.8.0-alpine3.20@sha256:f91ead25f3a98d9c873e5447a23407d7b28e98a0d1e82008415618261470f12a As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
