# start docker-compose

`docker-compose up -d`

# Start ksql-cli

`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create Avro topic

```
CREATE STREAM movies_avro (MOVIE_ID BIGINT KEY, title VARCHAR, release_year INT)
    WITH (KAFKA_TOPIC='avro-movies',
          PARTITIONS=1,
          VALUE_FORMAT='avro');
```

# Insert some data

```
INSERT INTO movies_avro (MOVIE_ID, title, release_year) VALUES (1, 'Lethal Weapon', 1992);
INSERT INTO movies_avro (MOVIE_ID, title, release_year) VALUES (2, 'Die Hard', 1988);
INSERT INTO movies_avro (MOVIE_ID, title, release_year) VALUES (3, 'Predator', 1997);
```

# Create protobuf topic

```
SET 'auto.offset.reset' = 'earliest';
CREATE STREAM movies_proto
    WITH (KAFKA_TOPIC='proto-movies', VALUE_FORMAT='protobuf') AS
    SELECT * FROM movies_avro;

```

# Observe the protobuf topic

`PRINT 'proto-movies' FROM BEGINNING LIMIT 3;`

# Run test

`docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input.json -s /opt/app/src/statements.sql -o /opt/app/test/output.json`
