# BASELINE (deliberately weak): old base image, runs as root
FROM node:14
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
