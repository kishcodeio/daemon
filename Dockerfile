FROM node:22-bookworm

# 1. Install system tools needed to compile C++ code
RUN apt-get update && apt-get install -y build-essential python3 make g++

WORKDIR /app

# 2. Copy all files from GitHub
COPY . .

# 3. Install dependencies and build the C++ module
RUN npm install
RUN cd libs && npx node-gyp rebuild

# 4. Compile the C++ module (The missing secure_open.node)
# This will now print the folder contents to the log if it fails
RUN ls -la libs && cd libs && npx node-gyp rebuild

# 5. Build the TypeScript project
RUN npm run build

# 6. Move the compiled module into the dist folder
RUN mkdir -p dist/libs/build/Release/ && \
    cp libs/build/Release/secure_open.node dist/libs/build/Release/

# 7. Start command (Make sure this path matches your logs!)
CMD ["node", "dist/app/app.js"]
