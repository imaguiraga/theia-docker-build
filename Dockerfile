# ------------------------------------------------------------------
#  STAGE 1 – build container (everything needed to *compile* Theia)
# ------------------------------------------------------------------
FROM node:20-bullseye AS build-stage

# system libraries required by native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ pkg-config libx11-dev libxkbfile-dev libsecret-1-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home/theia
COPY package.json yarn.lock* ./

# install dependencies & download plugins
RUN yarn --frozen-lockfile && yarn theia download:plugins

# copy source (here only package.json scripts) & build
COPY . .
RUN yarn build

# ------------------------------------------------------------------
#  STAGE 2 – tiny runtime image (only node + built artefacts)
# ------------------------------------------------------------------
FROM node:20-bullseye-slim

# create unprivileged user
RUN groupadd -r theia && useradd -r -g theia -d /home/theia -s /bin/bash theia \
 && mkdir -p /home/theia && chown theia:theia /home/theia

WORKDIR /home/theia
# copy everything that was built
COPY --from=build-stage --chown=theia:theia /home/theia /home/theia

USER theia
EXPOSE 3000

# start the browser backend
CMD ["node", "lib/backend/main.js", "--hostname=0.0.0.0", "--port=3000"]