-- SQL PROJECT ON LOGISTICS OF A COMPANY

create schema logistics;
use logistics;

-- 1). CUSTOMER COUNT BASED ON CUSTOMER TYPE TO IDENTIFY CURRENT CUSTOMER PREFERENCE
select count(C_TYPE) as Cust_Count,C_TYPE
from logistics.customer
group by C_TYPE
order by count(C_TYPE);

-- 2). CUSTOMER COUNT BASED ON THEIR STATUS OF PAYMENT IN DESENDING ORDER
select count(C_ID) as CustomerID_Count, Payment_Status
from logistics.payment_details
group by Payment_Status
order by count(C_ID) desc;

-- 3). CUSTOMER COUNT BASIS THEIR PAYMENT MODE IN DESCENDING ORDER OF COUNT
select count(C_ID) as Customer_Count, Payment_Mode
from logistics.payment_details
group by Payment_Mode
order by count(C_ID) desc;

-- 4). COUNT OF CUSTOMERS AS PER SHIPMENT DOMAIN IN DESCENDING ORDER
select count(C_ID) as Customer_Count, SH_DOMAIN
from logistics.shipment_details
group by SH_DOMAIN
order by count(C_ID) desc;

-- 5). COUNT OF CUSTOMER ACCORDING TO SERVICE TYPE IN DESCENDING ORDER OF COUNT
select count(C_ID) as Customer_Count, SER_TYPE
from logistics.shipment_details
group by SER_TYPE
order by count(C_ID) desc;

-- 6). EXPLORING EMPLOYEE COUNT BASED ON DESIGNATION WISE COUNT OF EMPLOYEE'S ID
select count(E_ID) as EmployeeID_Count, E_DESIGNATION
from logistics.employee_details
group by E_DESIGNATION
order by count(E_ID) desc;

-- 7). BRANCH WISE COUNT OF EMPLOYEES FOR EFFICIENCY OF DELIVERIES IN DESCENDING ORDER
select count(E_ID) as Employee_Count, E_BRANCH
from logistics.employee_details
group by E_BRANCH 
order by count(E_ID) desc;

-- 8). FINDING C_ID, M_ID AND TENURE FOR THOSE CUSTOMERS WHOSE MEMBERSHIP IS OVER 10 YRS
select customer.C_ID, customer.M_ID, membership.M_ID, End_date, Start_date,
(End_date-Start_date) as Tenure
from logistics.customer join membership on customer.M_ID = membership.M_ID
where (End_date-Start_date) >10
order by Tenure desc;

-- 9). CONSIDERING AVERAGE PAYMENT AMOUNT BASED ON CUSTOMER TYPE HAVING PAYMENT MODE AS COD
select C_TYPE, Payment_Mode, avg(AMOUNT)
from logistics.customer join payment_details on customer.C_ID = payment_details.C_ID
where Payment_Mode='COD'
group by C_TYPE;

-- 10). AVERAGE PAYMENT AMOUNT BASED ON PAYMENT MODE WHERE PAYMENT DATE IS NOT NULL
select Payment_Mode, Payment_Date, Avg(AMOUNT)  
from payment_details                              
where payment_date like '____-__-__'
group by Payment_Mode;

-- 11). AVERAGE SHIPMENT WEIGHT BASED ON PAYMENT_STATUS WHERE SHIPMENT CONTENT DOES NOT
--     START WITH "H"  
select avg(SH_WEIGHT), Payment_Status
from shipment_details join payment_details on payment_details.SH_ID=shipment_details.SH_ID
where SH_CONTENT in (select SH_CONTENT from shipment_details 
					 where SH_CONTENT not like 'H%%%%%')
group by Payment_Status;

-- 12). AVERAGE OF SHIPMENT WEIGHT  AND SHIPMENT CHARGES BASSED ON SHIPMENT STATUS
SELECT Current_Status, avg(SH_WEIGHT), avg(SH_CHARGES)  
from shipment_details join status on shipment_details.SH_ID = status.SH_ID
group by Current_Status;

-- 13). LOOKING AT MEAN PAYMENT AMOUNT BASED ON SHIPPING DOMAIN WITH SERVICE TYPE EXPRESS
--     AND PAYMENT STATUS PAID
 select SH_DOMAIN, SER_TYPE, Payment_Status, avg(AMOUNT)
from payment_details join shipment_details on payment_details.SH_ID = shipment_details.SH_ID
where SER_TYPE = 'Express' and Payment_Status = 'PAID'
group by SH_DOMAIN;

-- 14). LET'S FIND SUM OF SHIPMENT CHARGES BASED ON PAYMENT_MODE WHERE SERVICE TYPE 
--     IS NOT REGULAR
select Payment_Mode, SER_TYPE, sum(SH_CHARGES), count(SER_TYPE) 
from payment_details join shipment_details on payment_details.SH_ID = shipment_details.SH_ID
where SER_TYPE != 'regular'
group by Payment_Mode;

-- 15). WE DISPLAY SH_ID, SHIPMENT STATUS, SHIPMENT_WEIGHT AND DELIVERY DATE WHERE SHIPMENT
--     WEIGHT IS OVER 1000 AND PAYMENT IS DONE IN QUARTER 3
select Payment_Date, SH_WEIGHT, shipment_details.SH_ID
from payment_details join shipment_details on payment_details.C_ID = shipment_details.C_ID 
where (Payment_Date like '____-07-__' or '____-08-__' or '____-07-__')
union
select shipment_details.SH_ID, Current_Status, Delivery_date
from shipment_details join status on shipment_details.SH_ID = status.SH_ID
where (SH_WEIGHT > 500); 

-- 16). LET US DISPLAY SH_ID, SH_CHARGES, SH_WEIGHT AND Sent_Date WHERE CURRENT_STATUS IS
--     NOT DELIVERED AND PAYMENT_MODE IS CARD_PAYMENT.
select shipment_details.SH_ID, SH_CHARGES, SH_WEIGHT, Sent_Date, Current_Status, Payment_Mode
from payment_details join shipment_details on payment_details.C_ID = shipment_details.C_ID
					 join status on shipment_details.SH_ID = status.SH_ID
where Current_Status = 'NOT DELIVERED' and Payment_Mode = 'CARD PAYMENT';  

-- 17). SELECTING ALL RECORDS FROM SHIPMENT DETAILS WHERE SHIPPING CHARGE IS GREATER THAN
--     AVERAGE SHIPPING CHARGE FOR ALL THE CUSTOMERS     
select * from shipment_details
where SH_CHARGES > (select avg(SH_CHARGES)
                    from shipment_details);
# BELOW IS SQL CODE FOR AVERAGE SHIPPING CHARGE FOR ALL THE CUSTOMERS WHICH IS 937.9700
# select avg(SH_CHARGES)

-- 18). LET'S FIND CUSTOMER NAMES, THEIR MAIL, CONTACT, C_TYPE AND PAYMENT AMOUNT
--      WHERE C_TYPE IS EITHER WHOLESALE OR RETAIL 
select C_NAME, C_EMAIL_ID, C_CONT_NO, C_TYPE, AMOUNT as Payment_Amount  
from customer join payment_details on customer.C_ID = payment_details.C_ID
where C_TYPE = 'Wholesale' or C_TYPE = 'Retail';

-- 19). OBSERVING EMP_ID, EMP_NAME, C_ID, SHIPPING CHARGES OF THE EMPLOYEES MANAGING CUSTOMERS
--      WHOSE SHIPPING CHARGES ARE OVER 1000.  
select E_ID as EMP_ID, E_NAME, E_DESIGNATION, C_ID, SH_CHARGES as SHIPPING_CHARGES
from employee_details join emp_managed_shipment 
on employee_details.E_ID = emp_managed_shipment.Employee_E_ID join shipment_details
on shipment_details.SH_ID = emp_managed_shipment.Shipment_Sh_ID
where SH_CHARGES > 1000; 

-- 20). FINDING  WHERE CUSTOMER'S PAYMENT AMOUNT WHERE IT IS GREATER THAN AVERAGE PAYMENT 
--      BY ALL OTHER CUSTOMERS
select amount, C_ID
from payment_details
where amount > (select avg(amount)
			    from payment_details);
               
-- 21). FIND EMPLOYEE BRANCH AND EMPLOYEE DESIGNATION WISE COUNT OF EMPLOYEES WHO
--      HAVE MANAGED CUSTOMERS WHOSE SHIPPING WEIGHT IS LESS THAN 500. 
--      DISPLAY THE RESULT IN DESCENDING ODER OF COUNT

select E_DESIGNATION, E_BRANCH, count(Employee_E_ID), SH_WEIGHT
from shipment_details join emp_managed_shipment 
on shipment_details.SH_ID = emp_managed_shipment.Shipment_Sh_ID 
join employee_details on emp_managed_shipment.Employee_E_ID=employee_details.E_ID
where SH_WEIGHT < 500
group by SH_CONTENT
order by count(Employee_E_ID) desc;

-- 22). FINDING SHIPPING CONTENT WISE COUNT OF EMPLOYEES FOR THE EMPLOYEES WHO HAVE MANAGED
--      CUSTOMERS WHERE SHIPPING DOMAIN IS INTERNATIONAL AND SHIPPING CHARGES ARE GREATER THAN 
--      THE AVERAGE SHIPPING CHARGES FOR ALL THE CUSTOMERS.
--      DISPLAY THE RESULT IN DESCENDING ORDER OF COUNT.
select round(avg(SH_CHARGES),2)  # AVERAGE SH_CHARGES IS 937.97 
from shipment_details;

select SH_CONTENT, count(Employee_E_ID), SH_CHARGES, avg(SH_CHARGES), SH_DOMAIN
from shipment_details join emp_managed_shipment 
on shipment_details.SH_ID = emp_managed_shipment.Shipment_Sh_ID
where SH_DOMAIN = 'International' and SH_CHARGES > (select avg(SH_CHARGES)  
                                                    from shipment_details)
group by SH_CONTENT
order by count(Employee_E_ID) desc;

-- 23). WRITE A QUERY (USING VIEW) DISPLAYING CUSTOMER NAME AND TYPE WHERE SHIPMENT WEIGHT 
--      IS GREATER THAN 500 AND SHIPMENT CHARGES ARE LESS THAN 1000.
create view view_L as select C_NAME, C_TYPE, SH_WEIGHT, SH_CHARGES
from customer join shipment_details on customer.C_ID = shipment_details.C_ID
where SH_WEIGHT >500 and SH_CHARGES <1000
group by C_NAME;

-- 24). USE VIEW TO SHOW TOP 5 BRANCHES HAVING THE MOST NUMBER OF EMPLOYEES. 
create view view_L1 as select E_BRANCH,count(E_ID)
from employee_details
group by  E_BRANCH
order by count(E_ID) desc
limit 5;

-- 25). HOW MANY ROW ENTRIES ARE THERE WITH ANY VALUE IN THE PAYMENT_DETAILS TABLE BEING 
--      NULL?
select concat(Payment_ID,C_ID,SH_ID,AMOUNT,Payment_Status,Payment_Mode,Payment_Date) 
as Entries
from payment_details
having Entries is null;
show columns from payment_details;
-- or
select count(*) from payment_details
where Payment_ID is null or C_ID is null or SH_ID is null or AMOUNT is null or 
Payment_Status is null or Payment_Mode is null or Payment_Date is null;



