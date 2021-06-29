# To start KSQL-CLI 
`docker exec -it ksql-cli ksql http://ksql-server:8088`

# Create source collection/stream 
```
CREATE STREAM CLICKS (IP_ADDRESS VARCHAR, URL VARCHAR, TIMESTAMP VARCHAR)
    WITH (KAFKA_TOPIC = 'CLICKS',
          FORMAT = 'JSON',
          TIMESTAMP = 'TIMESTAMP',
          TIMESTAMP_FORMAT = 'yyyy-MM-dd''T''HH:mm:ssXXX',
          PARTITIONS = 1);
```

# For demo purpose
```
SET 'auto.offset.reset' = 'earliest';
SET 'cache.max.bytes.buffering' = '0';
```

# Create changelog table
```
CREATE TABLE DETECTED_CLICKS AS
    SELECT
        IP_ADDRESS AS KEY1,
        URL AS KEY2,
        TIMESTAMP AS KEY3,
        AS_VALUE(IP_ADDRESS) AS IP_ADDRESS,
        AS_VALUE(URL) AS URL,
        AS_VALUE(TIMESTAMP) AS TIMESTAMP
    FROM CLICKS WINDOW TUMBLING (SIZE 2 MINUTES, RETENTION 1000 DAYS)
    GROUP BY IP_ADDRESS, URL, TIMESTAMP
    HAVING COUNT(IP_ADDRESS) = 1;
```
This table and its underlying topic:
1. it must be a table becuase of aggregation
2. it is a compacted topic due to same reason as above point 
3. it is keyed by the three KEYs plus window info 
4. if for the same keys and window, another click event comes, a new entry with tomestone will be created 

# Convert this table into a stream
```
CREATE STREAM RAW_DISTINCT_CLICKS (IP_ADDRESS VARCHAR, URL VARCHAR, TIMESTAMP VARCHAR)
    WITH (KAFKA_TOPIC = 'DETECTED_CLICKS',
          PARTITIONS = 1,
          FORMAT = 'JSON');
```

# Create final deduped stream with a filtering condition (filter out tomstones)
```
CREATE STREAM DISTINCT_CLICKS AS
    SELECT
        IP_ADDRESS,
        URL,
        TIMESTAMP
    FROM RAW_DISTINCT_CLICKS
    WHERE IP_ADDRESS IS NOT NULL
    PARTITION BY IP_ADDRESS;
```
**NOTE** also we assign a new key for this new stream/topic with `PARTITION BY`

# Insert some test input data
```
INSERT INTO CLICKS (IP_ADDRESS, URL, TIMESTAMP) VALUES ('10.0.0.1', 'https://docs.confluent.io/current/tutorials/examples/kubernetes/gke-base/docs/index.html', '2021-01-17T14:50:43+00:00');
INSERT INTO CLICKS (IP_ADDRESS, URL, TIMESTAMP) VALUES ('10.0.0.12', 'https://www.confluent.io/hub/confluentinc/kafka-connect-datagen', '2021-01-17T14:53:44+00:01');
INSERT INTO CLICKS (IP_ADDRESS, URL, TIMESTAMP) VALUES ('10.0.0.13', 'https://www.confluent.io/hub/confluentinc/kafka-connect-datagen', '2021-01-17T14:56:45+00:03');

INSERT INTO CLICKS (IP_ADDRESS, URL, TIMESTAMP) VALUES ('10.0.0.1', 'https://docs.confluent.io/current/tutorials/examples/kubernetes/gke-base/docs/index.html', '2021-01-17T14:50:43+00:00');
INSERT INTO CLICKS (IP_ADDRESS, URL, TIMESTAMP) VALUES ('10.0.0.12', 'https://www.confluent.io/hub/confluentinc/kafka-connect-datagen', '2021-01-17T14:53:44+00:01');
INSERT INTO CLICKS (IP_ADDRESS, URL, TIMESTAMP) VALUES ('10.0.0.13', 'https://www.confluent.io/hub/confluentinc/kafka-connect-datagen', '2021-01-17T14:56:45+00:03');
```

# See what topics are there 
```
kafka-topics --bootstrap-server localhost:29092 --list
CLICKS
DETECTED_CLICKS
DISTINCT_CLICKS
__consumer_offsets
__transaction_state
_confluent-ksql-default__command_topic
_confluent-ksql-default_query_CTAS_DETECTED_CLICKS_1-Aggregate-Aggregate-Materialize-changelog
_confluent-ksql-default_query_CTAS_DETECTED_CLICKS_1-Aggregate-GroupBy-repartition
_schemas
```

# Running tests
`docker exec ksql-cli ksql-test-runner -i /opt/app/test/input.json -s /opt/app/src/statements.sql -o /opt/app/test/output.json`

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