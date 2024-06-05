###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.2.0-alpine3.20@sha256:8dec302f1453d78d629291dda2a0782506c4d62691de1d13e43e287fffe4387e As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.2.0-alpine3.20@sha256:8dec302f1453d78d629291dda2a0782506c4d62691de1d13e43e287fffe4387e As build

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

FROM node:22.2.0-alpine3.20@sha256:8dec302f1453d78d629291dda2a0782506c4d62691de1d13e43e287fffe4387e As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
