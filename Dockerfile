###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.7.1-alpine@sha256:92701a26dafc0e33c87fc245537b39af27da2be9736c84ed4f6f100c7d7194b0 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.7.1-alpine@sha256:92701a26dafc0e33c87fc245537b39af27da2be9736c84ed4f6f100c7d7194b0 As build

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

FROM node:21.7.1-alpine@sha256:92701a26dafc0e33c87fc245537b39af27da2be9736c84ed4f6f100c7d7194b0 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
