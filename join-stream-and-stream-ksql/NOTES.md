# Start docker-compose 
`docker-compose up -d`

# Start ksql cli 
`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create two source streams 
```
CREATE STREAM orders (ID INT KEY, order_ts VARCHAR, total_amount DOUBLE, customer_name VARCHAR)
    WITH (KAFKA_TOPIC='_orders',
          VALUE_FORMAT='AVRO',
          TIMESTAMP='order_ts',
          TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX',
          PARTITIONS=4);

CREATE STREAM shipments (ID VARCHAR KEY, ship_ts VARCHAR, order_id INT, warehouse VARCHAR)
    WITH (KAFKA_TOPIC='_shipments',
          VALUE_FORMAT='AVRO',
          TIMESTAMP='ship_ts',
          TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX',
          PARTITIONS=4);
```

# Insert some data entries in both streams
```
INSERT INTO orders (id, order_ts, total_amount, customer_name) VALUES (1, '2019-03-29T06:01:18Z', 133548.84, 'Ricardo Ferreira');
INSERT INTO orders (id, order_ts, total_amount, customer_name) VALUES (2, '2019-03-29T17:02:20Z', 164839.31, 'Tim Berglund');
INSERT INTO orders (id, order_ts, total_amount, customer_name) VALUES (3, '2019-03-29T13:44:10Z', 90427.66, 'Robin Moffatt');
INSERT INTO orders (id, order_ts, total_amount, customer_name) VALUES (4, '2019-03-29T11:58:25Z', 33462.11, 'Viktor Gamov');

INSERT INTO shipments (id, ship_ts, order_id, warehouse) VALUES ('ship-ch83360', '2019-03-31T18:13:39Z', 1, 'UPS');
INSERT INTO shipments (id, ship_ts, order_id, warehouse) VALUES ('ship-xf72808', '2019-03-31T02:04:13Z', 2, 'UPS');
INSERT INTO shipments (id, ship_ts, order_id, warehouse) VALUES ('ship-kr47454', '2019-03-31T20:47:09Z', 3, 'DHL');
```

# Run ad hoc query to join two streams 
```
SET 'auto.offset.reset' = 'earliest';
SELECT o.id AS order_id,
       TIMESTAMPTOSTRING(o.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS order_ts,
       o.total_amount,
       o.customer_name,
       s.id as shipment_id,
       TIMESTAMPTOSTRING(s.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS shipment_ts,
       s.warehouse,
       (s.rowtime - o.rowtime) / 1000 / 60 AS ship_time
FROM orders o INNER JOIN shipments s
WITHIN 7 DAYS
ON o.id = s.order_id
EMIT CHANGES
LIMIT 3;
```

# Create persistent query for the stream joining
```
CREATE STREAM shipped_orders AS
    SELECT o.id AS order_id,
           TIMESTAMPTOSTRING(o.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS order_ts,
           o.total_amount,
           o.customer_name,
           s.id AS SHIPMENT_ID,
           TIMESTAMPTOSTRING(s.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS shipment_ts,
           s.warehouse,
           (s.rowtime - o.rowtime) / 1000 / 60 AS ship_time
    FROM orders o INNER JOIN shipments s
    WITHIN 7 DAYS
    ON o.id = s.order_id;
```

# Observe output topic 
`PRINT SHIPPED_ORDERS FROM BEGINNING LIMIT 3;`

# Topics created 
```
$ kafka-topics --bootstrap-server localhost:29092 --list
SHIPPED_ORDERS
__consumer_offsets
__transaction_state
_confluent-ksql-default__command_topic
_confluent-ksql-default_query_CSAS_SHIPPED_ORDERS_3-Join-right-repartition
_confluent-ksql-default_query_CSAS_SHIPPED_ORDERS_3-KSTREAM-JOINOTHER-0000000013-store-changelog
_confluent-ksql-default_query_CSAS_SHIPPED_ORDERS_3-KSTREAM-JOINTHIS-0000000012-store-changelog
_orders
_schemas
_shipments
```
**NOTE** reason why `Join-right-repartition` is created is because the right (shipments) was keyed by shipment-id, not order-id, so need to repartition it to be by order-id

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
