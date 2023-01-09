CREATE TABLE users(
    user_id uuid PRIMARY KEY,
    username text NOT NULL UNIQUE,
    password text NOT NULL
);
