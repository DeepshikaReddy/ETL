create or replace database db_snowflake;
create or replace schema db_schema;

-------------------------------------------------------Precipitation Data Loading-------------------------------------------------------------------------------------------------------------
create or replace file format my_csv_format
    type=csv
    skip_header=1
    null_if=('NULL','null')
    empty_field_as_null=true;
    
create or replace stage my_stage
  file_format = my_csv_format;
  
create or replace table prec(
date string,
precipitation string,
precipitation_normal string);

--snowsql -a xxx.west-us-2.azure -u xxx123
--put file:///C:/Users/deeps/OneDrive/Documents/dataset_snowflake/precipitation.csv @db_snowflake.db_schema.my_stage/;
copy into prec
from @my_stage
on_error=continue;

--transform data while loading.
copy into Synthetic_Data(Name,Email,Phone,Financial_Status,Paid_at,Fulfillment_Status,Accepts_Marketing ,Currency ,
Subtotal ,Shipping ,Taxes ,Discount_Amount ,Total ,Discount_code,Shipping_Method ,Lineitem_quantity ,Lineitem_price ,
Lineitem_total_price ,Lineitem_compare_at_price ,Lineitem_sku ,Lineitem_requires_shipping ,Lineitem_fulfillment_status ,
Billing_Name,Billing_Street ,Billing_Address1 ,Billing_Addresss2 ,Billing_City ,Billing_Zip ,Billing_State ,
Billing_Country ,Shipping_Name ,Shipping_Street,Shipping_Address1,Shipping_Addresss2 ,
Shipping_City ,Shipping_Zip ,Shipping_State ,Shipping_Country,Payment_Method ,ID 
,Year_from_Paid_at )--41
   from (select t.$1,t.$2,t.$3,t.$4,to_timestamp_ntz(t.$5,'MM/DD/YYYY HH24:MI'),t.$6,
         t.$7,t.$8,t.$9,t.$10,t.$11,t.$12,t.$13,
         t.$14,t.$15,t.$16,t.$17,t.$18,t.$19,
         t.$20,t.$21,t.$22,t.$23,t.$24,t.$25,t.$26,t.$27,t.$28,t.$29,t.$30,t.$31,
         t.$32,t.$33,t.$34,t.$35,t.$36,t.$37,t.$38,t.$39,t.$40,(substring(split(t.$5,' ')[0],-4)) from @my_stage t)
   file_format = (format_name = my_csv_format);
   
update prec set date= TO_DATE(date, 'YYYYMMDD');


select count(*) from prec;

--------------------------------------------------------------Temp table loading----------------------------------------------------------------------------------------------------------------------------

create or replace table temp_change(
    date string,
    min_val int,
    max_val int,
    normal_min float,
    normal_max float
);

    
create or replace stage my_stage_temp
  file_format = my_csv_format;
  
--put file:///C:/Users/deeps/OneDrive/Documents/dataset_snowflake/temp_change.csv @db_snowflake.db_schema.my_stage_temp/;

copy into temp_change
from @my_stage_temp
on_error=continue;

update temp_change set date= TO_DATE(date, 'YYYYMMDD');

select count(*) from temp_change;

--------------------------------------------------------Business table loading.-------------------------------------------------------------------------------------------------------------------------------
create or replace file format my_json_format
type = 'json'
strip_outer_array = true;

create or replace stage json_buss_int_stage
file_format = my_json_format;

--put file:///C:/Users/deeps/OneDrive/Documents/dataset_snowflake/yelp_academic_dataset_business.json @db_snowflake.db_schema.json_buss_int_stage/;

create or replace table business_data(
business_id varchar,
name varchar,
address varchar,
city varchar,
state varchar,
postal_code varchar,
latitude float,
longitude float,
stars float,
review_count int,
is_open int,
attributes OBJECT,
categories varchar,
hours variant);

insert into business_data(business_id ,
name ,
address ,
city ,
state ,
postal_code ,
latitude ,
longitude ,
stars ,
review_count ,
is_open ,
attributes ,
categories ,
hours)
select 
parse_json($1):business_id,
parse_json($1):name ,
parse_json($1):address ,
parse_json($1):city ,
parse_json($1):state ,
parse_json($1):postal_code ,
parse_json($1):latitude ,
parse_json($1):longitude ,
parse_json($1):stars ,
parse_json($1):review_count ,
parse_json($1):is_open ,
parse_json($1):attributes ,
parse_json($1):categories ,
parse_json($1):hours
from @json_buss_int_stage;

select * from business_data limit 10;

--------------------------------------------------------------Checkin data Loading-----------------------------------------------------------------------------------------------------------------------------------------------
create or replace stage json_checkin_int_stage
file_format = my_json_format;

--put file:///C:/Users/deeps/OneDrive/Documents/dataset_snowflake/yelp_academic_dataset_checkin.json @db_snowflake.db_schema.json_checkin_int_stage/;

create or replace table checkin_data(
business_id varchar,
date string);

--select * from @json_checkin_int_stage;
INSERT INTO checkin_data(business_id, date)
SELECT parse_json($1):business_id,
		parse_json($1):date 
		FROM @json_checkin_int_stage;

select * from checkin_data limit 10;

---------------------------------------------------------------Review data Loading-------------------------------------------------------------------------------------------------------------------------------------
create or replace stage json_review_int_stage
file_format = my_json_format;

--put file:///C:/Users/deeps/OneDrive/Documents/dataset_snowflake/yelp_academic_dataset_review.json @db_snowflake.db_schema.json_review_int_stage/;

select * from @json_review_int_stage;

create or replace table review_data(
review_id varchar,
user_id varchar,
business_id varchar,
stars float,
useful number,
funny number,
cool number,
text varchar,
date string);

INSERT INTO review_data(review_id ,user_id ,business_id,stars,useful,funny,cool,text,date)
SELECT parse_json($1):review_id,
    parse_json($1):user_id,
    parse_json($1):business_id ,
    parse_json($1):stars, 
    parse_json($1):useful, 
    parse_json($1):funny, 
    parse_json($1):cool ,
    parse_json($1):text ,
    parse_json($1):date FROM @json_review_int_stage;
    
    select * from review_data limit 10;

---------------------------------------------------------Tip data loading----------------------------------------------------------------------------------------------------------------------
create or replace stage json_tip_int_stage
file_format = my_json_format;

--put file:///C:/Users/deeps/OneDrive/Documents/dataset_snowflake/yelp_academic_dataset_tip.json @db_snowflake.db_schema.json_tip_int_stage/;

select * from @json_tip_int_stage;

create or replace table tip_data(
user_id varchar,
business_id varchar,
text varchar,
date varchar,
compliment_count number);


INSERT INTO tip_data(user_id ,
business_id ,
text ,
date ,
compliment_count )
SELECT parse_json($1):user_id ,
       parse_json($1):business_id ,
       parse_json($1):text ,
       parse_json($1):date ,
       parse_json($1):compliment_count 
	   FROM @json_tip_int_stage;
       
select * from tip_data limit 10;

-------------------------------------------------------------USER Data Loading------------------------------------------------------------------------------------------------------------------------
create or replace stage json_user_int_stage
file_format = my_json_format;

create or replace table user_data(
user_id varchar,
name varchar,
review_count number,
yelping_since varchar,
useful number,
funny number,
cool number,
elite varchar,
friends varchar,
fans number,
average_stars float,
compliment_hot number,
compliment_more number,
compliment_profile number,
compliment_cute number,
compliment_list number,
compliment_note number,
compliment_plain number,
compliment_cool number,
compliment_funny number,
compliment_writer number,
compliment_photos number);

--put file:///C:/Users/deeps/OneDrive/Documents/dataset_snowflake/yelp_academic_dataset_user.json @db_snowflake.db_schema.json_user_int_stage/;

select * from @json_user_int_stage;

INSERT INTO user_data(user_id ,name ,review_count,yelping_since ,useful ,funny ,cool ,elite ,friends ,fans,average_stars ,compliment_hot ,compliment_more ,compliment_profile ,compliment_cute ,compliment_list ,compliment_note ,compliment_plain ,compliment_cool ,compliment_funny ,compliment_writer ,
compliment_photos )
SELECT parse_json($1):user_id ,
       parse_json($1):name ,
       parse_json($1):review_count,
       parse_json($1):yelping_since ,
       parse_json($1):useful ,
       parse_json($1):funny ,
       parse_json($1):cool ,
       parse_json($1):elite ,
       parse_json($1):friends ,
       parse_json($1):fans,
       parse_json($1):average_stars ,
       parse_json($1):compliment_hot ,
       parse_json($1):compliment_more ,
       parse_json($1):compliment_profile ,
       parse_json($1):compliment_cute ,
       parse_json($1):compliment_list ,
       parse_json($1):compliment_note ,
       parse_json($1):compliment_plain ,
       parse_json($1):compliment_cool ,
       parse_json($1):compliment_funny ,
       parse_json($1):compliment_writer ,
       parse_json($1):compliment_photos  
	   FROM @json_user_int_stage;
       
       select count(*) from user_data;
   
       -------------------------------------------Combine Business and Temperature data through Date-----------------------------------------------------------------------------------------
       select u.user_id as user_id,b.state as business_date,b.address as business_address,b.latitude,b.longitude, b.name as business_name,r.useful as useful_review,substring(r.date, 0, 10) as review_date,r.text as review_text,
       t.min_val as min_temp,t.normal_min,t.normal_max, t.max_val as max_temp,tips.text as tips_text, tips.compliment_count as compliment_count,p.precipitation,p.precipitation_normal from prec as p
       join review_data as r
       on substring(r.date, 0, 10) = p.date
       join temp_change as t
       on t.date =substring(r.date, 0, 10)
       join business_data as b
       on b.business_id=r.business_id
       join checkin_data as ch 
       on b.business_id=ch.business_id
       join tip_data as tips
       on b.business_id=tips.business_id
       join user_data as u
       on u.user_id=r.user_id;
       
       --query all joined data---
       select b.*,r.*,t.*,ch.*,tips.*,u.*  from prec as p
       join review_data as r
       on substring(r.date, 0, 10) = p.date
       join temp_change as t
       on t.date =substring(r.date, 0, 10)
       join business_data as b
       on b.business_id=r.business_id
       join checkin_data as ch 
       on b.business_id=ch.business_id
       join tip_data as tips
       on b.business_id=tips.business_id
       join user_data as u
       on u.user_id=r.user_id limit 10;
       
       
       -------------------------------------------------------Columns required for Analysis---------------------------------------------------------------------------------------------------------
       select count(*) from combined_fact_table;--329061051
       
       select count(distinct tips_text) from combined_fact_table;--845665
       
       select * from business_data limit 10; --BUSINESS_ID,NAME,ADDRESS,CITY,STATE,POSTAL_CODE,LATITUDE,LONGITUDE,STARS,REVIEW_COUNT,IS_OPEN,ATTRIBUTES,CATEGORIES,HOURS
       
       select * from checkin_data limit 10; --date
       
       select * from tip_data limit 10; --text,compliment_count
       
       select * from user_data limit 10;--name,review_count,averge_stars,useful
       
       select * from review_data limit 10;--stars,useful,text,date
       
       select * from prec limit 10;--date,precipitation,precipitation_normal
       
       select * from temp_change limit 10;--date,min_val,max_val,normal_min,normal_max
       
       -------------------------------------------------------Final fact table-----------------------------------------------------------------------------------------------------------------------------------
       select   
       b.business_id as bus_id,b.name as bus_name,b.address as bus_addr,b.city as bus_city,b.state as bus_state,
       b.postal_code as bus_post_code,b.latitude as bus_lat,b.longitude as bus_long,b.stars as bus_stars,
       b.review_count as bus_num_reviews,b.is_open as bus_open,
       b.attributes as bus_sttr,b.categories as bus_cat,b.hours as bus_hours,p.date as prec_date,
       p.precipitation as prec,p.precipitation_normal as prec_normal,t.date as temp_date,t.min_val as temp_min,
       t.max_val as  temp_max,
       t.normal_min as temp_norm_min,t.normal_max as temp_norm_max,ch.date as checkin_date,
       tips.text as tip_content,tips.compliment_count as tip_complimentcount,u.name as username,
       u.review_count as user_reviews,u.useful as user_review_useful,u.average_stars as user_avg_stars,
       r.stars as review_stars,r.useful as review_useful,r.text as review_text,r.date as review_date
       from prec as p
       join review_data as r
       on substring(r.date, 0, 10) = p.date
       join temp_change as t
       on t.date =substring(r.date, 0, 10)
       join business_data as b
       on b.business_id=r.business_id
       join checkin_data as ch 
       on b.business_id=ch.business_id
       join tip_data as tips
       on b.business_id=tips.business_id
       join user_data as u
       on u.user_id=r.user_id  limit 5;
       
       create or replace TRANSIENT table fact_table as select   
       b.business_id as bus_id,b.name as bus_name,b.address as bus_addr,b.city as bus_city,b.state as bus_state,
       b.postal_code as bus_post_code,b.latitude as bus_lat,b.longitude as bus_long,b.stars as bus_stars,
       b.review_count as bus_num_reviews,b.is_open as bus_open,
       b.attributes as bus_sttr,b.categories as bus_cat,b.hours as bus_hours,p.date as prec_date,
       p.precipitation as prec,p.precipitation_normal as prec_normal,t.date as temp_date,t.min_val as temp_min,
       t.max_val as  temp_max,
       t.normal_min as temp_norm_min,t.normal_max as temp_norm_max,ch.date as checkin_date,
       tips.text as tip_content,tips.compliment_count as tip_complimentcount,u.name as username,
       u.review_count as user_reviews,u.useful as user_review_useful,u.average_stars as user_avg_stars,
       r.stars as review_stars,r.useful as review_useful,r.text as review_text,r.date as review_date
       from prec as p
       join review_data as r
       on substring(r.date, 0, 10) = p.date
       join temp_change as t
       on t.date =substring(r.date, 0, 10)
       join business_data as b
       on b.business_id=r.business_id
       join checkin_data as ch 
       on b.business_id=ch.business_id
       join tip_data as tips
       on b.business_id=tips.business_id
       join user_data as u
       on u.user_id=r.user_id ;
       
       update combined_fact_table set review_text=REPLACE(review_text, ',', ' '),tips_text=REPLACE(tips_text, ',', ' ');
       update combined_fact_table set tips_text=REPLACE(tips_text, '\n', ' ');
      
       create or replace file format my_csv_unload_format
       TYPE = 'CSV'
       COMPRESSION = 'NONE'--else gives data ingz format.
       field_optionally_enclosed_by=NONE
       EMPTY_FIELD_AS_NULL=False
       ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE

       create or replace stage my_unload_stage_fin
       file_format = my_csv_unload_format;
       
       COPY INTO @my_unload_stage_fin from combined_fact_table HEADER = TRUE;
       
       --get @my_unload_stage_fin file://C:/Users/deeps/OneDrive/Documents/dataset_snowflake/;
       
       --truncate table combined_fact_table;
       
       SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17 FROM @my_unload_stage_test_fin;
       
       ------------------------------------------------SNOWFLAKE DATA ANALYSIS---------------------------------------------------------------------------------------------------
       
       --Top 10 users who had maximum number of useful reviews as 1 for which business category .
       select username,count(review_useful) as useful_review_count from fact_table 
       where review_useful=1 group by username,bus_cat
       order by useful_review_count desc limit 10;
       
       --On which date temperature diffrence was maximum.
       select sum(temp_min) as sum_min,sum(temp_norm_min) as sum_norm_min,
       abs(sum_min-sum_norm_min) as diffrence_temp,temp_date from fact_table 
       group by temp_date having diffrence_temp is not null
       order by diffrence_temp desc;
       
       --Get the top 5 dates with maximum temperature diffrence
       select temp_date from fact_table 
       group by temp_date having abs(sum(temp_min)-sum(temp_norm_min)) is not null
       order by abs(sum(temp_min)-sum(temp_norm_min)) desc limit 5;
       
       --Get the business details where the temperature distance was maximum for 5 dates.
       select temp_date,bus_stars,bus_open,bus_sttr['Alcohol'],bus_cat,prec 
       from fact_table where temp_date in (select temp_date from fact_table 
       group by temp_date having abs(sum(temp_min)-sum(temp_norm_min)) is not null
       order by abs(sum(temp_min)-sum(temp_norm_min)) desc limit 5)
       order by temp_date desc;
       
       select min(prec),max(prec),avg(prec) from fact_table where prec<>'T';
       
       --From the above analysis there is no pattern found for business stars based on temperature change 
       --and prec value is 4.6  itself which is higher then average precipitation.Even with high
       --temperatures the business was open.
       
       --Which business category got the highest star 
       select * from test;
       select bus_cat,bus_stars from fact_table where bus_stars in (select max(bus_stars) 
       from fact_table) group by bus_cat,bus_stars ;
      
      --Display review_stars,user_stars and business_star for each business based on desc order of user stars 
       select * from test;
       select BUS_NAME, USER_AVG_STARS,BUS_STARS,review_stars, row_number()
        over (order by USER_AVG_STARS desc) as index
        from fact_table;
   
