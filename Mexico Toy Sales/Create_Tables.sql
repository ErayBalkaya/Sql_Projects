-- Create Sales table

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    date DATE,
    store_id INTEGER,
    product_id INTEGER,
    units INTEGER
);

-- Create Products table

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    product_cost NUMERIC(12, 2),
    product_price NUMERIC(12, 2)
);

-- Create Stores table

CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100),
    store_city VARCHAR(50),
    store_location VARCHAR(100),
    store_open_date DATE
);

-- Create Inventory table

CREATE TABLE inventory (
    store_id INTEGER,
    product_id INTEGER,
    stock_on_hand INTEGER,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create Calendar table

CREATE TABLE calendar (
    date DATE PRIMARY KEY
);
