drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date);
INSERT INTO goldusers_signup(userid,gold_signup_date)
values(1,'09-30-2022'),(2,'04-21-2022'),(3,'10-25-2022');
drop table if exists users;
CREATE TABLE users(userid integer,signup_date date);
INSERT INTO users(userid,signup_date)
VALUES(1,'12-12-2022'),(2,'03-23-2022'),(3,'06-30-2022');
drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date, product_id integer);
INSERT INTO sales(userid,created_date,product_id)
VALUES (1,'04-19-2022',2),
(3,'12-18-2021',1),
(2,'07-20-2020',3),
(1,'10-23-2022',2),
(1,'03-19-2021',3),
(3,'12-20-2020',2),
(1,'11-09-2021',1),
(1,'05-20-2018',3),
(2,'09-24-2022',1),
(1,'03-11-2019',2),
(1,'03-11-2018',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'non vegthali',980),
(2,'veg thali',870),
(3,'empty',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;



 ---- what is total amount each customer spent on zomato ?

select a.userid,sum(b.price) total_amt_spent from sales a inner join product b on a.product_id=b.product_id
group by a.userid


 ---- How many days has each customer visited zomato?

select userid,count(distinct created_date) distinct_days
from sales 
group by userid;


 --- what was the first product purchased by each customer?

select * from
(select*,rank() over (partition by userid order by created_date ) rnk from sales) a where rnk = 1


--- what is most purchased item on menu & how many times was it purchased by all customers ?

select userid,count(product_id) cnt from sales where product_id =
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid


 ---- which item was most popular for each customer?

select * from
(select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid,product_id)a)b
where rnk =1


 --- which item was purchased first by customer after they become a member ?

select * from
(select c.*,rank() over (partition by userid order by created_date ) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date) c)d where rnk=1;


 --- which item was purchased just before customer became a member?

select * from
(select c.*,rank() over (partition by userid order by created_date desc ) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c)d where rnk=1;


 ---- what is total orders and amount spent for each member before they become a member ?

select userid,count(created_date) order_purchased,sum(price) total_amt_spent from
(select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c inner join product d on c.product_id=d.product_id)e
group by userid;

