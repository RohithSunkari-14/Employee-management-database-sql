CREATE DATABASE EMPLOYEE_MANAGEMENT_PROJECT_DB;

USE EMPLOYEE_MANAGEMENT_PROJECT_DB;

CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

SELECT * FROM jobdepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT * FROM salarybonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

SELECT * FROM employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT * FROM qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT * FROM LEAVES;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT * FROM payroll;

-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
SELECT DISTINCT(COUNT(EMP_ID)) AS TOTAL_EMPLOYEES FROM EMPLOYEE;

-- Which departments have the highest number of employees?
SELECT J.JOBDEPT ,COUNT(E.EMP_ID) AS EMP
FROM JOBDEPARTMENT AS J
JOIN EMPLOYEE AS E
on J.Job_ID = E.Job_ID
GROUP BY J.JOBDEPT
ORDER BY EMP DESC
LIMIT 1;

-- What is the average salary per department?
SELECT J.JOBDEPT, AVG(S.AMOUNT) AS AVERAGE_SALARY
FROM jobdepartment AS J
JOIN salarybonus AS S
ON J.JOB_ID = S.JOB_ID
GROUP BY JOBDEPT;

-- Who are the top 5 highest-paid employees?
SELECT E.EMP_ID, S.AMOUNT 
FROM EMPLOYEE AS E
JOIN salarybonus AS S
ON E.JOB_ID = S.JOB_ID
ORDER BY S.AMOUNT DESC
LIMIT 5 ;

-- What is the total salary expenditure across the company?
SELECT COUNT(E.EMP_ID) AS TOTAL_EMPLOYEES, SUM(S.AMOUNT) AS TOTAL_SALARY_EXPENDITURE
FROM EMPLOYEE AS E
JOIN salarybonus AS S
ON E.JOB_ID = S.JOB_ID;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- How many different job roles exist in each department?
SELECT JOBDEPT, COUNT(*) AS TOTAL_JOB_ROLES
FROM JOBDEPARTMENT
GROUP BY JOBDEPT
ORDER BY TOTAL_JOB_ROLES DESC;

-- What is the average salary range per department?
SELECT J.JOBDEPT, AVG(S.AMOUNT) AS AVERAGE_SALARY_RANGE
FROM JOBDEPARTMENT AS J
JOIN salarybonus AS S
ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY AVERAGE_SALARY_RANGE DESC;


-- Which job roles offer the highest salary?
SELECT J.JOBDEPT,J.Job_ID,J.name AS JOB_ROLE,S.AMOUNT
FROM JOBDEPARTMENT AS J
JOIN salarybonus AS S
ON J.JOB_ID = S.JOB_ID
ORDER BY S.AMOUNT DESC;

-- Which departments have the highest total salary allocation?
SELECT J.JOBDEPT, SUM(S.AMOUNT) AS TOTAL_SALARY_ALLOCATION
FROM jobdepartment AS J
JOIN salarybonus AS S
ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY TOTAL_SALARY_ALLOCATION DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS total_qualified_employees
FROM Qualification;

-- Which positions require the most qualifications?
SELECT POSITION, COUNT(*) AS QUALIFICATION_COUNT
FROM QUALIFICATION
GROUP BY POSITION
ORDER BY QUALIFICATION_COUNT DESC;

-- Which employees have the highest number of qualifications?
SELECT Emp_ID,COUNT(*) AS qualification_count
FROM Qualification
GROUP BY Emp_ID
ORDER BY qualification_count DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
SELECT YEAR(DATE) , COUNT(DISTINCT EMP_ID) AS TOTAL_EMPLOYEES
FROM LEAVES
GROUP BY YEAR(DATE)
ORDER BY TOTAL_EMPLOYEES DESC; 

-- What is the average number of leave days taken by its employees per department?
SELECT J.JOBDEPT, AVG(leave_count) AS AVERAGE_NUMBER_OF_DAYS
FROM(
		SELECT EMP_ID, COUNT(*) AS LEAVE_COUNT 
        FROM LEAVES 
        GROUP BY EMP_ID
) L
JOIN EMPLOYEE AS E
ON L.EMP_ID = E.EMP_ID
JOIN jobdepartment AS J
ON E.JOB_ID = J.JOB_ID
GROUP BY J.JOBDEPT;

-- Which employees have taken the most leaves?
SELECT EMP_ID, COUNT(*) AS LEAVE_COUNT
FROM LEAVES
GROUP BY EMP_ID
ORDER BY LEAVE_COUNT DESC;

-- What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS total_leave_days
FROM Leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.emp_ID,e.firstname,e.lastname,COUNT(l.leave_ID) AS leave_days,p.total_amount
FROM Employee e
JOIN Leaves l
ON e.emp_ID = l.emp_ID
JOIN Payroll p
ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname, p.total_amount
ORDER BY leave_days DESC;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT SUM(total_amount) AS total_monthly_payroll
FROM Payroll;

-- What is the average bonus given per department?
SELECT j.jobdept,AVG(s.bonus) AS avg_bonus
FROM JobDepartment j
JOIN SalaryBonus s
ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept
ORDER BY avg_bonus DESC;

-- Which department receives the highest total bonuses?
SELECT j.jobdept, SUM(s.bonus) AS total_bonus
FROM JobDepartment j
JOIN SalaryBonus s
ON j.Job_ID = s.Job_ID
GROUP BY j.jobdept
ORDER BY total_bonus DESC;

-- What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) AS average_payroll_amount
FROM Payroll;
