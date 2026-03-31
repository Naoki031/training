# =============================================
# Stage: base — shared tooling
# =============================================
FROM node:24-alpine AS base

ENV WORKDIR=/home/attendance_api
WORKDIR $WORKDIR

RUN apk add --no-cache bash git curl mysql-client && \
    rm -rf /var/cache/apk/*

RUN npm install -g npm@latest @nestjs/cli@latest

# =============================================
# Stage: deps — install dependencies
# =============================================
FROM base AS deps

COPY ./sources/attendance_api/package.json ./

RUN npm install && npm cache clean --force

# =============================================
# Stage: development
# =============================================
FROM base AS server_development

ENV NODE_ENV=development

# Copy installed node_modules from deps stage into image
COPY --from=deps $WORKDIR/node_modules ./node_modules

# Copy entrypoint
COPY .docker/node_server/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3001 9229

ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "run", "start:dev"]

# =============================================
# Stage: staging
# =============================================
FROM base AS server_staging

ENV NODE_ENV=production

COPY --from=deps $WORKDIR/node_modules ./node_modules
COPY ./sources/attendance_api ./

RUN npm run build

EXPOSE 3001
CMD ["node", "dist/main"]
