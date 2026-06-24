# ==========================================
# Stage 1: Builder Stage
# ==========================================
FROM node:20 AS builder

WORKDIR /app

# Sao chép mã nguồn ứng dụng vào stage builder
COPY app/server.js ./

# (Nếu ứng dụng của bạn có package.json, hãy thêm lệnh: RUN npm ci --only=production)


# ==========================================
# Stage 2: Runtime Stage
# ==========================================
FROM node:20-alpine AS runtime

# Thiết lập các nhãn Metadata theo chuẩn OCI (org.opencontainers.image)
LABEL org.opencontainers.image.title="Demo Node.js Web App" \
      org.opencontainers.image.description="A simple Node.js application dockerized with production best practices" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.authors="doductrung234@gmail.com" \
      org.opencontainers.image.licenses="MIT"

WORKDIR /app

# Sao chép file từ stage builder và tự động phân quyền sở hữu cho user 'node'
COPY --from=builder --chown=node:node /app/server.js ./

# Chuyển sang chạy bằng user 'node' (Non-root user) để đảm bảo an toàn bảo mật [cite: 31]
USER node

# Khai báo port ứng dụng sẽ lắng nghe (mang tính chất tài liệu/hướng dẫn) [cite: 25, 26]
EXPOSE 3000

# Thiết lập bộ kiểm tra sức khỏe ứng dụng (Healthcheck)
# Sử dụng 'wget' có sẵn trong Alpine để tránh cài thêm package gây nặng image
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Sử dụng mô hình kết hợp ENTRYPOINT + CMD ở dạng JSON (Exec Form) chuẩn production [cite: 43, 70]
ENTRYPOINT ["node"]
CMD ["server.js"]