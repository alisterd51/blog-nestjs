###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.7.1-alpine@sha256:3b078a1a63e529025efdbd7cec036db21462ff9a92d39147a84e259c8f7c33fb As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.7.1-alpine@sha256:3b078a1a63e529025efdbd7cec036db21462ff9a92d39147a84e259c8f7c33fb As build

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

FROM node:21.7.1-alpine@sha256:3b078a1a63e529025efdbd7cec036db21462ff9a92d39147a84e259c8f7c33fb As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
