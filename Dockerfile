###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.4.0-alpine@sha256:9bfaec4816d320226b1533abd5d22d6a888105ee502b820676736de99a198408 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.4.0-alpine@sha256:9bfaec4816d320226b1533abd5d22d6a888105ee502b820676736de99a198408 As build

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

FROM node:21.4.0-alpine@sha256:9bfaec4816d320226b1533abd5d22d6a888105ee502b820676736de99a198408 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
