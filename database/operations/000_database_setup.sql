-- Aurelia Operations Platform
-- PostgreSQL database bootstrap
--
-- Run as a PostgreSQL administrative user.

CREATE DATABASE aurelia_operations;

--CREATE SCHEMA operations;

--Create user 

CREATE ROLE aurelia_app
WITH
    LOGIN
    PASSWORD 'aurelia';

\du - list of roles

--psql -U postgres -d aurelia_operations
--aurelia
--replace_with_a_local_password


GRANT CONNECT
ON DATABASE aurelia_operations
TO aurelia_app;


GRANT USAGE
ON SCHEMA operations
TO aurelia_app;


GRANT CONNECT
ON DATABASE aurelia_operations
TO aurelia_app;


GRANT USAGE
ON SCHEMA operations
TO aurelia_app;


GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES
IN SCHEMA operations
TO aurelia_app;


GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES
IN SCHEMA operations
TO aurelia_app;


-- Future tables created by postgres
ALTER DEFAULT PRIVILEGES
FOR ROLE postgres
IN SCHEMA operations
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES
TO aurelia_app;


-- Future identity/sequence objects created by postgres
ALTER DEFAULT PRIVILEGES
FOR ROLE postgres
IN SCHEMA operations
GRANT USAGE, SELECT, UPDATE
ON SEQUENCES
TO aurelia_app;