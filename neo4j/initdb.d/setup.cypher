// Create social database
CREATE DATABASE $socialDbName IF NOT EXISTS;

// Create two additional database users
CREATE USER $userUsername IF NOT EXISTS SET PASSWORD $userPassword CHANGE NOT REQUIRED;
CREATE USER $socialUsername IF NOT EXISTS SET PASSWORD $socialPassword CHANGE NOT REQUIRED;

// Grant roles to users
GRANT ROLE editor TO $userUsername;
GRANT ROLE reader TO $socialUsername;

// Grant database access
// User has read/write access to social database
GRANT ACCESS ON DATABASE $socialDbName TO $userUsername;

// Social user has read-only access to social database
GRANT ACCESS ON DATABASE $socialDbName TO $socialUsername;

// Show all users
SHOW USERS;

// Show all databases
SHOW DATABASES;