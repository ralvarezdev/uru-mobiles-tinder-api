#!/bin/bash
set -e

echo "Starting Neo4j custom entrypoint..."

# Define marker file to track if initialization has been done
INIT_MARKER="/data/.initialized"

# Start Neo4j in background
/startup/docker-entrypoint.sh neo4j &
NEO4J_PID=$!

# Check if this is the first run
if [ ! -f "$INIT_MARKER" ]; then
  echo "First run detected. Will initialize database after Neo4j starts..."
  
  # Wait for Neo4j to be ready
  echo "Waiting for Neo4j to start..."
  max_attempts=30
  attempt=0
  until cypher-shell -u "$NEO4J_DEFAULT_USERNAME" -p "$NEO4J_DEFAULT_PASSWORD" "RETURN 1" > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
      echo "ERROR: Neo4j failed to start after $max_attempts attempts"
      exit 1
    fi
    echo "Neo4j not ready yet, waiting... (attempt $attempt/$max_attempts)"
    sleep 5
  done

  echo "Neo4j is ready! Running first-time setup..."

  # Run setup script if it exists
  if [ -f /var/lib/neo4j/setup.cypher ]; then
    echo "Executing setup.cypher..."
    
    # Export variables for cypher-shell parameter substitution
    export USER_USERNAME SOCIAL_USERNAME USER_PASSWORD SOCIAL_PASSWORD SOCIAL_DB_NAME
    
    # Execute setup with parameter substitution
    cypher-shell -u "$NEO4J_DEFAULT_USERNAME" -p "$NEO4J_DEFAULT_PASSWORD" \
      --param "userUsername => '$NEO4J_USER_USERNAME'" \
      --param "socialUsername => '$NEO4J_SOCIAL_USERNAME'" \
      --param "userPassword => '$NEO4J_USER_PASSWORD'" \
      --param "socialPassword => '$NEO4J_SOCIAL_PASSWORD'" \
      --param "socialDbName => '$NEO4J_SOCIAL_DB_NAME'" \
      -f /var/lib/neo4j/setup.cypher
    
    echo "Setup completed successfully!"
    echo "Admin user: $ADMIN_USER (created by NEO4J_AUTH with full privileges)"
    echo "Created users: $USER_USERNAME (read/write), $SOCIAL_USERNAME (read-only)"
    echo "Created database: $SOCIAL_DB_NAME"
    
    # Create marker file to indicate initialization is complete
    touch "$INIT_MARKER"
    echo "Initialization marker created. Future runs will skip setup."
  else
    echo "No setup.cypher file found, skipping initialization."
  fi
else
  echo "Initialization already completed. Starting Neo4j normally..."
fi

# Keep Neo4j running in foreground
wait $NEO4J_PID