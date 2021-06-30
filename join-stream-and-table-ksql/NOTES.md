# Run servers 
`docker-compose up -d`

# Start KSQL-CLI
`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create table 
`CREATE TABLE movies (ID INT PRIMARY KEY, title VARCHAR, release_year INT) WITH (kafka_topic='movies', partitions=1, value_format='avro');`

# Create Stream
`CREATE STREAM ratings (MOVIE_ID INT KEY, rating DOUBLE) WITH (kafka_topic='ratings', partitions=1, value_format='avro');`

# Insert base data 
```
INSERT INTO movies (id, title, release_year) VALUES (294, 'Die Hard', 1998);
INSERT INTO movies (id, title, release_year) VALUES (354, 'Tree of Life', 2011);
INSERT INTO movies (id, title, release_year) VALUES (782, 'A Walk in the Clouds', 1995);
INSERT INTO movies (id, title, release_year) VALUES (128, 'The Big Lebowski', 1998);
INSERT INTO movies (id, title, release_year) VALUES (780, 'Super Mario Bros.', 1993);

INSERT INTO ratings (movie_id, rating) VALUES (294, 8.2);
INSERT INTO ratings (movie_id, rating) VALUES (294, 8.5);
INSERT INTO ratings (movie_id, rating) VALUES (354, 9.9);
INSERT INTO ratings (movie_id, rating) VALUES (354, 9.7);
INSERT INTO ratings (movie_id, rating) VALUES (782, 7.8);
INSERT INTO ratings (movie_id, rating) VALUES (782, 7.7);
INSERT INTO ratings (movie_id, rating) VALUES (128, 8.7);
INSERT INTO ratings (movie_id, rating) VALUES (128, 8.4);
INSERT INTO ratings (movie_id, rating) VALUES (780, 2.1);
```

# Start explorary queries
`SET 'auto.offset.reset' = 'earliest';`
```
SELECT ratings.movie_id AS ID, title, release_year, rating
   FROM ratings
   LEFT JOIN movies ON ratings.movie_id = movies.id
   EMIT CHANGES;
```

# Create persistent query
```
CREATE STREAM rated_movies
    WITH (kafka_topic='rated_movies',
          value_format='avro') AS
    SELECT ratings.movie_id as id, title, rating
    FROM ratings
    LEFT JOIN movies ON ratings.movie_id = movies.id;
```

# Observe output topic
`PRINT rated_movies FROM BEGINNING LIMIT 9;`

# Run tests
`docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input.json -s /opt/app/src/statements.sql -o /opt/app/test/output.json`

# Submit query via REST 
```
tr '\n' ' ' < src/statements.sql | \
sed 's/;/;\'$'\n''/g' | \
while read stmt; do
    echo '{"ksql":"'$stmt'", "streamsProperties": {}}' | \
        curl -s -X "POST" "http://localhost:8088/ksql" \
             -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
             -d @- | \
        jq
done
```