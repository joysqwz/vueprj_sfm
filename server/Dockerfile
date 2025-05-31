FROM node:22

WORKDIR /server

COPY package.json package-lock.json ./

# Установка PostgreSQL 17 клиента
RUN apt-get update && apt-get install -y wget gnupg2 lsb-release \
    && wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y postgresql-client-17 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "run", "dev"]
