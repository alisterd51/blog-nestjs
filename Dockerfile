###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.1.0-alpine3.19@sha256:487dc5d5122d578e13f2231aa4ac0f63068becd921099c4c677c850df93bede8 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.1.0-alpine3.19@sha256:487dc5d5122d578e13f2231aa4ac0f63068becd921099c4c677c850df93bede8 As build

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

FROM node:22.1.0-alpine3.19@sha256:487dc5d5122d578e13f2231aa4ac0f63068becd921099c4c677c850df93bede8 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
