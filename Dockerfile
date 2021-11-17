FROM node:16.9-bullseye

#### initialize the orbit-db
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

RUN mkdir /home/node/orbitdb

WORKDIR /home/node/orbitdb

COPY ./orbit-db/package.json ./
COPY ./orbit-db/examples/ ./examples
COPY ./orbit-db/src/ ./src
COPY ./orbit-db/conf/ ./conf

# set permissions
RUN chown -R node:node /home/node/orbitdb
RUN chown -R node:node package.json examples src conf
USER node

# install orbit-db dependencies
RUN npm install babel-cli webpack \
 && npm install

#### orbit-db http api
USER root
RUN mkdir /api

# create cert-directory
RUN mkdir /certs
WORKDIR /api

# copy contents of the orbit-db-http-api server into /api
COPY . .

# install dependencies 
RUN npm ci  --no-color --only=prod

# entrypoint
CMD ["node", "src/cli.js", "api", "--ipfs-host", "ipfshost", "--orbitdb-dir", "/home/node/orbitdb", "--https-cert", "/certs/server.cert", "--https-key", "/certs/server.key"]
