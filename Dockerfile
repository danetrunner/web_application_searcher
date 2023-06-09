# Multistage Build
## Build frontend
FROM node:18.16-alpine3.17 as builder

WORKDIR /app

COPY . .

RUN npm ci && npm run build && npm prune --production

## Bring runner image
FROM node:18.16-alpine3.17 as runner

ENV NODE_ENV=production

ADD ./proxy-server /app/proxy-server

## Copy artifacts from previous layer
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/package.json /app
COPY --from=builder /app/package-lock.json /app

WORKDIR /app

RUN npm i express dotenv
RUN wget https://gobinaries.com/tj/node-prune --output-document - | /bin/sh && node-prune

EXPOSE 5000

CMD ["npm", "run", "server:up"]
