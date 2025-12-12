FROM neo4j:5.15

# Copy custom scripts
COPY entrypoint.sh /entrypoint.sh
COPY initdb.d/setup.cypher /var/lib/neo4j/setup.cypher

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["neo4j"]