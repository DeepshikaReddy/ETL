# This project focusses on  finding the effect of Temperature and Precipitation on Restaurant Sales and Review.(Tools:Snowflake,Powerbi)

#### Description : The restuarant dataset is fetched from (https://www.yelp.com/dataset/download) and the dataset for Temp/Prec observations are from the Global Historical Climatology Network-Daily (GHCN-D) database. As the datasets are from diffrent formats like json and so on, Snowflake made it  very easy to transform and load the data by creating File_formats, Staging, Pipes, Snowsql concepts directly into the table. The main object of the project was to load the data by following the star schema , find the correlation or effect of temperature on Restaurant reviews. The Data Analysis was done using Snowflake sql and Powerbi to get insights from the data. The Project also focusses on understanding key concepts in Snowflake like data loading, Resource Monitoring, Snowsql setup and usage, Streams, Role Management for Data Security, Transient Tables and many more. For Powerbi the concepts like connecting to Snowflake, Power Query Transformations, Visualizations and publishing the Dashboard were performed.

 #### Project Design
![plot](architecture.png)
#### Star Schema (Fact and Data Tables)
![plot](star_schema.png)
#### Table structure
![plot](Table_structure_snowflake.png)
#### Data Analysis(EDA)
**1. Powerbi Analysis**
1. There are lot of duplicate data so it will be removed in Power-query transformation.
2. Remove special characters from text field.
3. Display Max/Min Temperatures State and City Wise.
4. Top 5 Business having total review stars in descending order.
5. Top 10 Users who posted the Maximum Reviews
6. Time Series plot of Total Temperature by Date
7. Time Series plot of Total Precipitation by Date

**2. Snowflake Analysis**
1. Top 10 users who had maximum number of useful reviews as 1 for which business category .
![image](https://user-images.githubusercontent.com/82325528/202920631-14be6a59-29ff-4c21-90a5-ee28e9b8d319.png)
2. On which date temperature diffrence was maximum.
![image](https://user-images.githubusercontent.com/82325528/202920668-43b867e6-a3a8-4abb-b66b-b2208d5da6dd.png)
3. Fetch the top 5 dates with maximum temperature diffrence
![image](https://user-images.githubusercontent.com/82325528/202920711-693b23cd-530a-421e-b2e5-3cafb03997d7.png)
4. Get the business details where the temperature distance was maximum for 5 dates.
![image](https://user-images.githubusercontent.com/82325528/202920724-f99ea3a9-f853-4b00-b291-fa2b79c9efb2.png)
5. Which business cat got the highest star?
![image](https://user-images.githubusercontent.com/82325528/202920664-233719da-bff2-47e7-8d34-f21007b0c622.png)
6. Display review_stars,user_stars and business_star for each business based on desc order of user stars 

**Result:From the above analysis there is no pattern found for business stars based on temperature change and prec value which is 4.6 .It is higher than the average precipitation value.Even with high temperatures the business was open or there is no significant impact found.**
