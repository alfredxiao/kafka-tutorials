# Build UDF
`gradle wrapper`
`./gradlew build`

# Start KSQL-CLI
`docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

# Show functions (should see our custom UDF)
`SHOW FUNCTIONS;`

# Create custom stream 
```
CREATE STREAM customers (id int key, firstname string, lastname string, phonenumber string)
  WITH (kafka_topic='customers',
        partitions=2,
        value_format = 'avro');
```

# Insert data 
```
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (1, 'Sleve', 'McDichael', '(360) 555-8909');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (2, 'Onson', 'Sweemey', '206-555-1272');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (3, 'Darryl', 'Archideld', '425.555.6940');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (4, 'Anatoli', 'Smorin', '509.555.8033');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (5, 'Rey', 'McSriff', '360 555 6952');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (6, 'Glenallen', 'Mixon', '(253) 555-7050');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (7, 'Mario', 'McRlwain', '360 555 7598');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (8, 'Kevin', 'Nogilny', '206.555.8090');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (9, 'Tony', 'Smehrik', '425-555-7926');
INSERT INTO customers (id, firstname, lastname, phonenumber) VALUES (10, 'Bobson', 'Dugnutt', '509.555.8795');
```

# Examine input data with UDF 
```
SET 'auto.offset.reset' = 'earliest';
SELECT ID, FIRSTNAME, LASTNAME, PHONENUMBER, REGEXREPLACE(phonenumber, '\\(?(\\d{3}).*', '$1') as area_code
FROM CUSTOMERS
EMIT CHANGES
LIMIT 10;
```

# Create new stream rekeyed with UDF 
```
CREATE STREAM customers_by_area_code
  WITH (KAFKA_TOPIC='customers_by_area_code') AS
    SELECT
      REGEXREPLACE(phonenumber, '\\(?(\\d{3}).*', '$1') AS AREA_CODE,
      id,
      firstname,
      lastname,
      phonenumber
    FROM customers
    PARTITION BY REGEXREPLACE(phonenumber, '\\(?(\\d{3}).*', '$1')
    EMIT CHANGES;
```

# Examine rekeyed topic 
`print customers_by_area_code from beginning;`

# Run tests 
`./gradlew test`
Note to run KSQL test, extension folder needs to be mounted
`docker-compose exec ksqldb-cli ksql-test-runner -e /etc/ksqldb/ext -i /opt/app/test/input.json -s /opt/app/src/statements.sql -o /opt/app/test/output.json`