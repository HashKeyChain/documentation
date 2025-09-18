# 构建阶段：使用 Node.js 构建静态文件
FROM node:18-alpine AS builder

WORKDIR /app

# 安装必要的系统依赖
RUN apk add --no-cache libc6-compat

# 复制 package 文件
COPY package.json package-lock.json ./

# 安装依赖 - 使用 npm install（与你的本地环境一致）
RUN npm install

# 复制源代码
COPY . .

# 禁用 Next.js 遥测
ENV NEXT_TELEMETRY_DISABLED=1

# 构建静态文件 - 使用 npm run build
RUN npm run build

# 生产阶段：使用 Nginx 服务静态文件
FROM nginx:alpine AS production

# 复制构建的静态文件到 Nginx 目录
COPY --from=builder /app/out /usr/share/nginx/html

# 创建 Nginx 配置用于 SPA
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # 处理客户端路由 \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # 静态资源缓存 \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    # 安全头 \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
