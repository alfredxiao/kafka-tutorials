# start docker-compose 
`docker-compose up -d`

# start ksql cli 
`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Create source tables and stream 
```
CREATE TABLE customers (customerid STRING PRIMARY KEY, customername STRING)
    WITH (KAFKA_TOPIC='customers',
          VALUE_FORMAT='json',
          PARTITIONS=1);

CREATE TABLE items (itemid STRING PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items',
          VALUE_FORMAT='json',
          PARTITIONS=1);

CREATE STREAM orders (orderid STRING KEY, customerid STRING, itemid STRING, purchasedate STRING)
    WITH (KAFKA_TOPIC='orders',
          VALUE_FORMAT='json',
          PARTITIONS=1);
```

# load some test data 
```
INSERT INTO customers VALUES ('1', 'Adrian Garcia');
INSERT INTO customers VALUES ('2', 'Robert Miller');
INSERT INTO customers VALUES ('3', 'Brian Smith');

INSERT INTO items VALUES ('101', 'Television 60-in');
INSERT INTO items VALUES ('102', 'Laptop 15-in');
INSERT INTO items VALUES ('103', 'Speakers');

INSERT INTO orders VALUES ('abc123', '1', '101', '2020-05-01');
INSERT INTO orders VALUES ('abc345', '1', '102', '2020-05-01');
INSERT INTO orders VALUES ('abc678', '2', '101', '2020-05-01');
INSERT INTO orders VALUES ('abc987', '3', '101', '2020-05-03');
INSERT INTO orders VALUES ('xyz123', '2', '103', '2020-05-03');
INSERT INTO orders VALUES ('xyz987', '2', '102', '2020-05-05');
```

# Create multi join table 
```
SET 'auto.offset.reset' = 'earliest';

CREATE STREAM orders_enriched AS
  SELECT customers.customerid AS customerid, customers.customername AS customername,
         orders.orderid, orders.purchasedate,
         items.itemid, items.itemname
  FROM orders
  LEFT JOIN customers on orders.customerid = customers.customerid
  LEFT JOIN items on orders.itemid = items.itemid;
```

# Observe output topic 
`SELECT * FROM ORDERS_ENRICHED EMIT CHANGES LIMIT 6;`

# Topics created 
```
$ kafka-topics --bootstrap-server localhost:29092 --list
ORDERS_ENRICHED
__consumer_offsets
__transaction_state
_confluent-ksql-default__command_topic
_confluent-ksql-default_query_CSAS_ORDERS_ENRICHED_5-Join-repartition
_confluent-ksql-default_query_CSAS_ORDERS_ENRICHED_5-KafkaTopic_L_Right-Reduce-changelog
_confluent-ksql-default_query_CSAS_ORDERS_ENRICHED_5-KafkaTopic_Right-Reduce-changelog
_confluent-ksql-default_query_CSAS_ORDERS_ENRICHED_5-L_Join-repartition
_schemas
customers
items
orders
```

# Run test 
`docker exec ksqldb-cli ksql-test-runner -i /opt/app/test/input.json -s /opt/app/src/statements.sql -o /opt/app/test/output.json`

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