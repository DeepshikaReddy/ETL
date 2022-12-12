# ETL

# Some of the Sql optimization to keep in mind:
1. Try to create dimension tables with integer as Primary key it makes the indexing faster.
2. Whenever the query has distinct its very slow , try converting the same into group by statement as it takes from the memory.
3. When creating the foreign keys in fact table use another existing field in dimension which is unique and use that to pull put the primary key in dimension table and insert the value .
4. Use temporary tables whenever possible when doing intermediate steps for data insertion.
5. Fact table (*) all foreign keys are here ; Dimension tables(1) only primary keys here.
