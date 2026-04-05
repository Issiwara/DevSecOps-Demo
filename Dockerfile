# ── Stage 1: Build ────────────────────────────────────────────────
FROM --platform=$BUILDPLATFORM nginx:alpine AS builder

COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/templates/default.conf.template

# ── Stage 2: Runtime ──────────────────────────────────────────────
FROM nginx:alpine

COPY --from=builder /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html
COPY --from=builder /etc/nginx/templates/default.conf.template /etc/nginx/templates/default.conf.template

EXPOSE 80

# BACKEND_HOST is now injected at runtime via -e or Kubernetes env
# No .env file needed
CMD ["/bin/sh", "-c", \
    "envsubst '$BACKEND_HOST' < /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]