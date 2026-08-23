select * from book_cnts;
select * from books;
select * from books_price_greater_than_seven;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

/* Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue. */

select m.member_id, 
m.member_name, 
ist.issued_book_name as book_name,
ist.issued_date,
case
when current_date - ist.issued_date > 30
then current_date - ist.issued_date 
end as overdure_days
from 
members as m 
join issued_status as ist
on ist.issued_member_id = m.member_id
left join return_status as rst 
on rst.issued_id = ist.issued_id
where rst.issued_id is null
order by m.member_id;

/* Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes"
when they are returned (based on entries in the return_status table). */

-- Store procedure
create or replace procedure add_to_return_records(
	p_return_id varchar(10),
	p_issued_id varchar(10))
language plpgsql 
AS $$ 

declare 
	v_isbn varchar(50);
	v_book_name varchar(80);

begin 
	-- all your logic and code
	-- inserting into return_status based on users input
insert into return_status(return_id, issued_id, return_date)
values 
	(p_return_id,
	 p_issued_id,
	 current_date);

select 
	issued_book_isbn,
	issued_book_name
	into 
	v_isbn, 
	v_book_name
from issued_status 
where issued_id = p_issued_id;

update books
set status = 'yes'
where isbn = v_isbn;

raise notice 'Thank you for returning the book %', v_book_name;

end;
$$

-- The below query tells us the books that are not returned 
select ist.issued_book_name, ist.issued_id, ist.issued_book_isbn
from issued_status as ist 
left join return_status as rst 
on rst.issued_id = ist.issued_id
where rst.issued_id is null;

-- calling procedure
call add_to_return_records('RS135', 'IS135');
call add_to_return_records('RS140', 'IS140');

/* Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned, and 
the total revenue generated from book rentals. */

create table branch_report 
as 
select 
b.branch_id,
b.manager_id,
count(ist.issued_id) as no_of_books_issued,
count(rst.return_id) as no_of_books_returned,
sum(bk.rental_price) as total_revenue
from issued_status as ist
join employees as e 
on ist.issued_emp_id = e.emp_id 
join branch as b
on e.branch_id = b.branch_id
left join return_status as rst
on rst.issued_id = ist.issued_id
join books as bk
on ist.issued_book_isbn = bk.isbn
group by b.branch_id, b.manager_id;

select * from branch_report;

/* Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table 
active_members containing members who have issued at least 
one book in the last 29 months. */

create table active_members 
as 
select * from members
where member_id IN (select
                    distinct issued_member_id   
                    from issued_status
                    where 
                        issued_date >= current_date - interval '29 month'
                    );

select * from active_members;

/* Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the employees who have processed
the most book issues. Display the employee name, 
number of books processed, and their branch. */

select 
e.emp_name,
e.branch_id,
max(b.contact_no) as contact_no,
count(ist.issued_id) as no_of_books_processed
from employees as e 
join issued_status as ist
on ist.issued_emp_id = e.emp_id
join branch as b 
on e.branch_id = b.branch_id
group by e.emp_id
order by no_of_books_processed desc;

/* Task 18: Stored Procedure Objective:
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status 
of a book in the library based on its issuance.
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is
available (status = 'yes').
If the book is available, it should be issued,
and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'),
the procedure should return an error message indicating that
the book is currently not available.*/

create or replace procedure issue_book(
p_book_id varchar(25),
p_issued_id varchar(25),
p_member_id varchar(25),
p_emp_id varchar(10)
)
language plpgsql
as $$

declare 
-- all the variables
v_book_name varchar(80);
v_status varchar(10);

begin 
-- all the code
select
book_title, status 
into 
v_book_name, v_status
from books
where isbn = p_book_id;

if v_status = 'yes'
then 
insert into issued_status (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
values 
(p_issued_id, p_member_id, v_book_name, current_date, p_book_id, p_emp_id);

update books
set status = 'no'
where isbn = p_book_id;

raise notice 'Book records added successfully for book isbn: %', p_book_id;

else 
raise notice 'Sorry to inform you that the book you have requested is currently unavailabe book_isbn: %', p_book_id;
end if; 
end;
$$;

-- testing 
select * from books 
-- where isbn = '978-0-375-41398-8'; -- status: no
-- where isbn = '978-0-553-29698-2'; -- status: yes

select * from issued_status
-- where issued_book_isbn = '978-0-375-41398-8'; 
-- where issued_book_isbn = '978-0-553-29698-2'; 

select * from members;
select * from employees;

call issue_book('978-0-375-41398-8', 'IS141', 'C108', 'E104'); 
call issue_book('978-0-553-29698-2', 'IS141', 'C108', 'E104'); 

/* Task 19: Create Table As Select (CTAS) Objective:
Create a CTAS (Create Table As Select) query to 
identify overdue books and calculate fines. 
Description: 
Write a CTAS query to create a new table 
that lists each member and the books they have issued 
but not returned within 30 days. 
The table should include: 
The number of overdue books. The total fines, with each day's fine
calculated at $0.50. The number of books issued by each member.
The resulting table should show:
Member ID, Number of overdue books, Total fines */ 

create table overdue_fines as 
select 
m.member_id, 
count(ist.issued_id) as no_of_overdue_books,
sum(
	case  
		when rst.return_date - ist.issued_date > 30
			then (rst.return_date - ist.issued_date - 30) * 0.50 
		when rst.return_date is null
			then (current_date - ist.issued_date - 30) * 0.50
		else 0
	end
) as total_fine
from 
issued_status as ist 
left join return_status as rst
on rst.issued_id = ist.issued_id
join members as m
on ist.issued_member_id = m.member_id 
where
(rst.return_date is null and current_date > ist.issued_date + interval '30 days')
or 
(rst.return_date - ist.issued_date > 30)
group by m.member_id;

select * from overdue_fines;