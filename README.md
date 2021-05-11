# Apache Spark SQL for Cassandra Data Operations
In this walkthrough, we will cover how we can use Spark SQL to do Cassandra Data Operations. We will be using Spark Shell instead of the Spark SQL Shell due to the amount logs that come with a command in the Spark SQL Shell. We will also be using the [Catalog](https://github.com/datastax/spark-cassandra-connector/blob/6a213676caf3323333753752600b5551a69845d5/doc/1_connecting.md#configuring-catalogs-to-cassandra) method from [DataStax's Spark Cassandra Connector](https://github.com/datastax/spark-cassandra-connector). 

## Prerequisites
- Docker
- Spark 3.0.X

## 1. Setup Dockerized Apache Cassandra

### 1.1 - Clone repo and cd into it
```bash
git clone https://github.com/Anant/example-cassandra-spark-sql.git
```

```bash
cd example-cassandra-spark-sql
```

### 1.2 - Start Apache Cassandra Container and Mount Directory
```bash
docker run --name cassandra -p 9042:9042 -d -v "$(pwd)":/example-cassandra-spark-sql cassandra:latest
```

### 1.3 - Run `cqlsh`
```bash
docker exec -it cassandra cqlsh
```

### 1.4 - Run `setup.cql`
```bash
source '/example-cassandra-spark-sql/setup.cql'
```

## 2. Start Spark Shell

### 2.1 - Navigate to Spark directory and start in standalone cluster mode
```bash
./sbin/start-master.sh
```

### 2.2 - Start worker and point it at the master
You can find your Spark master URL at `localhost:8080`
```bash
./sbin/start-slave.sh <master-url>
```

### 2.3 - Start Spark Shell
```bash
./bin/spark-shell --packages com.datastax.spark:spark-cassandra-connector_2.12:3.0.0 \
--master <spark-master-url> \
--conf spark.cassandra.connection.host=127.0.0.1 \
--conf spark.cassandra.connection.port=9042 \
--conf spark.sql.extensions=com.datastax.spark.connector.CassandraSparkExtensions \
--conf spark.sql.catalog.cassandra=com.datastax.spark.connector.datasource.CassandraCatalog
```

## 3. Basic Cassandra Schema Commands
We will cover some basic Cassandra Schema commands we can do with Spark SQL. More can this can be found [here](https://github.com/datastax/spark-cassandra-connector/blob/42937e1ed01dd5aefb37fea38dbafc49ed44250e/doc/14_data_frames.md#supported-schema-commands)

### 3.1 - Create Table
```bash
spark.sql("CREATE TABLE cassandra.demo.testTable (key_1 Int, key_2 Int, key_3 Int, cc1 STRING, cc2 String, cc3 String, value String) USING cassandra PARTITIONED BY (key_1, key_2, key_3) TBLPROPERTIES (clustering_key='cc1.asc, cc2.desc, cc3.asc', compaction='{class=SizeTieredCompactionStrategy,bucket_high=1001}')")
```

### 3.2 - Alter Table
```bash
spark.sql("ALTER TABLE cassandra.demo.testTable ADD COLUMNS (newCol INT)")
```
```bash
spark.sql("describe table cassandra.demo.testTable").show
```

### 3.3 - Drop Table
```bash
spark.sql("DROP TABLE cassandra.demo.testTable")
```
```bash
spark.sql("SHOW TABLES from cassandra.demo").show
```

## 4. Basic Cassandra Data Operations with Spark SQL (Cassandra to Cassandra)

### 4.1 - Read
Perform a basic read
```bash
spark.sql("SELECT * from cassandra.demo.previous_employees_by_job_title").show
```

### 4.2 - Write
Write data to a table from another table and use SQL functions
```bash
spark.sql("INSERT INTO cassandra.demo.days_worked_by_previous_employees_by_job_title SELECT job_title, employee_id, employee_name, abs(datediff(last_day, first_day)) as number_of_days_worked from cassandra.demo.previous_employees_by_job_title")
```

### 4.3 - Joins
Join data from two tables together
```bash
spark.sql("""
SELECT cassandra.demo.previous_employees_by_job_title.job_title, cassandra.demo.previous_employees_by_job_title.employee_name, cassandra.demo.previous_employees_by_job_title.first_day, cassandra.demo.previous_employees_by_job_title.last_day, cassandra.demo.days_worked_by_previous_employees_by_job_title.number_of_days_worked 
FROM cassandra.demo.previous_employees_by_job_title 
LEFT JOIN cassandra.demo.days_worked_by_previous_employees_by_job_title ON cassandra.demo.previous_employees_by_job_title.employee_id=cassandra.demo.days_worked_by_previous_employees_by_job_title.employee_id 
WHERE cassandra.demo.days_worked_by_previous_employees_by_job_title.job_title='Dentist'
""").show
```

## 5. Truncate tables with `CQLSH`

```bash
TRUNCATE TABLE demo.previous_employees_by_job_title ; 
```
```bash
TRUNCATE TABLE demo.days_worked_by_previous_employees_by_job_title ; 
```

## 6. Basic Cassandra Data Operations with Spark SQL (Source File to Cassandra)

### 6.1 - Restart Spark Shell
```bash
./bin/spark-shell --packages com.datastax.spark:spark-cassandra-connector_2.12:3.0.0 \
--master spark://arpans-mbp.lan:7077 \
--conf spark.cassandra.connection.host=127.0.0.1 \
--conf spark.cassandra.connection.port=9042 \
--conf spark.sql.extensions=com.datastax.spark.connector.CassandraSparkExtensions \
--conf spark.sql.catalog.cassandra=com.datastax.spark.connector.datasource.CassandraCatalog \
--files /path/to/example-cassandra-spark-sql/previous_employees_by_job_title.csv 
```

### 6.2 - Load CSV data to df
```bash
val csv_df = spark.read.format("csv").option("header", "true").load("/path/to/example-cassandra-spark-sql/previous_employees_by_job_title.csv")
```

### 6.3 - Create temp view to use Spark SQL
```bash
csv_df.createOrReplaceTempView("source")
```

### 6.4 - Write into Cassandra table using Spark SQL
```bash
spark.sql("INSERT INTO cassandra.demo.previous_employees_by_job_title SELECT * from source")
```

And that will wrap up the walkthrough on using Spark SQL for basic Cassandra Data Operations. If you want to watch a live recording of the walkthrough, be sure to check out the YouTube video linked below!

## Resources
- [Accompanying Blog]()
- [Accompanying YouTube]()
- https://github.com/datastax/spark-cassandra-connector
- https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/spark/sparkSqlSupportedSyntax.html
