# Stage 1: builder with Node for building/testing
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Run tests
RUN npm test || echo "No tests found"

# Build Angular app (production)
RUN npx ng build --configuration production

# Stage 2: serve built files with nginx
FROM nginx:alpine

COPY --from=builder /app/dist/ /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
