-- update and insert
merge into products as target
using source_products as source
on target.product_id = source.product_id
when matched and target.price != source.price then 
update set target.price = source.price
when not matched 
insert (product_id, product_name, price)
values (source.product_id, source.product_name, source.price)

-- update and delete
MERGE INTO employees AS target
USING updated_employee_data AS source
ON target.employee_id = source.employee_id
WHEN MATCHED THEN
UPDATE SET
target.salary = source.salary,
target.department = source.department
WHEN NOT MATCHED BY SOURCE THEN
DELETE;

-- update, insert and delete
MERGE INTO inventory AS target
USING updated_Inventory_Data AS source
ON target.product_id = source.product_id
WHEN MATCHED THEN
UPDATE SET
target.stock_quantity = source.stock_quantity,
target.last_updated = CURRENT_DATE()
WHEN NOT MATCHED THEN
INSERT (product_id, stock_quantity, last_updated)
VALUES (source.product_id, source.stock_quantity, CURRENT_DATE())
WHEN NOT MATCHED BY SOURCE THEN
DELETE;