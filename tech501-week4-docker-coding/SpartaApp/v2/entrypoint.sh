#!/bin/sh
# entrypoint.sh

# If the environment variable EXECUTE_NPM_INSTALL is set to "true", run npm install.
if [ "$EXECUTE_NPM_INSTALL" = "true" ]; then
  echo "Executing npm install..."
  npm install
fi

# Execute the CMD provided in the Dockerfile or docker-compose.
exec "$@"

