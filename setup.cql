CREATE KEYSPACE demo WITH REPLICATION={'class': 'SimpleStrategy', 'replication_factor': 1};

CREATE TABLE demo.previous_employees_by_job_title (
    job_title text,
    employee_id uuid,
    employee_name text,
    first_day timestamp,
    last_day timestamp,
    PRIMARY KEY (job_title, employee_id)
) WITH CLUSTERING ORDER BY (employee_id ASC);

CREATE TABLE demo.days_worked_by_previous_employees_by_job_title (
    job_title text,
    employee_id uuid,
    employee_name text,
    number_of_days_worked int,
    PRIMARY KEY (job_title, employee_id)
) WITH CLUSTERING ORDER BY (employee_id ASC);

COPY demo.previous_employees_by_job_title from '/example-cassandra-spark-sql/previous_employees_by_job_title.csv' WITH HEADER = TRUE ;
