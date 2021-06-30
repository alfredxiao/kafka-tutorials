# Start 
`docker-compose up -d`

# Start KSQL-CLI
`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create source stream 
```
CREATE STREAM ratings (old INT KEY, id INT, rating DOUBLE)
    WITH (kafka_topic='ratings',
          partitions=2,
          value_format='avro');
```

# Insert some recrods 
```
INSERT INTO ratings (old, id, rating) VALUES (1, 294, 8.2);
INSERT INTO ratings (old, id, rating) VALUES (2, 294, 8.5);
INSERT INTO ratings (old, id, rating) VALUES (3, 354, 9.9);
INSERT INTO ratings (old, id, rating) VALUES (4, 354, 9.7);
INSERT INTO ratings (old, id, rating) VALUES (5, 782, 7.8);
INSERT INTO ratings (old, id, rating) VALUES (6, 782, 7.7);
INSERT INTO ratings (old, id, rating) VALUES (7, 128, 8.7);
INSERT INTO ratings (old, id, rating) VALUES (8, 128, 8.4);
INSERT INTO ratings (old, id, rating) VALUES (9, 780, 2.1);
```

# Create rekey stream 
```
-- Besure to set this for DEMO
SET 'auto.offset.reset' = 'earliest';

CREATE STREAM RATINGS_REKEYED
    WITH (KAFKA_TOPIC='ratings_keyed_by_id') AS
    SELECT *
    FROM RATINGS
    PARTITION BY ID;
```

# Observe output topic
`PRINT ratings_keyed_by_id FROM BEGINNING LIMIT 9;`

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