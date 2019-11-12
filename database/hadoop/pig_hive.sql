##########################################################################
--Pig >> delay execution.mapreduce is run only when you dump or store.
##########################################################################
-- LOAD
-- FILTER
-- GROUP BY
-- FLATTEN 
-- FOREACH GENERATE
-- CASE
-- STORE
-- EXPLAIN
-- DESCRIBE
-- LIMIT
-- SAMPLE
-- DUMP

--implicit schema
grades = LOAD 'grades/*' USING PigStorage('\t');
-- data type [int, long, float, double, chararray, bytarray, boolean,datatime, bigdecimal, biginteger]
agrades = FILTER grades by $4 =='A';
DUMP agrades;

-- explicit schema
grades = LOAD 'grades/*' USING PigStorage('\t') AS
	( 
	  year:int,
	  term:chararray,
	  course:chararray,
	  credits: int,
	  letter:chararray
	);
agrades = FILTER by letter=='A';
DUMP agrades;

-- specifying range in foreach
customer = LOAD 'data/customers';
F = FOREACH customer GENERATE $12..$23;  -- generate column from 12 to 23 in customer table --

-- demo
grades2 = FOREACH grades GENERATE course, credits,letter;
grade3 = FILTER grade2 BY letter =='B+' OR letter =='B';
EXPLAIN grade3;

-- Grouping and aggregates
letters = GROUP grades by letter;
DESCRIBE letters;
-- rename the column
letter_rename = FOREACH letters GENERATE group AS letter; [rename group to letter]
DESCRIBE letter_rename;

letter_count = FOREACH letter_rename GENERATE letter, COUNT(grades.letter) as count, sum(grades.credits) as total_tcredits;
DUMP letter_count;


-- ORDER BY Operator & CASE Operator
salaries = LOAD 'data/salary' USING PigStorage(',') AS (gender:chaearray, age:int, salary:float, zip:chararray)
bonuses = FOREACH salaries GENERATE salary, (
		CASE
			WHEN salary >= 70000.0 THEN salary * 0.10
			WHEN salary < 70000 AND salary >= 300000 THEN salary * .50
			WHEN salary < 30000.0 THEN 0.0
			END) AS bonus;
bonuses_order = ORDER bonuses by bonus ASC;

-- PARALLEL can be used with element with reducer in its operation.



-- STORE
STORE grades INTO '/user/cloudera/grades' USING PigStorage(',');


--Hcatalogue with pig
empl_relation = LOAD 'employee' USING org.apache.hive.hcatalogue.pig.HCatLoader();


##############################################################################
--Hive
##############################################################################
-- run sql like query on hdfs. data is stored in hdfs.
-- hive client
beeline
beeline -u url -n username -p password

-- connecting using the beeline client
beeline -u jdbc:hive2://localhost:1000/default -u cloudera -p cloudera -silent=true;

show databases;

-- internal and external table can be created in hive.
CREATE TABLE customer (
		customer_id INT,
		first_name STRING,
		last_name STRING,
		birthday TIMESTAMP
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

--load data 
LOAD DATA LOCAL INPATH '/tmp/customer.csv' OVERWRITE INTO TABLE customers;
or
LOAD DATA INPATH '/user/cloudera/customer.csv' OVERWRITE INTO TABLE customers;

-- External Table
CREATE EXTERNAL TABLE salaries (
		gender STRING,
		age INT,
		salary DOUBLE,
		zip int
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/path/to/hdfs/';

-- droping an internal table will delete the data from the hdfs.

-- checkinternal table in hdfs
hadoop fs -ls '/user/hive/warehouse/'

-- Query Hive
-- Bucket table
CREATE TABLE customers (
	id int,
	username string,
	zip int
)
CLUSTERED BY (zip) INTO 5 BUCKETS;


-- SET hive.exec.dynamic.partition=true;


-- Storage format
CREATE TABLE latest_customer 
	STORE AS AVRO | ORC | PARQUET | JSONFILE
AS SELECT * FROM customers 
	WHERE reg_year=2018;


-- Using HCatStorer with pig
STORE customer_projection INTO 'customers' USING org.apache.hive.hcatalog.pig.HCatStorer();























