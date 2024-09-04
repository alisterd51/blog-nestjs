###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.8.0-alpine3.20@sha256:1c782a2915a27952e937ff78081ece2ef1d7c5bf12cc85f47eae5511f7014915 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.8.0-alpine3.20@sha256:1c782a2915a27952e937ff78081ece2ef1d7c5bf12cc85f47eae5511f7014915 As build

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

FROM node:22.8.0-alpine3.20@sha256:1c782a2915a27952e937ff78081ece2ef1d7c5bf12cc85f47eae5511f7014915 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
