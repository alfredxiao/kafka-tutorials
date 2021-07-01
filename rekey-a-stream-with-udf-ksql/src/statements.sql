CREATE STREAM customers (id int key, firstname string, lastname string, phonenumber string)
  WITH (kafka_topic='customers',
        partitions=2,
        value_format = 'avro');

CREATE STREAM customers_by_area_code
  WITH (KAFKA_TOPIC='customers_by_area_code',
        partitions=2,
        value_format = 'avro') 
  AS
  SELECT
      REGEXREPLACE(phonenumber, '\(?(\d{3}).*', '$1'),
      id,
      firstname,
      lastname,
      phonenumber
    FROM customers
    PARTITION BY REGEXREPLACE(phonenumber, '\(?(\d{3}).*', '$1')
    EMIT CHANGES;
