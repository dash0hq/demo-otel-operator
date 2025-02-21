FROM node:22.12.0-slim
WORKDIR /app

COPY package.json /app
RUN npm install
COPY . /app

CMD ["node","app.js"]