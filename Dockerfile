FROM node:12-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8080

CMD ["npm", "run", "start"]

FROM nginx:alpine

COPY proxy.conf /etc/nginx/conf.d/default.conf