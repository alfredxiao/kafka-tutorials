# Start docker-compose 
`docker-compose up -d`

# Start KSQLDB CLI 
`docker exec -it ksqldb ksql http://ksqldb:8088`

# Create steram 
```
CREATE STREAM pageviews (msg VARCHAR)
  WITH (KAFKA_TOPIC ='pageviews',
        VALUE_FORMAT='JSON');
```

# Do ad hoc query to count it 
```
SET 'auto.offset.reset' = 'earliest';
SELECT 'X' AS X,
       COUNT(*) AS MSG_CT
  FROM PAGEVIEWS
  GROUP BY 'X'
  EMIT CHANGES LIMIT 1;
```

# Create table (backed by changelog topic as well as state store, allows queries)
```
CREATE TABLE MSG_COUNT AS
    SELECT 'X' AS X,
        COUNT(*) AS MSG_CT
    FROM PAGEVIEWS
    GROUP BY 'X'
    EMIT CHANGES;
```

# Query your table (Pull query)
`SELECT * FROM MSG_COUNT WHERE X='X';`

# Query via REST 
```
docker exec ksqldb \
    curl --silent --show-error \
         --http2 'http://localhost:8088/query-stream' \
         --data-raw '{"sql":"SELECT MSG_CT FROM MSG_COUNT WHERE X='\''X'\'';"}'
```

# Run tests
**NOTE** that contrary to the output we saw from the CLI above, in the test execution there is **no buffering** of the input records and so an aggregate value is emitted for every input record processed 
`docker exec ksqldb ksql-test-runner -i /opt/app/test/input.json -s /opt/app/src/statements.sql -o /opt/app/test/output.json 2>&1`

# Cleanup 
`docker-compuse down`