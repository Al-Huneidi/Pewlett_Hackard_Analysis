-- Use LEFT JOIN with tables employees and current_emp to 
-- create table of employees eligible for supervisory role.
SELECT e.emp_no,
	   e.birth_date,
	   e.first_name,
	   e.last_name
INTO born_supervisor 
FROM employees AS e
LEFT JOIN current_emp AS ce
ON (e.emp_no = ce.emp_no)
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY emp_no ASC;

-- Create a list with the number of titles retiring.
-- Create a list with the number of titles retiring.
SELECT ri.emp_no,
	   ri.first_name,
	   ri.last_name,
	   ti.title,
	   ti.from_date,
	   s.salary
INTO titles_retiring
FROM retirement_info as ri
INNER JOIN titles AS ti
ON (ri.emp_no = ti.emp_no)
INNER JOIN salaries AS s
ON (ri.emp_no = s.emp_no)
ORDER BY emp_no ASC;

-- Delete employees that have held a title more than once.
SELECT emp_no, first_name, last_name, title, from_date, salary 
INTO unique_titles
FROM
  (SELECT emp_no, first_name, last_name, title, from_date, salary,
     ROW_NUMBER() OVER 
(PARTITION BY (emp_no, first_name, last_name) ORDER BY from_date DESC) rn
   FROM titles_retiring
  ) tmp WHERE rn = 1;

  -- Create a list with the number of titles retiring including to_date field.
SELECT ri.emp_no,
	   ri.first_name,
	   ri.last_name,
	   ti.title,
	   ti.from_date,
	   ti.to_date,
	   s.salary
INTO titles_retiring_info
FROM retirement_info as ri
INNER JOIN titles AS ti
ON (ri.emp_no = ti.emp_no)
INNER JOIN salaries AS s
ON (ri.emp_no = s.emp_no)
ORDER BY emp_no ASC;

-- Delete employees that have held a title more than once in table that includes to_date.
SELECT emp_no, first_name, last_name, title, from_date, to_date, salary 
INTO unique_titles_info
FROM
  (SELECT emp_no, first_name, last_name, title, from_date, to_date, salary,
     ROW_NUMBER() OVER 
(PARTITION BY (emp_no, first_name, last_name) ORDER BY from_date DESC) rn
   FROM titles_retiring_info
  ) tmp WHERE rn = 1;

  -- Create a list with the number of titles retiring including to_date field.
SELECT ri.emp_no,
	   ri.first_name,
	   ri.last_name,
	   ti.title,
	   ti.from_date,
	   ti.to_date,
	   s.salary
INTO titles_retiring_info
FROM retirement_info as ri
INNER JOIN titles AS ti
ON (ri.emp_no = ti.emp_no)
INNER JOIN salaries AS s
ON (ri.emp_no = s.emp_no)
ORDER BY emp_no ASC;

SELECT * FROM titles_retiring_info;

-- Delete employees that have held a title more than once in table that includes to_date.
SELECT emp_no, first_name, last_name, title, from_date, to_date, salary 
INTO unique_titles_info
FROM
  (SELECT emp_no, first_name, last_name, title, from_date, to_date, salary,
     ROW_NUMBER() OVER 
(PARTITION BY (emp_no, first_name, last_name) ORDER BY from_date DESC) rn
   FROM titles_retiring_info
  ) tmp WHERE rn = 1;

SELECT * FROM unique_titles_info;

-- Create table with a count of the number of employees with the same title.
SELECT COUNT(unique_titles_info.emp_no), unique_titles_info.title 
INTO count_title
FROM unique_titles_info
GROUP BY unique_titles_info.title
ORDER BY title;

--Create a list of mentors born in 1965 from born-supervisor table created from
-- current_emp and filtered for those born in 1965 only and title table to include
-- title, from_date, and to_date.
SELECT bs.emp_no,
	   bs.first_name,
	   bs.last_name,
	   ti.title,
	   ti.from_date,
	   ti.to_date
--INTO select_mentors 
FROM born_supervisor AS bs
LEFT JOIN titles AS ti
ON (bs.emp_no = ti.emp_no)
ORDER BY emp_no ASC;

-- Delete potential mentors, born in 1965, that have held a title more than once.
SELECT emp_no, birth_date,first_name, last_name 
--INTO mentors_no_dups
FROM
  (SELECT emp_no, birth_date, first_name, last_name,
     ROW_NUMBER() OVER 
(PARTITION BY (emp_no, first_name, last_name) ORDER BY emp_no ASC) rn
   FROM born_supervisor
  ) tmp WHERE rn = 1;

  -- Create table with possible mentors and all the required fields.
SELECT mnd.emp_no,
	   mnd.first_name,
	   mnd.last_name,
	   ti.title,
	   ti.from_date,
	   ti.to_date
INTO for_mentors
FROM mentors_no_dups AS mnd
INNER JOIN titles AS ti
ON (mnd.emp_no = ti.emp_no);