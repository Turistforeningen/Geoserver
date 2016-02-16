FROM node:argon-slim

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install --production

COPY . /usr/src/app
RUN npm run build

CMD [ "node", "lib/server.js" ]
