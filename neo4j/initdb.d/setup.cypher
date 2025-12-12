// Neo4j Community Edition - Single Database Setup
// Create users with different access levels

// Create read/write user for user service
CREATE USER $userUsername SET PASSWORD $userPassword CHANGE NOT REQUIRED;
// GRANT ROLE editor TO $userUsername;

// Create read-only user for social service  
CREATE USER $socialUsername SET PASSWORD $socialPassword CHANGE NOT REQUIRED;
// GRANT ROLE reader TO $socialUsername;