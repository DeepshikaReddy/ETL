----------------------------ROW level security(Minor Project-1)---------------------------------------------------------
-- Apply row level security on tables to enable limited access for all users of Organization.

create or replace role HUMAN_RESOURCE;
create or replace role TECHNOLOGY;
create or replace role MARKETING;

create or replace user john password="Deepshika@123" default_role='HUMAN_RESOURCE';
grant role HUMAN_RESOURCE to user john;

create or replace user bill password="Deepshika@123" default_role='MARKETING';
grant role MARKETING to user bill;

grant role HUMAN_RESOURCE to user DEEPS1709 ;
grant role TECHNOLOGY to user DEEPS1709;
grant role MARKETING to user DEEPS1709;

create or replace database role_management;
use database role_management;
create schema employee;

create or replace table employees(
employee_id number,
employee_join_date date,
dept varchar(10),
salary number,
manager_id number
)

insert into employees values
(1,'2018-10-01','HR',40000,4),
(2,'2018-10-01','Tech',50000,9),
(3,'2017-10-01','Marketing',70000,5),
(4,'2016-10-01','HR',40000,5),
(5,'2016-10-01','HR',40000,9),
(6,'2015-10-01','Tech',70000,4);

create or replace table managers(manager_id number,
                                manager_role_name varchar,
                                manager_role_alias varchar);
                                
insert into managers values
(1,'MARKETING','MARKETING'),
(4,'TECHNOLOGY','TECH'),
(4,'HUMAN_RESOURCE','HR'),
(5,'MARKETING','MARKETING'),
(5,'HUMAN_RESOURCE','HR'),
(9,'TECHNOLOGY','TECH'),
(9,'HUMAN_RESOURCE','HR');

grant usage on warehouse test_warehouse to role HUMAN_RESOURCE; 
grant usage on warehouse test_warehouse to role TECHNOLOGY; 
grant usage on warehouse test_warehouse to role MARKETING; 

grant usage on database ROLE_MANAGEMENT to role HUMAN_RESOURCE; 
grant usage on database ROLE_MANAGEMENT to role TECHNOLOGY; 
grant usage on database ROLE_MANAGEMENT to role MARKETING; 

grant usage on schema employee to role HUMAN_RESOURCE; 
grant usage on schema employee to role TECHNOLOGY; 
grant usage on schema employee to role MARKETING; 

use role technology;
use database role_management;
use schema employee;

create or replace secure view vw_employee as
select e.* 
from employees e
where upper(e.dept) in (select upper(manager_role_alias)
                       from managers m
               where upper(manager_role_name)=upper(current_role()));--Eg:current_role() will be marketing for bill
               
create or replace  view vw_employee_norm as
select e.* 
from employees e
where upper(e.dept) in (select upper(manager_role_alias)
                       from managers m
               where upper(manager_role_name)=upper(current_role()));
               
--grant access of view to roles
grant select on view vw_employee to role human_resource;
grant select on view vw_employee to role technology;                      
grant select on view vw_employee to role marketing;
grant select on view vw_employee to role accountadmin;

--grant access of normal view to roles
grant select on view vw_employee_norm to role human_resource;
grant select on view vw_employee_norm to role technology;                      
grant select on view vw_employee_norm to role marketing;
grant select on view vw_employee_norm to role accountadmin;

select * from vw_employee_norm; -- only marketing role can see marketing data.

show views like 'vw_employee_norm';
show views like 'vw_employee'; -- can see only the data cant see the view definition.

select * from vw_employee;

-- Based on the roles , only respective data is visible to the users.








