###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:21.6.0-alpine@sha256:506f24c082496c8ddddbd2d09d77c440cceb816493fea0501bb7797f278dae80 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:21.6.0-alpine@sha256:506f24c082496c8ddddbd2d09d77c440cceb816493fea0501bb7797f278dae80 As build

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

FROM node:21.6.0-alpine@sha256:506f24c082496c8ddddbd2d09d77c440cceb816493fea0501bb7797f278dae80 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
