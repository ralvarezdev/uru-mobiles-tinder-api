#!/bin/sh

# Create the initdb.d/sql directory if it doesn't exist
mkdir -p ./postgres/initdb.d/sql

# Create the folders if they don't exist
mkdir -p ./sql-auth
mkdir -p ./sql-user
mkdir -p ./sql-chats

# Copy SQL initialization files from Auth microservice to the postgres directory
for file in ./sql-auth/*.sql; do
    if [ -f "$file" ]; then
        cp "$file" "./postgres/initdb.d/sql/auth_$(basename "$file")"
    fi
done

# Copy SQL initialization files from User microservice to the postgres directory
for file in ./sql-user/*.sql; do
    if [ -f "$file" ]; then
        cp "$file" "./postgres/initdb.d/sql/user_$(basename "$file")"
    fi
done

# Copy SQL initialization files from Chats microservice to the postgres directory
for file in ./sql-chats/*.sql; do
    if [ -f "$file" ]; then
        cp "$file" "./postgres/initdb.d/sql/chats_$(basename "$file")"
    fi
done

# Ensure SQL files can be read
chmod a+r ./postgres/initdb.d/sql/*.sql
echo "SQL initialization files prepared."