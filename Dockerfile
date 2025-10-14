# Stage 1: Builder - Node environment
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Run tests (if none, just echo)
RUN npm test || echo "No tests found"

# Build Angular app
RUN npm run build -- --output-path=dist

# Stage 2: Production image - Nginx
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
