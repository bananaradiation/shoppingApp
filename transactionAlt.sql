CREATE TABLE categories (
    ID          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL
);
CREATE TABLE products (
    ID          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    sku         TEXT NOT NULL UNIQUE,
    price       NUMERIC NOT NULL,
        -- price > 0
    category    INTEGER REFERENCES categories (id) NOT NULL
);
CREATE TABLE users (
    ID          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    role        TEXT NOT NULL,
    age         INTEGER NOT NULL,
        -- age > 0
    state       TEXT NOT NULL,
    creditCard  TEXT
    --hasCart     INTEGER REFERENCES inCart (ID)
);
CREATE TABLE inCart (
    ID          INTEGER REFERENCES users (ID),
    product     INTEGER REFERENCES products (ID),
    quantity    INTEGER
)