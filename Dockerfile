# Stage 1: Build the application
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install --force

# Copy the rest of the application code
COPY . .

# Build the Nest.js application
RUN npm run build

# Stage 2: Production image
FROM node:18-alpine

# Set the working directory for the production image
WORKDIR /app

# Install PM2 globally
RUN npm install pm2 -g

# Copy the built application from the build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package*.json ./

# Expose the port the app runs on
EXPOSE 3000

# Start the application with PM2
CMD ["pm2-runtime", "start", "npm", "--name", "gapmap.dev", "--", "run", "start:prod"]
