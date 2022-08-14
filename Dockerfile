FROM node:14-alpine as BUILD

WORKDIR /app

COPY package.json .
RUN npm install

FROM node:14-alpine
WORKDIR /app
COPY src/app.js .
COPY --from=BUILD /app/node_modules/ /app/node_modules/
ENTRYPOINT ["node", "app.js"]

