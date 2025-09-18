FROM node:18-alpine

WORKDIR /app

# 安装必要的系统依赖
RUN apk add --no-cache libc6-compat

# 复制 package 文件
COPY package.json package-lock.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 禁用 Next.js 遥测
ENV NEXT_TELEMETRY_DISABLED=1

# 暴露端口
EXPOSE 3000

# 启动开发服务器
CMD ["npm","run","dev"]
