**Synapse table architecture Speed**

![image](https://user-images.githubusercontent.com/82325528/205367388-8c3ab4ef-199f-4044-a08d-0fc7ddd19c3b.png)
![image](https://user-images.githubusercontent.com/82325528/205367418-6bd5096b-d14b-42a6-a8ca-1b930e19bd45.png)

**Snowflake Speed**

![image](https://user-images.githubusercontent.com/82325528/205367551-1cc6d9b0-a772-4281-adb4-47799cd8c461.png)

**Analysis**
Clearly for 1 million rows querying, snowflake is much faster than synapse as it returns the results less than 1 second. If the Snowflake table is further indexed it will be much faster.

