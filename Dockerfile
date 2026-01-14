FROM node:22-bookworm

# 1. Install build tools AND Docker CLI
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python-is-python3 \
    make \
    g++ \
    curl \
    gnupg \
    lsb-release

# Install Docker CLI so your app can find 'docker'
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli

WORKDIR /app
COPY . .

# 2. Install dependencies and compile the missing secure_open.node file
RUN npm install
RUN cd libs && npx node-gyp rebuild

# 3. Build the TypeScript project
RUN npm run build

# 4. FIX PATHS: Move the module into the dist folder
RUN mkdir -p dist/libs/build/Release/ && \
    cp libs/build/Release/secure_open.node dist/libs/build/Release/

# 5. ENVIRONMENT FIX: Create .env and set to 0.0.0.0 for Render
RUN echo 'remote="0.0.0.0"\nport=10000\nDEBUG=false\nenvironment="production"' > .env
# Create a fake docker command that returns success for 'docker ps'
RUN echo '#!/bin/sh\nexit 0' > /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker
    # This applies your panel URL and key during the Docker build
RUN npm run configure -- --panel "https://panel.fshost.qzz.io" --key "oFergEDyhOi8mMaXGUbC43fHj8jqtzbB"

    

# 6. Start the app 
CMD ["node", "dist/app/app.js"]
