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
