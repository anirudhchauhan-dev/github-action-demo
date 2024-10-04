# Stage 1: Build the application
ARG NODE_VERSION=18-alpine
FROM node:${NODE_VERSION} AS build

ARG WORKDIR=/app
WORKDIR ${WORKDIR}

# Copy package.json and package-lock.json for dependency installation
COPY package*.json ./

# Install dependencies
RUN npm install --force

# Copy the rest of the application code
COPY . .

# Copy the appropriate .env file based on the build environment
ARG ENV_FILE=.env
COPY ${ENV_FILE} .env  # Ensure the correct .env file is copied to .env

# Build the Nest.js application
RUN npm run build

# Stage 2: Production image
FROM node:${NODE_VERSION}

# Set the working directory for the production image
WORKDIR /app

# Install PM2 globally
ARG PM2_VERSION=latest
RUN npm install pm2@${PM2_VERSION} -g

# Copy the built application and necessary files from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package*.json ./
COPY .env .env  # Ensure the selected .env is copied

# Expose the port the app runs on
ARG APP_PORT=3000
EXPOSE ${APP_PORT}

# Set environment variables
ENV NODE_ENV=production

# Parameterize the app name and start command
ARG APP_NAME=test_app.dev
CMD ["pm2-runtime", "start", "npm", "--name", "${APP_NAME}", "--", "run", "start:prod"]
