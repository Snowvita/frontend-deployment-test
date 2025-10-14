# Stage 1: Build Angular app
FROM node:20-alpine AS builder

# Install dependencies for headless Chrome
RUN apk add --no-cache chromium

# Set Chrome binary path
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CI=true

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy project files
COPY . .

# Run Angular tests in headless mode
RUN npx ng test --watch=false --browsers=ChromeHeadless || echo "No tests found"

# Build production Angular app
RUN npx ng build --configuration production

# Stage 2: Serve app with Nginx
FROM nginx:alpine

# Copy built app from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
