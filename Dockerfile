FROM node:argon-slim

# Add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r app && useradd -r -g app app

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install --production

COPY . /usr/src/app
RUN npm run build

USER app
RUN chown -R app:app /usr/src/app

CMD [ "node", "lib/server.js" ]
