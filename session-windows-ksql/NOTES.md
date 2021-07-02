# start docker-compose
`docker-compose up -d`

# start ksql cli 
`docker exec -it ksqldb ksql http://ksqldb:8088`

# create source stream 
```
CREATE STREAM clicks (ip VARCHAR, url VARCHAR, timestamp VARCHAR)
WITH (KAFKA_TOPIC='clicks',
      TIMESTAMP='timestamp',
      TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX',
      PARTITIONS=1,
      VALUE_FORMAT='Avro');
```

# load with some data 
```
INSERT INTO clicks (ip, timestamp, url) VALUES ('51.56.119.117','2019-07-18T10:00:00Z','/etiam/justo/etiam/pretium/iaculis.xml');
INSERT INTO clicks (ip, timestamp, url) VALUES ('51.56.119.117','2019-07-18T10:01:00Z','/nullam/orci/pede/venenatis.json');
INSERT INTO clicks (ip, timestamp, url) VALUES ('53.170.33.192','2019-07-18T10:01:31Z','/mauris/morbi/non.jpg');
INSERT INTO clicks (ip, timestamp, url) VALUES ('51.56.119.117','2019-07-18T10:01:36Z','/convallis/nunc/proin.jsp');
INSERT INTO clicks (ip, timestamp, url) VALUES ('53.170.33.192','2019-07-18T10:02:00Z','/vestibulum/vestibulum/ante/ipsum/primis/in.json');
INSERT INTO clicks (ip, timestamp, url) VALUES ('51.56.119.117','2019-07-18T11:03:21Z','/vehicula/consequat/morbi/a/ipsum/integer/a.jpg');
INSERT INTO clicks (ip, timestamp, url) VALUES ('51.56.119.117','2019-07-18T11:03:50Z','/pede/venenatis.jsp');
INSERT INTO clicks (ip, timestamp, url) VALUES ('53.170.33.192','2019-07-18T11:40:00Z','/nec/euismod/scelerisque/quam.xml');
INSERT INTO clicks (ip, timestamp, url) VALUES ('53.170.33.192','2019-07-18T11:40:09Z','/ligula/nec/sem/duis.jsp');
```

# ad hoc query with session window
```
SET 'auto.offset.reset' = 'earliest';
SET 'ksql.streams.cache.max.bytes.buffering'='2000000';

SELECT IP,
       TIMESTAMPTOSTRING(WINDOWSTART,'yyyy-MM-dd HH:mm:ss', 'UTC') AS SESSION_START_TS,
       TIMESTAMPTOSTRING(WINDOWEND,'yyyy-MM-dd HH:mm:ss', 'UTC')   AS SESSION_END_TS,
       COUNT(*)                                                    AS CLICK_COUNT,
       WINDOWEND - WINDOWSTART                                     AS SESSION_LENGTH_MS
  FROM CLICKS
       WINDOW SESSION (5 MINUTES)
GROUP BY IP
EMIT CHANGES LIMIT 4;

```

# create persistent query for the table 
```
CREATE TABLE IP_SESSIONS AS
SELECT IP,
       TIMESTAMPTOSTRING(WINDOWSTART,'yyyy-MM-dd HH:mm:ss', 'UTC') AS SESSION_START_TS,
       TIMESTAMPTOSTRING(WINDOWEND,'yyyy-MM-dd HH:mm:ss', 'UTC')   AS SESSION_END_TS,
       COUNT(*)                                                    AS CLICK_COUNT,
       WINDOWEND - WINDOWSTART                                     AS SESSION_LENGTH_MS
  FROM CLICKS
       WINDOW SESSION (5 MINUTES)
GROUP BY IP;
```

# observe output topic
`PRINT IP_SESSIONS FROM BEGINNING LIMIT 5;`

# run test
`docker exec ksqldb ksql-test-runner -i /opt/app/test/input.json -s /opt/app/src/statements.sql -o /opt/app/test/output.json`

# topics created
```
docker exec broker kafka-topics --bootstrap-server localhost:29092 --list
IP_SESSIONS
__consumer_offsets
__transaction_state
_confluent-ksql-default__command_topic
_confluent-ksql-default_query_CTAS_IP_SESSIONS_1-Aggregate-Aggregate-Materialize-changelog
_confluent-ksql-default_query_CTAS_IP_SESSIONS_1-Aggregate-GroupBy-repartition
_schemas
clicks
```

# submit query via REST 
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




