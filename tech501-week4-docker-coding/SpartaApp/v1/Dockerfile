FROM node:20

# Set maintainer (note that using LABEL for maintainer is now deprecated in favor of documentation)
LABEL maintainer="haashimalvi@sparta"

# Set working directory
WORKDIR /usr/src/app

# Copy the rest of the application
COPY app/ .

# Copy package files first to leverage Docker cache for dependency installation
COPY app/package*.json ./

# Install dependencies
RUN npm install


# Expose the application port
EXPOSE 3000

# Define the command to run your app
CMD ["npm", "start"]
