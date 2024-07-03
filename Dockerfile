###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:22.4.0-alpine3.20@sha256:6fa9da622cb8350243700b15ed9b2b848f6631d00284761c1c9671239b268864 As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:22.4.0-alpine3.20@sha256:6fa9da622cb8350243700b15ed9b2b848f6631d00284761c1c9671239b268864 As build

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

FROM node:22.4.0-alpine3.20@sha256:6fa9da622cb8350243700b15ed9b2b848f6631d00284761c1c9671239b268864 As production

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
