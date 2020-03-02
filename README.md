# Pewlett_Hackard_Analysis
Analyzing future employees retiring and future head count necessary.

## Overview of Project
Future-proof the company by determining how many people will be retiring and, of those employees, who is eligible for a retirement package.

	- Design an ERD that will apply to the data.
	- Create and use a SQL database.
	- Import and export large CSV datasets into pgAdmin.
	- Practice using different joins to create new tables in pgAdmin.
	- Write basic- to intermediate-level SQL statements.

Image of ERD:
![alt text](https://github.com/Al-Huneidi/Pewlett_Hackard_Analysis/blob/master/EmployeeDB.png)

Resources:
departments.csv
employees.csv
salaries.csv
dept_emp.csv
dept_manager.csv
emp_info.csv


# Challenge - Technical Report
	
Objective
To create a list of candidates for the mentorship program.

Work to be done to get a list of candidates for the mentorship program required creating a few more tables.
1. Created a list of current employees born from 01-01-1965 to 12-31-1965.
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
￼![alt text](https://github.com/Al-Huneidi/Pewlett_Hackard_Analysis/blob/master/screenshots/born_supervisor.png)

2. Create a table with the number of retirees with their titles and a finally a count of each title.
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
￼

Then I made another query to add the to_date field as I noticed it was missing and needed to be added.
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

￼


3. I partitioned the table titles_retiring_info to delete duplicates so I could get a count of all the employees per title.
-- Delete employees that have held a title more than once in table that includes to_date.
SELECT emp_no, first_name, last_name, title, from_date, to_date, salary 
INTO unique_titles_info
FROM
  (SELECT emp_no, first_name, last_name, title, from_date, to_date, salary,
     ROW_NUMBER() OVER 
(PARTITION BY (emp_no, first_name, last_name) ORDER BY from_date DESC) rn
   FROM titles_retiring_info
  ) tmp WHERE rn = 1;

￼

Then I created a table to show the count of employees with each title in alphabetical order.
-- Create table with a count of the number of employees with the same title.
SELECT COUNT(unique_titles_info.emp_no), unique_titles_info.title 
INTO count_title
FROM unique_titles_info
GROUP BY unique_titles_info.title
ORDER BY title;

￼

4. Filtered the born_supervisor table, employees born between 01-01-1965 and 12-31-1965 to remove any duplicates in order to find a list of potential mentors.

-- Delete potential mentors, born in 1965m that have held a title more than once.
SELECT emp_no, birth_date,first_name, last_name 
INTO mentors_no_dups
FROM
  (SELECT emp_no, birth_date, first_name, last_name,
     ROW_NUMBER() OVER 
(PARTITION BY (emp_no, first_name, last_name) ORDER BY emp_no ASC) rn
   FROM born_supervisor
  ) tmp WHERE rn = 1;

￼

Then I had to create one more table to add the title, from_date, and to_date fields for a complete table with all necessary information.
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

￼

Observationsand Recommendations:

This analysis is a great start on finding the answers as to how to future-proof the employee base required for Pewlett Hackard to keep their competitive edge. However, more analysis for a more granular look at the data in order to develop and implement a successful plan for the future head count.

 There are 65,428 employees on the retiring list so there will need to be much thought about how many of those positions will not need to be filled and which ones wills.  I suggest some more analysis is required in order to determine the headcount for the future.


There seem to be more Senior Engineers, 15,600, than Engineers, 4692, and Assistant Engineers, 501, which indicates there may too many leaders and not enough individual contributors.  This would suggest new hires would not include Senior Engineers to replace them as they retire.  The same is true for the Senior Staff, 14735, and the Staff, 3837.


There are quite a few employees born in 1965 eligible for the mentorship program.  Additional conditions should be applied to this group other than their birthdate such as title.  It would make sense that only the most senior titles should be the only ones considered as mentors.  Those titles need to be better defined.


