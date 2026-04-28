FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git /flutter --depth 1 --branch 3.24.0

RUN /flutter/bin/flutter config --enable-web && /flutter/bin/flutter precache --web

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN /flutter/bin/flutter pub get

COPY . .

RUN /flutter/bin/flutter build web --release

FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

