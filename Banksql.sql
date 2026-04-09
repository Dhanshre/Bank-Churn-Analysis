use bank;
# 1.What is the distribution of account balance across different regions?
select GeographyLocation,round(sum(Balance),2) as balance from bank_churn b
join customerinfo c 
on b.customerid=c.customerid
 join geography g 
 on c.geographyid=g.geographyid
group by 1;

#Deriving a new date of joining column as the earlier one was in string format
ALTER TABLE customerinfo ADD DOJ DATE;
UPDATE customerinfo
SET DOJ = STR_TO_DATE(Bank_DOJ, '%d-%m-%Y');

#calculating a date column in bank_churn using tenure and doj
Alter table bank_churn ADD churndate Date;
UPDATE bank_churn y
INNER JOIN customerinfo c 
ON y.customerid = c.customerid
SET y.churndate = DATE_ADD(c.DOJ, INTERVAL y.Tenure YEAR);

#verifying the date
select doj,tenure,churndate from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
limit 10;


#Q1. What is the distribution of account balance across different regions?
select geographylocation,round(avg(balance),2) as avg_balance from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
join geography c
on b.geographyid=c.geographyid
group by 1;


#2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
select a.customerid,estimatedsalary from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
where month(churndate) in (10,11,12)
order by estimatedsalary desc
limit 5;



#3. Calculate the average number of products used by customers who have a credit card. (SQL)
select HasCrCard,avg(NumOfProducts) as avg_prdcts from bank_churn
where HasCrCard=1;

#4. Determine the churn rate by gender for the most recent year in the dataset.
select gendercategory,round((count(exited)*100/(select count(customerid) from bank_churn)),2) as churn_rate from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
join gender g 
on g.genderid=b.genderid
where exited=1
and year(churndate)=2023
group by 1;

#5. Compare the average credit score of customers who have exited and those who remain. (SQL)
select ExitCategory,avg(creditscore) from bank_churn a 
join exitcustomer b 
on a.exited=b.exitid
group by 1;

#6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
select gendercategory,activecategory,round(avg(estimatedsalary)) as avg_sal from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
join activecustomer c 
on a.isactivemember=c.activeid
join gender g 
on g.genderid=b.genderid
group by 1,2
limit 4;

#7. Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
select max(creditscore),avg(creditscore),min(creditscore) from bank_churn;
select case when creditscore between 350 and 550 then 'LowCScore'
when creditscore between 551 and 700 then 'AverageCScore'
else 'HighCScore' end as Ccategory,count(customerid) from bank_churn
group by 1;

select count(Exited) from bank_churn
where creditscore between 350 and 550;
select "AverageCScore",count(Exited) from bank_churn
where creditscore between 551 and 700;
select count(Exited) from bank_churn
where creditscore >700;

#8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
select geographylocation,count(a.customerid) as tot_customers from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
join geography g 
on g.geographyid=b.geographyid
where isactivemember=1
group by 1
order by 2 desc;

#9. What is the impact of having a credit card on customer churn, based on the available data?
select c.category,count(customerid) from bank_churn b 
join creditcard c 
on b.hascrcard=c.creditid
where exited=1
group by 1;

#10. For customers who have exited, what is the most common number of products they have used?
select "exited",round(avg(numofproducts)) as no_of_products from bank_churn
where exited=1;

#11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). 
    -- Prepare the data through SQL and then visualize it.
    select year(doj),month(doj),count(customerid) from customerinfo
    group by 1,2
    order by 1,2;
    
#12. Analyze the relationship between the number of products and the account balance for customers who have exited.
select numofproducts,count(customerid),round(avg(balance),2) as balance from bank_churn
where exited=1
group by 1;

#13. Identify any potential outliers in terms of balance among customers who have remained with the bank.
-- Done in Power BI
#14. How many different tables are given in the dataset, out of these tables which table only consists of categorical variables?
-- There are total 7 tables in the dataset,out of which 5 tables have categorical data which are
-- activecustomer,creditcard,exitcustomer,gender,geography.


#15. Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
--  Also, rank the gender according to the average value. (SQL)

with a as(select geographylocation as location,gendercategory as gender,round(avg(estimatedsalary),2) as avg_salary from customerinfo a 
join gender b on a.genderid=b.genderid
join geography c on a.geographyid=c.geographyid
group by 1,2)
select *,rank() over(order by avg_salary desc) as ranks from a;

#16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket 
-- (18-30, 30-50, 50+).

select case when age between 18 and 30 then "18-30"
when age between 30 and 50 then "30-50"
else "50+" end as age_category,round(avg(tenure),2) as avg_tenure from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
where exited=1
group by 1;

#17. Is there any direct correlation between salary and the balance of the customers? 
-- And is it different for people who have exited or not?
select min(estimatedsalary),max(estimatedsalary),round(avg(estimatedsalary),2) from customerinfo;
select case when estimatedsalary between 11.58 and 100090 then 'low' else 'high' end as sal_range,
round(avg(balance)) as avg_balance,exitcategory from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
join exitcustomer c 
on a.exited=c.exitid
group by 1,3; 

#18. Is there any correlation between the salary and the Credit score of customers?
select case when creditscore between 350 and 450 then 'LowCScore'
when creditscore between 451 and 600 then 'AverageCScore'
else 'HighCScore' end as Ccategory,round(avg(estimatedsalary)) as salary from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
group by 1
order by 2 desc;

#19. Rank each bucket of credit score as per the number of customers who have churned the bank.
with a as(select case when creditscore between 350 and 450 then 'LowCScore'
when creditscore between 451 and 600 then 'AverageCScore'
else 'HighCScore' end as Ccategory,count(a.customerid) as cust_count from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
where exited=1
group by 1
order by 2 desc)

select *,rank() over(order by cust_count desc) as ranks from a;

#20. According to the age buckets find the number of customers who have a credit card.
--  Also retrieve those buckets that have lesser than average number of credit cards per bucket.

with a as(select case when age between 18 and 30 then "18-30"
when age between 30 and 50 then "30-50"
else "50+" end as age_category,count(a.customerid) as cust_count_havingCRcard from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
where hascrcard=1
group by 1
order by 2 desc),

b as (select age_category,cust_count_havingCRcard,avg(cust_count_havingCRcard) over() as avg_number from a)

select * from b
where cust_count_havingCRcard<avg_number;

#21. Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
with temp as(select geographylocation as location,count(a.customerid) as exited_cust_count,round(avg(balance),2) as avg_balance from customerinfo a 
join bank_churn b 
on a.customerid=b.customerid
join geography c on a.geographyid=c.geographyid
where exited=1
group by 1)
select *,rank() over(order by exited_cust_count desc,avg_balance desc) as ranks from temp;

#22. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now 
-- if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, 
-- come up with a column where the format is “CustomerID_Surname”.
alter table customerinfo
add column fullname text;
UPDATE CustomerInfo
SET fullname = CONCAT(customerid, '_', surname);
select customerid,surname,fullname from customerinfo;

#23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table?
--   If yes do this using SQL
select a.customerid,exited,(select b.exitcategory from exitcustomer b where a.exited=b.exitid) as exitcategory from 
bank_churn a;

#24. Were there any missing values in the data, using which tool did you replace them and what are the ways to handle them?

select customerid from bank_churn
where creditscore is null or tenure is null or balance is null or numofproducts is null or hascrcard is null
or isactivemember is null or exited is null or churndate is null;
                #no missing values
                
#25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers
-- whose surname ends with “on”.
select distinct(a.customerid),b.surname,
(select activecategory from activecustomer where a.isactivemember = activeid limit 1) as active_category
from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
where surname like '%on';

#***************                        SUBJECTIVE QUESTION                        *****************
#9.  Utilize SQL queries to segment customers based on demographics and account details.

select case when age between 18 and 30 then "18-30"
when age between 30 and 50 then "30-50"
else "50+" end as age_category,
case when creditscore between 350 and 450 then 'LowCScore'
when creditscore between 451 and 600 then 'AverageCScore'
else 'HighCScore' end as Ccategory,
case when balance between 0 and 84000 then 'Lowbalance'
when creditscore between 84001 and 170000 then 'Averagebalance'
else 'Highbalance' end as balance
,geographylocation,exitcategory,gendercategory,
count(a.customerid) as cust_count from bank_churn a 
join customerinfo b 
on a.customerid=b.customerid
join geography g 
on g.geographyid=b.geographyid
join exitcustomer e
on e.exitid=a.exited
join gender r 
on r.genderid=b.genderid
group by 1,2,3,4,5,6
order by 7 desc;





















