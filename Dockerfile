FROM node:18-bullseye

# Install build tools
RUN apt-get update && apt-get install -y build-essential python3

WORKDIR /app
COPY . .

# Install and build
RUN npm install
# If the project has a custom build script for the 'libs' folder, run it here
RUN npm run build

CMD ["npm", "start"]
