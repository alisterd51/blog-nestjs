###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.9.0-alpine3.20@sha256:298e7594bec0213ac122ca36f30081a17fa80c571413e5f5a46d61d9c27c41e4 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.9.0-alpine3.20@sha256:298e7594bec0213ac122ca36f30081a17fa80c571413e5f5a46d61d9c27c41e4 As build

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

FROM node:22.9.0-alpine3.20@sha256:298e7594bec0213ac122ca36f30081a17fa80c571413e5f5a46d61d9c27c41e4 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
