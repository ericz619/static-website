FROM node:12-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

EXPOSE 8080

RUN node index.js

FROM nginx:alpine

COPY proxy.conf /etc/nginx/conf.d/default.conf