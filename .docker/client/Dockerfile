# =============================================
# Stage: base — shared tooling
# =============================================
FROM node:24-alpine AS base

ENV WORKDIR=/home/attendance_client
WORKDIR $WORKDIR

# System dependencies needed for native addons (node-gyp etc.)
RUN apk add --no-cache bash git curl python3 make g++ && \
    rm -rf /var/cache/apk/*

# Update npm to latest
RUN npm install -g npm@latest

# =============================================
# Stage: deps — install dependencies
# =============================================
FROM base AS deps

# Copy only package.json (not lock file) — lock file may be stale after version upgrades
COPY ./sources/attendance_client/package.json ./

RUN npm install && npm cache clean --force

# =============================================
# Stage: development
# =============================================
FROM base AS client-development

ENV NODE_ENV=development
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

# Copy installed node_modules from deps stage into image
# (docker-compose will overlay with a named volume on first run)
COPY --from=deps $WORKDIR/node_modules ./node_modules

# Copy entrypoint
COPY .docker/client/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000 24678

ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "run", "dev"]

# =============================================
# Stage: staging
# =============================================
FROM base AS client-staging

ENV NODE_ENV=production
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

COPY --from=deps $WORKDIR/node_modules ./node_modules
COPY ./sources/attendance_client ./

RUN npm run build

EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
