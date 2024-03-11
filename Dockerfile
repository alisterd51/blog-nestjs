###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.7.1-alpine@sha256:4999fa1391e09259e71845d3d0e9ddfe5f51ab30253c8b490c633f710c7446a0 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.7.1-alpine@sha256:4999fa1391e09259e71845d3d0e9ddfe5f51ab30253c8b490c633f710c7446a0 As build

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

FROM node:21.7.1-alpine@sha256:4999fa1391e09259e71845d3d0e9ddfe5f51ab30253c8b490c633f710c7446a0 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
