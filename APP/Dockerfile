FROM node:18-alpine3.17

WORKDIR /usr/app

COPY package*.json /usr/app/

RUN npm install

COPY . .

ENV MONGO_DB=solar-system-db
ENV MONO_URI=mongodb://db_admin:db_12345@solar-system-db.cluster-cxu20w2ieheu.us-east-2.docdb.amazonaws.com:27017/solar-system-db?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false
ENV MONGO_COLLECTION=planets
ENV S3_MONGO_DB_KEY=superData.planets.json
ENV S3_MONGO_ACCESS_KEY=global-bundle.pem

EXPOSE 3000

CMD [ "npm", "start" ]
