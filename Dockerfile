# Stage 1: Build the application
ARG NODE_VERSION=18-alpine
FROM node:${NODE_VERSION} AS build

# Set working directory inside the container
ARG WORKDIR=/app
WORKDIR ${WORKDIR}

# Copy package.json and package-lock.json to leverage Docker layer caching
COPY package*.json ./

# Install dependencies
RUN npm install --force

# Copy the rest of the application code
COPY . .

# Build the Nest.js application
RUN npm run build

# Stage 2: Production image
FROM node:${NODE_VERSION}

# Set working directory inside the container
WORKDIR /app

# Install PM2 globally
ARG PM2_VERSION=latest
RUN npm install pm2@${PM2_VERSION} -g

# Copy the built application from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package*.json ./

# Expose the application port (default to 3000 if not provided)
ARG APP_PORT=3000
ENV PORT=${APP_PORT}
EXPOSE ${PORT}

# Environment variables for the app
ENV NODE_ENV=production

# Optional: Copy .env file if necessary (uncomment if needed)
# COPY .env ./

# Run the application with PM2 using environment variable for app name
ARG APP_NAME=test_app.dev
ENV APP_NAME=${APP_NAME}

# Start the application with PM2
CMD ["pm2-runtime", "start", "npm", "--name", "${APP_NAME}", "--", "run", "start:prod"]
