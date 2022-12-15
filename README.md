# ETL
1.Snowflake.
2.Altteryx.
3.Power Query.
4.Python.

# Some of the Sql optimization to keep in mind:
1. Try to create dimension tables with integer as Primary key it makes the indexing faster.
2. Whenever the query has distinct its very slow , try converting the same into group by statement as it takes from the memory.
3. When creating the foreign keys in fact table use another existing field in dimension which is unique and use that to pull put the primary key in dimension table and insert the value .
4. Use temporary tables whenever possible when doing intermediate steps for data insertion.
5. Fact table (*) all foreign keys are here ; Dimension tables(1) only primary keys here.
6.	Make sure to use the datatype of field depending on the nature of the field .(ie.When defining columns that contain dates or timestamps, Snowflake and Synapse recommends choosing date/datetime field which stores more efficiently than the VARCHAR types which results in better query performance)
7.	When Creating the table , keep the length of the maximum value in the data-type only.(i.e. For Values ‘product’ in the field the datatype might be VARCHAR(7)).
8.	Clustered column store is the default storage method and the fastest one for large tables.
9.	Make use of partitioning for large tables .This helps in data management and faster query retrieval.
10.	Snowflake recommends using foreign key constraints when creating tables as constraints creates valuable metadata and makes team members familiar with the  schema and easily build queries. When integrating the warehouse with BI , it can easily build proper join conditions at the destination.
11.	Synapse sql pool doesn't support Foreign key constraint . Unique and Primary key constraints are only supported.
12.	Use of Primary keys as Numeric values which uses less space than other data types, auto-populate options are also available.
13.	In order to populate the Dimension table , the unique records where fetched using Distinct keyword which increased the query time as it was sorting the output rows to find duplicates and doesn't work for large tables. The workaround for the same was by using group by and query ran faster. 
14.	Better approach than Group by was to get the relevant data into temp tables and then do operations.
15.	Don’t perform Select * on the columns . Instead select only required columns for faster query retrieval.
16.	If we use the same queries multiple times in future, create Materialized Views. A materialized view pre-computes, stores, and maintains its data in a dedicated SQL pool like a table. There's no recomputation needed each time a materialized view is used. That's why queries that use all or a subset of the data in materialized views can get faster performance.

