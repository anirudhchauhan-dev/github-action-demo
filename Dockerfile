# Stage 1: Production image
FROM node:18-alpine AS production

# Set working directory
WORKDIR /app

# Install PM2 globally to manage your application
ARG PM2_VERSION=latest
RUN npm install pm2@${PM2_VERSION} -g

# Copy package.json and node_modules from the build artifacts (from CI)
COPY package*.json ./
COPY node_modules ./node_modules

# Copy the pre-built dist folder from the GitHub Actions build artifacts
COPY dist ./dist

# Expose the port
ARG APP_PORT=3000
EXPOSE ${APP_PORT}

# Set environment variables
ENV NODE_ENV=production

# Set the app name for PM2 and start the application using PM2
CMD ["pm2-runtime", "start", "npm", "--name", "test_app.dev", "--", "run", "start:prod"]
