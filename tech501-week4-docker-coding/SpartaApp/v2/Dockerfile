FROM node:20

# Set maintainer (note that using LABEL for maintainer is now deprecated in favor of documentation)
LABEL maintainer="haashimalvi@sparta"

# Set working directory
WORKDIR /usr/src/app

# Copy package files first to leverage Docker cache for dependency installation
COPY app/package*.json ./

# Copy the rest of the application
COPY app/ .

# Install dependencies
RUN npm install

# Copy the custom entrypoint script
COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

# Expose the application port
EXPOSE 3000

# Define the command to run your app
# Set the entrypoint and default command
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
CMD ["npm", "start"]
