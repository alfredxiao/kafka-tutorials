# Build it 
```
gradle wrapper 
./gradlew build 
./gradlew shadowJar
```

# Run it 
`java -jar build/libs/dynamic-output-topic-standalone-0.0.1.jar configuration/dev.properties`

# Observe output topics
```
docker exec -it schema-registry /usr/bin/kafka-avro-console-consumer --topic regular-order --bootstrap-server broker:9092 --from-beginning
docker exec -it schema-registry /usr/bin/kafka-avro-console-consumer --topic special-order --bootstrap-server broker:9092 --from-beginning
```

# Generate input samples
```
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic input --bootstrap-server broker:9092 \
  --property "parse.key=true" \
  --property 'key.schema={"type":"string"}' \
  --property "key.separator=:" \
  --property value.schema="$(< src/main/avro/order.avsc)"
```
```
"5":{"id":5,"name":"tp","quantity":10000, "sku":"QUA00000123"}
"6":{"id":6,"name":"coffee","quantity":1000, "sku":"COF0003456"}
"7":{"id":7,"name":"hand-sanitizer","quantity":6000, "sku":"QUA000022334"}
"8":{"id":8,"name":"beer","quantity":4000, "sku":"BER88899222"}
```

# Run test 
`./gradlew test`

# Build docker image
`gradle jibDockerBuild --image=io.confluent.developer/dynamic-output-topic-join:0.0.1`

# Run docker container 
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/dynamic-output-topic-join:0.0.1 config.properties`

# Topics created 
```
kafka-topics --bootstrap-server localhost:29092 --list
__consumer_offsets
_schemas
input
regular-order
special-order
```