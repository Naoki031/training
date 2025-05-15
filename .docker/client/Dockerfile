# Use the official Node.js 20 image as a base image
FROM node:22-alpine AS dependency-base

# Create destination directory
ENV WORKDIR=/home/attendance_client
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR

# Install system dependencies
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk add --no-cache openssh g++ make python3 bash vim git wget curl nodejs npm && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Install Nuxt.js CLI
RUN npm install -g npm@10

FROM dependency-base AS client-development
# Set NODE_ENV environment variable to development
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Copy over package.json and package-lock.json files
COPY ./sources/attendance_client/package*.json $WORKDIR/

# Retry mechanism for npm install
RUN set -ex; \
    for i in $(seq 1 5); do \
        npm install && break || sleep 15; \
    done; \
    npm cache clean --force

# Service hostname
ENV NUXT_HOST=0.0.0.0

# Copy the rest of the application code
COPY ./sources/attendance_client/ $WORKDIR/

# Adjust permissions for Nuxt.js directory
RUN chmod -R 755 $WORKDIR

# Use non-root user for better security
ARG UID=1041
ARG GID=1001
RUN addgroup -g ${GID} client && \
    adduser -D -G client -u ${UID} client

# Change ownership of the working directory
RUN chown -R client:client $WORKDIR

# Switch to the non-root user
USER client

# Expose port 3000 (Nuxt default port)
EXPOSE 3000

# Command to start the application
CMD ["sh", "-c", "npm install && npm run dev"]