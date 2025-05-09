###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.15.0-alpine3.20@sha256:686b8892b69879ef5bfd6047589666933508f9a5451c67320df3070ba0e9807b As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.15.0-alpine3.20@sha256:686b8892b69879ef5bfd6047589666933508f9a5451c67320df3070ba0e9807b As build

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

FROM node:22.15.0-alpine3.20@sha256:686b8892b69879ef5bfd6047589666933508f9a5451c67320df3070ba0e9807b As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
