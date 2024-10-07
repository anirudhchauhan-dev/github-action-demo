
# Stage 1: Build the application
ARG NODE_VERSION=18-alpine
FROM node:${NODE_VERSION} AS build

ARG WORKDIR=/app
WORKDIR ${WORKDIR}

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --force

# Copy the rest of the application code
COPY . .

# Build the Nest.js application
RUN npm run build

# Stage 2: Production image
FROM node:${NODE_VERSION}

WORKDIR /app

# Install PM2 globally
ARG PM2_VERSION=latest
RUN npm install pm2@${PM2_VERSION} -g

# Copy the built application from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package*.json ./

# Expose the port
ARG APP_PORT=3000
EXPOSE ${APP_PORT}

# Set environment variables from the .env file
ENV NODE_ENV=production

ARG APP_NAME=test_app.dev
CMD ["pm2-runtime", "start", "npm", "--name", "${APP_NAME}", "--", "run", "start:prod"]
