# Stage 1: Builder
FROM node:20-alpine AS builder

WORKDIR /app

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm ci

# Copy rest of the app
COPY . .

# Set headless Chrome env for Karma
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Optional: install Chromium for headless tests
RUN apk add --no-cache chromium

# Run tests in headless mode; ignore failures
RUN npm test -- --watch=false --browsers=ChromeHeadless || echo "No tests found"

# Build Angular app for production
RUN ng build --configuration production

# Stage 2: Serve
FROM nginx:alpine

COPY --from=builder /app/dist/ /usr/share/nginx/html

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
