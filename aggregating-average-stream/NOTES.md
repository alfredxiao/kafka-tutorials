# To Build 
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# To Run 
`java -Dconfig.file=configuration/dev.properties -jar build/libs/aggregating-average-standalone-0.0.1.jar`

# To monitor output topic
```
docker exec -it broker /usr/bin/kafka-console-consumer --topic rating-averages --bootstrap-server broker:9092 \
  --property "print.key=true"\
  --property "key.deserializer=org.apache.kafka.common.serialization.LongDeserializer" \
  --property "value.deserializer=org.apache.kafka.common.serialization.DoubleDeserializer" \
  --from-beginning
```

# To produce input test data
```
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic ratings --bootstrap-server broker:9092 \
  --property "parse.key=false" \
  --property "key.separator=:" \
  --property value.schema="$(< src/main/avro/rating.avsc)"

{"movie_id":362,"rating":10}
{"movie_id":362,"rating":8}
```

# To run test 
`./gradlew test`

# To build a docker image 
`gradle jibDockerBuild --image=io.confluent.developer/aggregating-average:0.0.1`

# To run docker container 
```
# docker run -v $PWD/configuration/prod.properties:/prod.properties io.confluent.developer/aggregating-average:0.0.1

# run with network
docker run -v $PWD/configuration/prod.properties:/prod.properties --network cp_network io.confluent.developer/aggregating-average:0.0.1
```