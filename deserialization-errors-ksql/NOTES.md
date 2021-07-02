# start docker-compose 
`docker-compose up -d`

# Start ksql cli 
`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create the raw stream and repartitioned stream 
```
CREATE STREAM SENSORS_RAW (id VARCHAR, timestamp VARCHAR, enabled BOOLEAN)
    WITH (KAFKA_TOPIC = 'SENSORS_RAW',
          VALUE_FORMAT = 'JSON',
          TIMESTAMP = 'TIMESTAMP',
          TIMESTAMP_FORMAT = 'yyyy-MM-dd HH:mm:ss',
          PARTITIONS = 1);

CREATE STREAM SENSORS AS
    SELECT
        ID, TIMESTAMP, ENABLED
    FROM SENSORS_RAW
    PARTITION BY ID;
```

# Produce some records 
`docker exec -i broker /usr/bin/kafka-console-producer --bootstrap-server broker:9092 --topic SENSORS_RAW`
```
{"id": "e7f45046-ad13-404c-995e-1eca16742801", "timestamp": "2020-01-15 02:20:30", "enabled": true}
{"id": "835226cf-caf6-4c91-a046-359f1d3a6e2e", "timestamp": "2020-01-15 02:25:30", "enabled": true}
{"id": "1a076a64-4a84-40cb-a2e8-2190f3b37465", "timestamp": "2020-01-15 02:30:30", "enabled": "true"}
{"id": "1a076a64-4a84-40cb-a2e8-38eb389cf892", "timestamp": "2020-01-15 02:32:20", "enabled": true}
```

# Check for deserialization errors 
`SET 'auto.offset.reset' = 'earliest';`

Below query should only yeild 3 records
```
SELECT
    ID,
    TIMESTAMP,
    ENABLED
FROM SENSORS EMIT CHANGES;
```

# Check for processing logs
```
SELECT
    message->deserializationError->errorMessage,
    encode(message->deserializationError->RECORDB64, 'base64', 'utf8') AS MSG,
    message->deserializationError->cause
  FROM KSQL_PROCESSING_LOG
  EMIT CHANGES
  LIMIT 1;
```
`PRINT ksql_processing_log FROM BEGINNING LIMIT 1;`

# Submit query via REST 
```
statements=$(< src/statements.sql) && \
    echo '{"ksql":"'$statements'", "streamsProperties": {}}' | \
        curl -X "POST" "http://localhost:8088/ksql" \
             -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
             -d @- | \
        jq
```

