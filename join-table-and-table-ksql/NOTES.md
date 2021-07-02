# Run docker-compose
`docker-compose up -d`

# Start ksql cli 
`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create two source tables 
```
CREATE TABLE movies (
      title VARCHAR PRIMARY KEY,
      id INT,
      release_year INT
    ) WITH (
      KAFKA_TOPIC='movies',
      PARTITIONS=1,
      VALUE_FORMAT='avro'
    );
CREATE TABLE lead_actor (
     title VARCHAR PRIMARY KEY,
     actor_name VARCHAR
   ) WITH (
     KAFKA_TOPIC='lead_actors',
     PARTITIONS=1,
     VALUE_FORMAT='avro'
   );
```

# Insert some test data 
```
INSERT INTO MOVIES (ID, TITLE, RELEASE_YEAR) VALUES (48, 'Aliens', 1986);
INSERT INTO MOVIES (ID, TITLE, RELEASE_YEAR) VALUES (294, 'Die Hard', 1998);
INSERT INTO MOVIES (ID, TITLE, RELEASE_YEAR) VALUES (128, 'The Big Lebowski', 1998);
INSERT INTO MOVIES (ID, TITLE, RELEASE_YEAR) VALUES (42, 'The Godfather', 1998);

INSERT INTO LEAD_ACTOR (TITLE, ACTOR_NAME) VALUES ('Aliens','Sigourney Weaver');
INSERT INTO LEAD_ACTOR (TITLE, ACTOR_NAME) VALUES ('Die Hard','Bruce Willis');
INSERT INTO LEAD_ACTOR (TITLE, ACTOR_NAME) VALUES ('The Big Lebowski','Jeff Bridges');
INSERT INTO LEAD_ACTOR (TITLE, ACTOR_NAME) VALUES ('The Godfather','Al Pacino');
```

# Run ad hoc query
```
SET 'auto.offset.reset' = 'earliest';

SELECT M.ID, M.TITLE, M.RELEASE_YEAR, L.ACTOR_NAME
    FROM MOVIES M
    INNER JOIN LEAD_ACTOR L
    ON M.TITLE = L.TITLE
    EMIT CHANGES
    LIMIT 3;
```

# Create persistent query for the table joining 
```
CREATE TABLE MOVIES_ENRICHED AS
    SELECT M.ID, M.TITLE, M.RELEASE_YEAR, L.ACTOR_NAME
    FROM MOVIES M
    INNER JOIN LEAD_ACTOR L
    ON M.TITLE = L.TITLE
    EMIT CHANGES;
```

# Observe output topic 
`PRINT MOVIES_ENRICHED FROM BEGINNING LIMIT 3;`

# Run test 
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