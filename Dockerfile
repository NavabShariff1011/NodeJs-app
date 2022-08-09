FROM node:14

WORKDIR /usr/src/app

ADD /nodejs-cicd/nodejsexample/-/nodejsexample-1.0.0.tgz .

EXPOSE 3000

CMD ["node", "app.js"]

