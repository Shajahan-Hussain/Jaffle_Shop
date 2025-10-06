-- Table + column descriptions
CREATE OR REPLACE TABLE JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (
  ID INT AUTOINCREMENT START 1 INCREMENT 1 ORDER,
  schema_name   STRING,
  table_name    STRING,
  column_name   STRING,   -- NULL = table-level description
  description   STRING
);

CREATE OR REPLACE TABLE JAFFLE_SHOP.TESTING.TEST_METADATA (
  ID INT AUTOINCREMENT START 1 INCREMENT 1 ORDER,
  schema_name   STRING,
  table_name    STRING,
  column_name   STRING,
  test_type     STRING,
  test_config   STRING,
  description   STRING,
  scope         STRING   -- values: 'unit' or 'qa'
);

-- MARTS schema
-- Customers table
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('marts', 'customers', NULL, 'Customer overview data mart, offering key details for each unique customer. One row per customer.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('marts', 'customers', 'customer_id', 'The unique key of the orders mart.'),
('marts', 'customers', 'customer_name', 'Customers'' full name.'),
('marts', 'customers', 'count_lifetime_orders', 'Total number of orders a customer has ever placed.'),
('marts', 'customers', 'first_ordered_at', 'The timestamp when a customer placed their first order.'),
('marts', 'customers', 'last_ordered_at', 'The timestamp of a customer''s most recent order.'),
('marts', 'customers', 'lifetime_spend_pretax', 'The sum of all the pre-tax subtotals of every order a customer has placed.'),
('marts', 'customers', 'lifetime_tax_paid', 'The sum of all the tax portion of every order a customer has placed.'),
('marts', 'customers', 'lifetime_spend', 'The sum of all the order totals (including tax) that a customer has ever placed.'),
('marts', 'customers', 'customer_type', 'Options are ''new'' or ''returning'', indicating if a customer has ordered more than once or has only placed their first order to date.');



-- Location description
-- -- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('marts', 'locations', NULL, 'Stores details of business locations such as identifier, name, tax rate, and opening date.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('marts', 'locations', 'location_id', 'Unique identifier for each location.'),
('marts', 'locations', 'location_name', 'Name of the location.'),
('marts', 'locations', 'tax_rate', 'Sales tax rate for the location.'),
('marts', 'locations', 'opened_date', 'Date and time when the location was opened.');

-- ORDERS table
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('marts', 'orders', NULL, 'Order overview data mart, offering key details for each order including if it’s a customer’s first order and a food vs. drink item breakdown. One row per order.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('marts', 'orders', 'order_id', 'The unique key of the orders mart.'),
('marts', 'orders', 'location_id', 'The foreign key relating to the location where the order was placed.'),
('marts', 'orders', 'customer_id', 'The foreign key relating to the customer who placed the order.'),
('marts', 'orders', 'subtotal_cents', 'Order subtotal stored in cents for precision.'),
('marts', 'orders', 'tax_paid_cents', 'Tax amount for the order stored in cents for precision.'),
('marts', 'orders', 'order_total_cents', 'Order total including tax stored in cents for precision.'),
('marts', 'orders', 'subtotal', 'Order subtotal in USD.'),
('marts', 'orders', 'tax_paid', 'Tax amount for the order in USD.'),
('marts', 'orders', 'order_total', 'The total amount of the order in USD including tax.'),
('marts', 'orders', 'ordered_at', 'The timestamp the order was placed at.'),
('marts', 'orders', 'order_cost', 'The sum of supply expenses to fulfill the order.'),
('marts', 'orders', 'order_items_subtotal', 'The sum of subtotals of all items in the order.'),
('marts', 'orders', 'count_food_items', 'The number of food items in the order.'),
('marts', 'orders', 'count_drink_items', 'The number of drink items in the order.'),
('marts', 'orders', 'count_order_items', 'Total number of items in the order.'),
('marts', 'orders', 'is_food_order', 'A boolean indicating if this order included any food items.'),
('marts', 'orders', 'is_drink_order', 'A boolean indicating if this order included any drink items.'),
('marts', 'orders', 'customer_order_number', 'Sequence number of the order for the customer.');
-- DELETE FROM JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA where column_name = 'updated_at';

--ORDER_ITEMS table
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('marts', 'order_items', NULL, 'Stores details of individual items within each order, including product, price, type, and supply cost. One row per order item.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('marts', 'order_items', 'order_item_id', 'Unique identifier for each order item.'),
('marts', 'order_items', 'order_id', 'The foreign key relating to the order that contains this item.'),
('marts', 'order_items', 'product_id', 'The foreign key relating to the product being ordered.'),
('marts', 'order_items', 'ordered_at', 'The timestamp when the order item was created.'),
('marts', 'order_items', 'product_name', 'Name of the product ordered.'),
('marts', 'order_items', 'product_price', 'Price of the product in USD.'),
('marts', 'order_items', 'is_food_item', 'A boolean indicating if the item is a food product.'),
('marts', 'order_items', 'is_drink_item', 'A boolean indicating if the item is a drink product.'),
('marts', 'order_items', 'supply_cost', 'Supply expense incurred to fulfill this item.');

-- products_table
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('marts', 'products', NULL, 'Stores details of products available for orders, including identifiers, type, description, price, and categorization as food or drink. One row per product.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('marts', 'products', 'product_id', 'Unique identifier for each product.'),
('marts', 'products', 'product_name', 'Name of the product.'),
('marts', 'products', 'product_type', 'Category or type of the product.'),
('marts', 'products', 'product_description', 'Description of the product.'),
('marts', 'products', 'product_price', 'Price of the product in USD.'),
('marts', 'products', 'is_food_item', 'A boolean indicating if the product is a food item.'),
('marts', 'products', 'is_drink_item', 'A boolean indicating if the product is a drink item.');

-- supplies table
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('marts', 'supplies', NULL, 'Stores details of supplies used for products, including identifiers, names, costs, and whether the supply is perishable. One row per supply.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('marts', 'supplies', 'supply_uuid', 'System-generated unique identifier for the supply record.'),
('marts', 'supplies', 'supply_id', 'Business identifier for the supply.'),
('marts', 'supplies', 'product_id', 'The foreign key relating to the product that uses this supply.'),
('marts', 'supplies', 'supply_name', 'Name of the supply item.'),
('marts', 'supplies', 'supply_cost', 'Cost of the supply in USD.'),
('marts', 'supplies', 'is_perishable_supply', 'A boolean indicating if the supply is perishable.');

-- STAGING schema
-- stg_customers
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('staging', 'stg_customers', NULL, 'Customer data with basic cleaning and transformation applied, one row per customer.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('staging', 'stg_customers', 'customer_id', 'The unique key for each customer.'),
('staging', 'stg_customers', 'customer_name', 'Name of the customer.');

-- stg_locations
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('staging', 'stg_locations', NULL, 'List of open locations with basic cleaning and transformation applied, one row per location.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('staging', 'stg_locations', 'location_id', 'The unique key for each location.'),
('staging', 'stg_locations', 'location_name', 'Name of the location.'),
('staging', 'stg_locations', 'tax_rate', 'Sales tax rate applicable to the location.'),
('staging', 'stg_locations', 'opened_date', 'Date and time when the location was opened.');

-- stg_order_items
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('staging', 'stg_order_items', NULL, 'Individual food and drink items that make up orders, one row per item.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('staging', 'stg_order_items', 'order_item_id', 'The unique key for each order item.'),
('staging', 'stg_order_items', 'order_id', 'The corresponding order each order item belongs to.'),
('staging', 'stg_order_items', 'product_id', 'The foreign key relating to the product for this order item.');

-- stg_orders
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('staging', 'stg_orders', NULL, 'Order data with basic cleaning and transformation applied, one row per order.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('staging', 'stg_orders', 'order_id', 'The unique key for each order.'),
('staging', 'stg_orders', 'location_id', 'The foreign key relating to the location where the order was placed.'),
('staging', 'stg_orders', 'customer_id', 'The foreign key relating to the customer who placed the order.'),
('staging', 'stg_orders', 'subtotal_cents', 'Order subtotal stored in cents for precision.'),
('staging', 'stg_orders', 'tax_paid_cents', 'Tax amount for the order stored in cents for precision.'),
('staging', 'stg_orders', 'order_total_cents', 'Order total including tax stored in cents for precision.'),
('staging', 'stg_orders', 'subtotal', 'Order subtotal in USD.'),
('staging', 'stg_orders', 'tax_paid', 'Tax amount for the order in USD.'),
('staging', 'stg_orders', 'order_total', 'The total amount of the order in USD including tax.'),
('staging', 'stg_orders', 'ordered_at', 'The timestamp the order was placed at.');

-- stg_products table
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('staging', 'stg_products', NULL, 'Product (food and drink items that can be ordered) data with basic cleaning and transformation applied, one row per product.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('staging', 'stg_products', 'product_id', 'The unique key for each product.'),
('staging', 'stg_products', 'product_name', 'Name of the product.'),
('staging', 'stg_products', 'product_type', 'Category or type of the product.'),
('staging', 'stg_products', 'product_description', 'Description of the product.'),
('staging', 'stg_products', 'product_price', 'Price of the product in USD.'),
('staging', 'stg_products', 'is_food_item', 'A boolean indicating if the product is a food item.'),
('staging', 'stg_products', 'is_drink_item', 'A boolean indicating if the product is a drink item.');

-- stg_supplies
-- Table-level description
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description)
VALUES 
('staging', 'stg_supplies', NULL, 'List of our supply expenses data with basic cleaning and transformation applied. One row per supply cost, not per supply. As supply costs fluctuate they receive a new row with a new UUID. Thus there can be multiple rows per supply_id.');

-- Column-level descriptions
INSERT INTO JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA (schema_name, table_name, column_name, description) VALUES
('staging', 'stg_supplies', 'supply_uuid', 'The unique key of our supplies per cost.'),
('staging', 'stg_supplies', 'supply_id', 'Business identifier for the supply.'),
('staging', 'stg_supplies', 'product_id', 'The foreign key relating to the product that uses this supply.'),
('staging', 'stg_supplies', 'supply_name', 'Name of the supply item.'),
('staging', 'stg_supplies', 'supply_cost', 'Cost of the supply in USD.'),
('staging', 'stg_supplies', 'is_perishable_supply', 'A boolean indicating if the supply is perishable.');

SELECT TABLE_NAME, COUNT(TABLE_NAME) FROM JAFFLE_SHOP.TESTING.DESCRIPTION_METADATA GROUP BY TABLE_NAME;