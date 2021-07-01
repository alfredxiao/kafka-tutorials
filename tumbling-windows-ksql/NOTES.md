# Start docker-compose

`docker-compose up -d`

# Start ksql-cl

`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create source stream

```
CREATE STREAM ratings (title VARCHAR, release_year INT, rating DOUBLE, timestamp VARCHAR)
    WITH (kafka_topic='ratings',
          timestamp='timestamp',
          timestamp_format='yyyy-MM-dd HH:mm:ss',
          partitions=1,
          value_format='avro');
```

# Insert sampel data

```
INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('Die Hard', 1998, 8.2, '2019-07-09 01:00:00');
INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('Die Hard', 1998, 4.5, '2019-07-09 05:00:00');
INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('Die Hard', 1998, 5.1, '2019-07-09 07:00:00');

INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('Tree of Life', 2011, 4.9, '2019-07-09 09:00:00');
INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('Tree of Life', 2011, 5.6, '2019-07-09 08:00:00');

INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('A Walk in the Clouds', 1995, 3.6, '2019-07-09 12:00:00');
INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('A Walk in the Clouds', 1995, 6.0, '2019-07-09 15:00:00');
INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('A Walk in the Clouds', 1995, 4.6, '2019-07-09 22:00:00');

INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('The Big Lebowski', 1998, 9.9, '2019-07-09 05:00:00');
INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('The Big Lebowski', 1998, 4.2, '2019-07-09 02:00:00');

INSERT INTO ratings (title, release_year, rating, timestamp) VALUES ('Super Mario Bros.', 1993, 3.5, '2019-07-09 18:00:00');
```

# Ad hoc query

```
SET 'auto.offset.reset' = 'earliest';
SELECT title,
       COUNT(*) AS rating_count,
       WINDOWSTART AS window_start,
       WINDOWEND AS window_end
FROM ratings
WINDOW TUMBLING (SIZE 6 HOURS)
GROUP BY title
EMIT CHANGES
LIMIT 11;

```

# Create materialised table view

```
CREATE TABLE rating_count
    WITH (kafka_topic='rating_count') AS
    SELECT title,
           COUNT(*) AS rating_count,
           WINDOWSTART AS window_start,
           WINDOWEND AS window_end
    FROM ratings
    WINDOW TUMBLING (SIZE 6 HOURS)
    GROUP BY title;
```

# Query the view

```
SELECT title,
       rating_count,
       TIMESTAMPTOSTRING(window_start, 'yyy-MM-dd HH:mm:ss', 'UTC') as window_start,
       TIMESTAMPTOSTRING(window_end, 'yyy-MM-dd HH:mm:ss', 'UTC') as window_end
FROM rating_count
EMIT CHANGES
LIMIT 11;
```

# Observe output topic

`PRINT rating_count FROM BEGINNING LIMIT 11;`

# NOTE

note that records (windowed result) in the output topic might be removed due to retention period exiry, as by default window retention is 1 day and we input data with old timestamp
