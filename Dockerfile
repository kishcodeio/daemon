FROM node:22-bookworm

# Install build tools for C++
RUN apt-get update && apt-get install -y build-essential python3 python-is-python3 make g++

WORKDIR /app
COPY . .

# Install dependencies and build the missing module
RUN npm install
RUN cd libs && npx node-gyp rebuild

# Build the TypeScript project
RUN npm run build

# FIX THE PATH: Copy the module into the dist folder
RUN mkdir -p dist/libs/build/Release/ && \
    cp libs/build/Release/secure_open.node dist/libs/build/Release/

# Start the app from the correct entry point found in your logs
CMD ["node", "dist/app/app.js"]
