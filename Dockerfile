# ==========================================================
# 1. BUILD STAGE — Build Flutter Web App
# ==========================================================
FROM debian:stable-slim AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl unzip xz-utils git clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable web
RUN flutter config --enable-web
RUN flutter doctor

# Copy project
WORKDIR /app
COPY . .

# Build Flutter web
RUN flutter build web --release

# ==========================================================
# 2. RUNTIME STAGE — Serve with Nginx
# ==========================================================
FROM nginx:1.21-alpine

# Copy built web app to Nginx’s public directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
