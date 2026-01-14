FROM node:22-bookworm

# 1. Install system tools needed to compile C++ code
RUN apt-get update && apt-get install -y build-essential python3 make g++

WORKDIR /app

# 2. Copy all files from GitHub
COPY . .

# 3. Install dependencies and build the C++ module
RUN npm install
RUN cd libs && npx node-gyp rebuild

# 4. Build the TypeScript project
RUN npm run build

# 5. FIX THE PATH: Copy the compiled module into the 'dist' folder
# This makes sure the path ../../../libs works from dist/handlers/
RUN mkdir -p dist/libs/build/Release/ && \
    cp libs/build/Release/secure_open.node dist/libs/build/Release/

# 6. Start the app using the entry point shown in your logs
CMD ["node", "dist/app/app.js"]
