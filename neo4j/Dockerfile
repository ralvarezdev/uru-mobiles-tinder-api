FROM docker.io/library/neo4j:latest

# Copy custom scripts
COPY entrypoint.sh /app/entrypoint.sh
COPY healthcheck.sh /app/healthcheck.sh
COPY initdb.d/setup.cypher /app/setup.cypher

# Set working directory
WORKDIR /app

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh /app/healthcheck.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["neo4j"]