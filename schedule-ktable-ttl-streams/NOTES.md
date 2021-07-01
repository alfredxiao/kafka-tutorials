# Write back to the same topic!!
```
table.toStream()  //we just have to do this part for doing in the same topology but in another app, you can do as above
    .transform(() -> new TTLEmitter<String, String, KeyValue<String, String>>(MAX_AGE,
        SCAN_FREQUENCY, STATE_STORE_NAME), STATE_STORE_NAME)
    .to(inputTopicForTable, Produced.with(Serdes.String(), Serdes.String())); // write the
```

#  Null Transformer
* The above transformer always return `null` in its `transform` function
* Instead, it relies on scheduled run to create/forward new records to downstream processors
    * use context to forward: `context.forward(record.key, null);`
    * forward a tombstone 
    * downstream processor is the same input topic!
    
# To Start docker-compose
`docker-compose up -d`

# To build it 
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# To run it 
`java -jar build/libs/schedule-ktable-ttl-standalone-0.0.1.jar configuration/dev.properties`

# Enter some data into table topic
```
docker exec -i broker kafka-console-producer --topic inputTopicForTable --bootstrap-server broker:9092 \
  --property parse.key=true \
  --property key.separator=":"
```
```
key1:what a lovely
foo:bar
fun:not quarantine
```

# Enter some data into stream
```
docker exec -i broker kafka-console-producer --topic inputTopicForStream --bootstrap-server broker:9092 \
  --property parse.key=true \
  --property key.separator=":"
```
```
key1:Bunch of coconuts
foo:baz
fun:post quarantine
```

# Observer from output topic (keep this running, don't stop it)
```
docker exec -it broker kafka-console-consumer \
 --bootstrap-server broker:9092 \
 --topic output-topic \
 --property print.key=true \
 --value-deserializer "org.apache.kafka.common.serialization.StringDeserializer" \
 --property key.separator=" : "  \
 --from-beginning \
 --max-messages 3
```

# After 65 seconds, enter some data again (actually does not matter which topic, below use the table topic for example)
```
docker exec -i broker kafka-console-producer --topic inputTopicForTable --bootstrap-server broker:9092 \
  --property parse.key=true \
  --property key.separator=":"
```
`key2: some new data`

# Now enter some data with old keys (into the stream topic)
```
docker exec -i broker kafka-console-producer --topic inputTopicForStream --bootstrap-server broker:9092 \
  --property parse.key=true \
  --property key.separator=":"
```
```
key1:Bunch of coconuts
foo:baz
fun:post quarantine
```
Expected observation: You should see that the joined topic does not include right side value from table because they have expired due to passing TTL threshold

# Run test 
`./gradlew test`

# Build image 
`gradle jibDockerBuild --image=io.confluent.developer/schedule-ktable-ttl-join:0.0.1`

# Run container
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/schedule-ktable-ttl-join:0.0.1 config.properties`