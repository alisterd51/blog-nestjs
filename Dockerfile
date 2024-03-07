###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.7.0-alpine@sha256:e0bb2d5b83959e3f8f07a5223f01791d87f0be0efb0161aee4bce4c9979097dd As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.7.0-alpine@sha256:e0bb2d5b83959e3f8f07a5223f01791d87f0be0efb0161aee4bce4c9979097dd As build

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

FROM node:21.7.0-alpine@sha256:e0bb2d5b83959e3f8f07a5223f01791d87f0be0efb0161aee4bce4c9979097dd As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
