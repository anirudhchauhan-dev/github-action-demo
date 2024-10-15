# Stage 1: Build the application with Bun
FROM oven/bun:latest as build

# Set working directory inside the container
WORKDIR /app

# Copy package.json and bun.lockb (if available) to leverage Docker layer caching
COPY package.json bun.lockb ./

# Install dependencies using Bun
RUN bun install

# Copy the rest of the application code
COPY . .

# Build the Nest.js application (or your app's build process)
RUN bun run build

# Stage 2: Production image using Node.js
ARG NODE_VERSION=18-alpine
FROM node:${NODE_VERSION}

# Set working directory inside the container
WORKDIR /app

# Copy the built application from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json ./

# Expose the application port (default to 3000 if not provided)
ARG APP_PORT=3000
ENV PORT=${APP_PORT}
EXPOSE ${PORT}

# Environment variables for the app
ENV NODE_ENV=production

# Optional: Copy .env file if necessary
# COPY .env ./

# Run the application with PM2 using environment variable for app name
ARG APP_NAME=test_app.dev
ENV APP_NAME=${APP_NAME}

# Start the application with PM2 and Bun
CMD ["pm2-runtime", "start", "bun", "--name", "${APP_NAME}", "--", "run", "start:prod"]
