#!/bin/bash
set -e

echo "Starting Neo4j custom entrypoint..."

# Define marker file to track initialization
INIT_MARKER="/data/.initialized"

# Start Neo4j in background
/startup/docker-entrypoint.sh neo4j &
NEO4J_PID=$!

# Check if this is the first run
if [ ! -f "$INIT_MARKER" ]; then
  echo "First run detected. Will initialize database after Neo4j starts..."
  
  # Wait for Neo4j to be ready (use the credentials from NEO4J_AUTH)
  echo "Waiting for Neo4j to start..."
  max_attempts=60
  attempt=0
  
  # Extract username and password from NEO4J_AUTH (format: username/password)
  AUTH_USERNAME="${NEO4J_AUTH%%/*}"
  AUTH_PASSWORD="${NEO4J_AUTH##*/}"
  
  until cypher-shell -u "$AUTH_USERNAME" -p "$AUTH_PASSWORD" "RETURN 1" > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
      echo "ERROR: Neo4j failed to start after $max_attempts attempts"
      exit 1
    fi
    echo "Neo4j not ready yet, waiting... (attempt $attempt/$max_attempts)"
    sleep 2
  done
  
  echo "Neo4j is ready! Running first-time setup..."
  
  # Run setup script if it exists
  if [ -f /app/setup.cypher ]; then
    echo "Executing setup.cypher..."
    
    cypher-shell -u "$AUTH_USERNAME" -p "$AUTH_PASSWORD" \
      --param "userUsername => '$NEO4JDB_USER_USERNAME'" \
      --param "socialUsername => '$NEO4JDB_SOCIAL_USERNAME'" \
      --param "userPassword => '$NEO4JDB_USER_PASSWORD'" \
      --param "socialPassword => '$NEO4JDB_SOCIAL_PASSWORD'" \
      --param "socialDbName => '$NEO4JDB_SOCIAL_DB_NAME'" \
      -f /app/setup.cypher
    
    echo "Setup completed successfully!"
    echo "Created users: $NEO4JDB_USER_USERNAME, $NEO4JDB_SOCIAL_USERNAME"
    echo "Created database: $NEO4JDB_SOCIAL_DB_NAME"
    
    # Create marker file
    touch "$INIT_MARKER"
    echo "Initialization marker created."
  else
    echo "WARNING: No setup.cypher file found at /app/setup.cypher"
  fi
else
  echo "Initialization already completed. Starting Neo4j normally..."
fi

# Keep Neo4j running in foreground
wait $NEO4J_PID