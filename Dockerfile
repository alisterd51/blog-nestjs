###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.6.1-alpine@sha256:4cc2d9f365691fc6f8fe227321d32d9a2691216a71f51c21c7f02224515dea48 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.6.1-alpine@sha256:4cc2d9f365691fc6f8fe227321d32d9a2691216a71f51c21c7f02224515dea48 As build

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

FROM node:21.6.1-alpine@sha256:4cc2d9f365691fc6f8fe227321d32d9a2691216a71f51c21c7f02224515dea48 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
