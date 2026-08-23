-- Library Management System

CREATE TABLE books(
isbn varchar(20) PRIMARY KEY,
book_title varchar(75),
category varchar(10),
rental_price float,
status varchar(10),
author varchar(40),
publisher varchar(60)
);

CREATE TABLE branch(
branch_id varchar(10) PRIMARY KEY,
manager_id varchar(10),
branch_address varchar(20),
contact_no varchar(10)
);

CREATE TABLE employees(
emp_id varchar(10) PRIMARY KEY,
emp_name varchar(20),
"position" varchar(18),
salary integer,
branch_id varchar(16)
);

CREATE TABLE issued_status
(issued_id varchar(25) PRIMARY KEY,
issued_member_id varchar(25),
issued_book_name varchar(75),
issued_date date,
issued_book_isbn varchar(25),
issued_emp_id varchar(20)
);

CREATE TABLE members
(member_id varchar(10) PRIMARY KEY,
member_name varchar(20),
member_address varchar(20),
reg_date date
);

CREATE TABLE return_status 
(return_id varchar(10) PRIMARY KEY,
issued_id varchar(10),
return_book_name varchar(75),
return_date date,
return_book_isbn varchar(20)
);

-- FOREGIN KEY 
ALTER TABLE issued_status
ADD CONSTRAINT fk_members FOREIGN KEY (issued_member_id) 
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees FOREIGN KEY (issued_emp_id) 
REFERENCES employees(emp_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books FOREIGN KEY (issued_book_isbn) 
REFERENCES books(isbn);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status FOREIGN KEY (issued_id) 
REFERENCES issued_status(issued_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch FOREIGN KEY (branch_id) 
REFERENCES branch(branch_id);