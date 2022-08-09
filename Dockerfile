FROM node:14

WORKDIR /usr/src/app

ADD nodejs.tgz .

EXPOSE 3000

CMD ["node", "src/app.js"]

