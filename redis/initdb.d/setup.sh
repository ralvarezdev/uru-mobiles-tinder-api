#!/bin/sh

echo "=========================================="
echo "Redis Tinder Setup: Starting..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create Redis users for gRPC Auth, User, Chats, Social, and Websockets Services
echo "Creating Redis users..."

# Create user for gRPC Auth Service
(echo "AUTH ${REDIS_DEFAULT_PASSWORD}"; echo "ACL SETUSER ${REDIS_AUTH_USER} on >${REDIS_AUTH_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read +@write") | redis-cli
echo "${GREEN}✓ Auth service created successfully!${NC}"

# Create user for gRPC User Service
(echo "AUTH ${REDIS_DEFAULT_PASSWORD}"; echo "ACL SETUSER ${REDIS_USER_USER} on >${REDIS_USER_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read") | redis-cli
echo "${GREEN}✓ User service created successfully!${NC}"

# Create user for gRPC Chats Service
(echo "AUTH $REDIS_DEFAULT_PASSWORD"; echo "ACL SETUSER ${REDIS_CHATS_USER} on >${REDIS_CHATS_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read") | redis-cli
echo "${GREEN}✓ Chats service created successfully!${NC}"

# Create user for gRPC Social Service
(echo "AUTH ${REDIS_DEFAULT_PASSWORD}"; echo "ACL SETUSER ${REDIS_SOCIAL_USER} on >${REDIS_SOCIAL_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read") | redis-cli
echo "${GREEN}✓ Social service created successfully!${NC}"

# Create user for Websockets Realtime Chats Service
(echo "AUTH ${REDIS_DEFAULT_PASSWORD}"; echo "ACL SETUSER ${REDIS_WEBSOCKETS_USER} on >${REDIS_WEBSOCKETS_PASSWORD} ~* &${REDIS_TOKENS_DB} +@read") | redis-cli
echo "${GREEN}✓ Websockets service created successfully!${NC}"

# Save again with root authentication
redis-cli -a "${REDIS_DEFAULT_PASSWORD}" --no-auth-warning ACL SAVE
echo "Users saved to ACL file."

echo "Users created successfully!"

echo ""
echo "=========================================="
echo "${GREEN}Redis Setup: Complete!${NC}"
echo "=========================================="