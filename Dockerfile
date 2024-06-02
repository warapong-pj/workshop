FROM node:20-bullseye AS build
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN npm ci && npm run build

FROM node:20-alpine AS pack
WORKDIR /home/node
COPY --chown=node:node --from=build /usr/src/app/node_modules /home/node/node_modules
COPY --chown=node:node --from=build /usr/src/app/dist  /home/node/dist
USER node
CMD [ "node", "dist/main.js" ]
