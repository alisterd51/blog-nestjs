###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.7.2-alpine@sha256:5002af639bd84c62d4162751b25a48ada9b23440403bdf1c0a19a3f8cfef70b8 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.7.2-alpine@sha256:5002af639bd84c62d4162751b25a48ada9b23440403bdf1c0a19a3f8cfef70b8 As build

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

FROM node:21.7.2-alpine@sha256:5002af639bd84c62d4162751b25a48ada9b23440403bdf1c0a19a3f8cfef70b8 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
