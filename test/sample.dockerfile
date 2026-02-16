# Poikile Theme — Dockerfile Test File
#
# Colors vary by variant — see PALETTE.md for hex values per theme.
#
# Scopes to verify:
#   keyword.other.special-method.dockerfile → keyword  (FROM, RUN, CMD, LABEL, EXPOSE, ENV, ADD, COPY, ENTRYPOINT, VOLUME, USER, WORKDIR, ARG, ONBUILD, HEALTHCHECK, SHELL)
#   keyword.control.dockerfile              → keyword  (AS)
#   entity.name.image.dockerfile            → type  (image names)
#   variable.other.dockerfile               → fg.default  ($VAR, ${VAR})
#   keyword.operator.dockerfile             → fg.subtle
#   constant.numeric.dockerfile             → number  (numbers)
#   string                                  → string
#   comment                                 → fg.muted  italic

# ── Stage 1: Build dependencies ──────────────────────────────────────

FROM node:20-alpine AS deps

LABEL maintainer="jduartea <hello@poikile.dev>"
LABEL org.opencontainers.image.title="Poikile API"
LABEL org.opencontainers.image.version="2.1.0"
LABEL org.opencontainers.image.description="Stoic-inspired task pipeline service"
LABEL org.opencontainers.image.source="https://github.com/jduartea/poikile"

WORKDIR /app

# Install dependencies only (for layer caching)
COPY package.json package-lock.json ./
COPY patches/ ./patches/

RUN npm ci --ignore-scripts \
    && npm cache clean --force

# ── Stage 2: Build application ───────────────────────────────────────

FROM node:20-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ARG BUILD_DATE
ARG GIT_COMMIT
ARG NODE_ENV=production

ENV NODE_ENV=${NODE_ENV}

RUN npm run build \
    && npm prune --production \
    && rm -rf src/ test/ .github/ \
    && echo "Build complete: ${BUILD_DATE} (${GIT_COMMIT})"

# ── Stage 3: Production runtime ──────────────────────────────────────

FROM node:20-alpine AS runner

# Security: non-root user
RUN addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --ingroup appgroup appuser

# Install runtime dependencies
RUN apk add --no-cache \
    curl \
    tini \
    dumb-init \
    ca-certificates

WORKDIR /app

# Copy built artifacts
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./

# Configuration
ENV NODE_ENV=production
ENV PORT=8080
ENV HOST=0.0.0.0
ENV LOG_LEVEL=info
ENV WORKERS=4
ENV MAX_MEMORY=512

ARG APP_VERSION=2.1.0
ENV APP_VERSION=${APP_VERSION}

# Expose ports
EXPOSE 8080
EXPOSE 9090

# Volumes
VOLUME ["/app/data", "/app/logs"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Switch to non-root user
USER appuser:appgroup

# Use tini as PID 1
ENTRYPOINT ["tini", "--"]

# Start the application
CMD ["node", "dist/server.js"]

# ── Stage 4: Development (optional) ─────────────────────────────────

FROM node:20-alpine AS dev

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . .

ENV NODE_ENV=development
ENV PORT=3000
ENV DEBUG=poikile:*

EXPOSE 3000
EXPOSE 9229

# Development server with debugging
CMD ["npx", "tsx", "watch", "--inspect=0.0.0.0:9229", "src/server.ts"]

# ── ONBUILD example ─────────────────────────────────────────────────

FROM runner AS base-image

ONBUILD COPY config/ /app/config/
ONBUILD RUN echo "Config copied for derived image"

# ── Multi-platform build hints ───────────────────────────────────────

# docker buildx build \
#   --platform linux/amd64,linux/arm64 \
#   --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
#   --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) \
#   --tag poikile/api:2.1.0 \
#   --push .
