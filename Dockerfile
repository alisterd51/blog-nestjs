###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.6.0-alpine@sha256:9146b6edca184979d280214a0fea02eb5435e0d2be06a3928aa9127753c0dbe2 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.6.0-alpine@sha256:9146b6edca184979d280214a0fea02eb5435e0d2be06a3928aa9127753c0dbe2 As build

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

FROM node:21.6.0-alpine@sha256:9146b6edca184979d280214a0fea02eb5435e0d2be06a3928aa9127753c0dbe2 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
