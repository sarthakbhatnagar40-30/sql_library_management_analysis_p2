-- use file path and directories according to your operating system (eg, Linux, macOS)

COPY books
FROM 'C:\YourDirectory\books.csv'
WITH (FORMAT CSV, HEADER);

ALTER TABLE books
ALTER COLUMN category TYPE varchar(25);

COPY branch
FROM 'C:\YourDirectory\branch.csv'
WITH (FORMAT CSV, HEADER);

ALTER TABLE branch
ALTER COLUMN contact_no TYPE varchar(20);

COPY employees
FROM 'C:\YourDirectory\employees.csv'
WITH (FORMAT CSV, HEADER);

ALTER TABLE employees
ALTER COLUMN salary TYPE float;

COPY issued_status
FROM 'C:\YourDirectory\issued_status.csv'
WITH (FORMAT CSV, HEADER);

COPY members
FROM 'C:\YourDirectory\members.csv'
WITH (FORMAT CSV, HEADER);

-- Remvoign F.K. constraint because it's violated
ALTER TABLE return_status
DROP CONSTRAINT fk_issued_status;

-- fk_issued_status F.K. constraint violated, importing raw data
COPY return_status
FROM 'C:\YourDirectory\return_status.csv'
WITH (FORMAT CSV, HEADER);

-- taking copy of a column which needs to be a F.K. constraint
ALTER TABLE return_status ADD COLUMN issued_id_copy varchar(10);
UPDATE return_status
SET issued_id_copy = issued_id;

-- Deleting rows which are violating F.K. constraint
DELETE FROM return_status
WHERE issued_id_copy NOT IN (
SELECT issued_id 
FROM issued_status);

-- Adding F.K. constraint to the colum after deleting rows
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id) ON DELETE CASCADE;

-- Deleting copied column
ALTER TABLE return_status DROP COLUMN issued_id_copy;