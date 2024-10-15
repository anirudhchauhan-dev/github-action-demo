# Stage 1: Build the application
FROM oven/bun:latest AS build

# Set working directory
ARG WORKDIR=/app
WORKDIR ${WORKDIR}

# Copy package.json and bun.lockb (if available)
COPY package*.json ./
COPY bun.lockb ./

# Install dependencies using Bun
RUN bun install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the Nest.js application using Bun
RUN bun run build

# Stage 2: Production image
FROM node:18-alpine AS production

# Set working directory
WORKDIR /app

# Install PM2 globally to manage your application
ARG PM2_VERSION=latest
RUN npm install pm2@${PM2_VERSION} -g

# Copy the built application from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package*.json ./

# Expose the port
ARG APP_PORT=3000
EXPOSE ${APP_PORT}

# Set environment variables
ENV NODE_ENV=production

# Set the app name for PM2 and start the application using PM2
ARG APP_NAME=test_app.dev
CMD ["pm2-runtime", "start", "bun", "--name", "${APP_NAME}", "--", "run", "start:prod"]
