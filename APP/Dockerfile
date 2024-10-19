FROM node:18-alpine3.17

WORKDIR /usr/app

COPY package*.json /usr/app/

RUN npm install

COPY . .

ENV MONGO_URI=mongodb://db_admin:db_12345@solar-system-db.cluster-cxu20w2ieheu.us-east-2.docdb.amazonaws.com:27017/solarDB?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false


EXPOSE 3000

CMD [ "npm", "start" ]
