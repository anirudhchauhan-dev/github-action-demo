# Stage 1: Build the application with Bun
FROM oven/bun:latest as build

# Set working directory inside the container
WORKDIR /app

# Copy package.json and bun.lockb to leverage Docker layer caching
COPY package.json bun.lockb ./

# Install dependencies using Bun
RUN bun install

# Copy the rest of the application code
COPY . .

# Build the Nest.js application (or your app's build process)
RUN bun run build

# Stage 2: Production image using Node.js
FROM node:18-alpine  # Use the ARG in the FROM statement

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

# Start the application with PM2 and Bun
ARG APP_NAME=test_app.dev
ENV APP_NAME=${APP_NAME}

CMD ["pm2-runtime", "start", "bun", "--name", "${APP_NAME}", "--", "run", "start:prod"]
