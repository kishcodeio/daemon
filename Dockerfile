FROM node:18-bullseye

# 1. Install build tools needed for C++ compilation
RUN apt-get update && apt-get install -y build-essential python3

WORKDIR /app
COPY . .

# 2. Install standard npm dependencies
RUN npm install

# 3. FIX: Build the missing secure_open.node file from source
# This goes into the libs folder and compiles the C++ code
RUN cd libs && npx node-gyp rebuild

# 4. Build the main TypeScript project
RUN npm run build

# 5. Ensure the compiled file is placed where the app expects it inside dist
RUN mkdir -p dist/libs/build/Release/ && cp libs/build/Release/secure_open.node dist/libs/build/Release/

# 6. Verify the file exists (this will show in your Render logs)
RUN ls -l dist/libs/build/Release/secure_open.node

# 7. Use the direct path to start the app to avoid path errors
CMD ["node", "dist/src/index.js"]
