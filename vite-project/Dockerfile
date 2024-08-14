# Stage 1: Build the Vite project
FROM node:18 AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Vite project
RUN npm run build

# Stage 2: Serve the built project using a lightweight Node.js server
FROM node:18

# Set working directory
WORKDIR /app

# Copy the built files from the previous stage
COPY --from=build /app/dist /app/dist

# Install a simple HTTP server
RUN npm install -g serve

# Expose port 5433
EXPOSE 5433

# Start the server
CMD ["serve", "-s", "dist", "-l", "5433"]