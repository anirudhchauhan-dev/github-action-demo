ARG NODE_VERSION=18-alpine

# Stage 1: Build the application with Bun
FROM oven/bun AS build

# Set working directory inside the container
WORKDIR /app

# Copy package.json and bun.lockb to leverage Docker layer caching
COPY package.json bun.lockb ./

# Install dependencies using Bun
RUN bun install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the Nest.js application
RUN bun run build

# Stage 2: Production image using Node.js with PM2 and Bun
FROM node:${NODE_VERSION}

# Install PM2 globally in the production stage
RUN npm install -g pm2

# Install Bun in the production image
RUN npm install -g bun

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

# Set environment variables for production
ENV NODE_ENV=production

# Optional: Copy .env file if necessary (uncomment if needed)
# COPY .env ./

# Define the application name (can be passed as a build argument)
ARG APP_NAME=test_app.dev
ENV APP_NAME=${APP_NAME}

# Start the application with PM2 and Bun
CMD ["pm2-runtime", "start", "bun", "--name", "${APP_NAME}", "--", "run", "start:prod"]
