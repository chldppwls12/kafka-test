create database testdb; 
use testdb; 
CREATE TABLE customers ( 
    id VARCHAR(255), 
    customer_name VARCHAR(255), 
    customer_description VARCHAR(255),
    PRIMARY KEY (id) 
);

GRANT ALL PRIVILEGES ON *.* TO 'mysqluser'@'%';