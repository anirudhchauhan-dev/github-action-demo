# Stage 1: Build the application
ARG NODE_VERSION=18-alpine
FROM node:${NODE_VERSION} AS build

# Define the working directory and default build arguments
ARG WORKDIR=/app
WORKDIR ${WORKDIR}

# Copy package.json and package-lock.json for dependency installation
COPY package*.json ./

# Install dependencies (including devDependencies for building)
RUN npm install --force

# Copy the rest of the application code
COPY . .

# Build the Nest.js application
RUN npm run build

# Stage 2: Production image
FROM node:${NODE_VERSION}

# Set the working directory for the production image
WORKDIR /app

# Install only production dependencies
COPY package*.json ./
RUN npm install --only=production

# Install PM2 globally
ARG PM2_VERSION=latest
RUN npm install pm2@${PM2_VERSION} -g

# Copy the built application from the build stage
COPY --from=build /app/dist ./dist

# Expose the port the app runs on
ARG APP_PORT=3000
ENV APP_PORT=${APP_PORT}
EXPOSE ${APP_PORT}

# Set environment variables for app name and start command
ARG APP_NAME=test_app.dev
ENV APP_NAME=${APP_NAME}

# Start the application with PM2
CMD ["pm2-runtime", "start", "npm", "--name", "${APP_NAME}", "--", "run", "start:prod"]
