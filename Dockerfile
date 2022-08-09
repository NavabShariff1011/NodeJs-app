FROM node:14

WORKDIR /usr/src/app

RUN npm install nodejsexample@1.0.0

EXPOSE 3000

CMD ["node", "app.js"]

