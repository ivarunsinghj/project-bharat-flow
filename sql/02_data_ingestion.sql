-- ============================================================================
-- PROJECT BHARAT-FLOW: DATA INGESTION SCRIPTS & BULK LOADER
-- ============================================================================

-- PostgreSQL COPY Commands
/*
\copy suppliers FROM 'data/suppliers.csv' WITH (FORMAT csv, HEADER true);
\copy fulfillment_hubs FROM 'data/fulfillment_hubs.csv' WITH (FORMAT csv, HEADER true);
\copy products FROM 'data/products.csv' WITH (FORMAT csv, HEADER true);
\copy customers FROM 'data/customers.csv' WITH (FORMAT csv, HEADER true);
\copy inventory FROM 'data/inventory.csv' WITH (FORMAT csv, HEADER true);
\copy orders FROM 'data/orders.csv' WITH (FORMAT csv, HEADER true);
\copy order_items FROM 'data/order_items.csv' WITH (FORMAT csv, HEADER true);
*/

-- MySQL LOAD DATA INFILE Commands
/*
LOAD DATA LOCAL INFILE 'data/suppliers.csv' INTO TABLE suppliers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'data/fulfillment_hubs.csv' INTO TABLE fulfillment_hubs FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'data/products.csv' INTO TABLE products FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'data/customers.csv' INTO TABLE customers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'data/inventory.csv' INTO TABLE inventory FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'data/orders.csv' INTO TABLE orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'data/order_items.csv' INTO TABLE order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
*/

-- SQLite .mode csv and .import commands
/*
.mode csv
.import --skip 1 data/suppliers.csv suppliers
.import --skip 1 data/fulfillment_hubs.csv fulfillment_hubs
.import --skip 1 data/products.csv products
.import --skip 1 data/customers.csv customers
.import --skip 1 data/inventory.csv inventory
.import --skip 1 data/orders.csv orders
.import --skip 1 data/order_items.csv order_items
*/

-- Python Automated Ingestion:
-- Run: python3 scripts/load_sqlite.py to instantiate the local database.
