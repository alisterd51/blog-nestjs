###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.2.0-alpine@sha256:b661eb974e89da4c8073ec8a288de5b24eddc16604a7e09f245cf4775b96330c As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.2.0-alpine@sha256:b661eb974e89da4c8073ec8a288de5b24eddc16604a7e09f245cf4775b96330c As build

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

FROM node:21.2.0-alpine@sha256:b661eb974e89da4c8073ec8a288de5b24eddc16604a7e09f245cf4775b96330c As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
