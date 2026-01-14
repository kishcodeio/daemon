FROM node:22-bookworm

# 1. Install build tools for the C++ module
RUN apt-get update && apt-get install -y build-essential python3 python-is-python3 make g++

WORKDIR /app
COPY . .

# 2. Install dependencies and compile the missing secure_open.node file
RUN npm install
RUN cd libs && npx node-gyp rebuild

# 3. Build the TypeScript project
RUN npm run build

# 4. FIX PATHS: Move the module into the dist folder where the app looks for it
RUN mkdir -p dist/libs/build/Release/ && \
    cp libs/build/Release/secure_open.node dist/libs/build/Release/

# 5. ENVIRONMENT FIX: Create a .env file that works with Render's network
# This overrides the 127.0.0.1 setting so Render can route traffic to your app
RUN echo 'remote="0.0.0.0"\nport=10000\nDEBUG=false\nenvironment="production"' > .env

# 6. Start the app from the compiled entry point
CMD ["node", "dist/app/app.js"]
