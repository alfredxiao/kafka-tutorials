How to build and run:
```
gradle wrapper 
./gradlew build
./gradlew shadowJar
java -jar build/libs/kstreams-aggregating-count-standalone-0.0.1.jar configuration/dev.properties


```

# To create input records
`docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic movie-ticket-sales --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/ticket-sale.avsc)"`
Input below records
```
{"title":"Die Hard","sale_ts":"2019-07-18T10:00:00Z","ticket_total_value":12}
{"title":"Die Hard","sale_ts":"2019-07-18T10:01:00Z","ticket_total_value":12}
{"title":"The Godfather","sale_ts":"2019-07-18T10:01:31Z","ticket_total_value":12}
{"title":"Die Hard","sale_ts":"2019-07-18T10:01:36Z","ticket_total_value":24}
{"title":"The Godfather","sale_ts":"2019-07-18T10:02:00Z","ticket_total_value":18}
{"title":"The Big Lebowski","sale_ts":"2019-07-18T11:03:21Z","ticket_total_value":12}
{"title":"The Big Lebowski","sale_ts":"2019-07-18T11:03:50Z","ticket_total_value":12}
{"title":"The Godfather","sale_ts":"2019-07-18T11:40:00Z","ticket_total_value":36}
{"title":"The Godfather","sale_ts":"2019-07-18T11:40:09Z","ticket_total_value":18}
```

# Inspect output topic
`docker exec -it broker /usr/bin/kafka-console-consumer --topic movie-tickets-sold --bootstrap-server broker:9092 --from-beginning --property print.key=true`

# Topics created 
```
# kafka-topics --bootstrap-server localhost:29092 --list
__consumer_offsets
_schemas
aggregating-count-app-KSTREAM-AGGREGATE-STATE-STORE-0000000002-changelog
aggregating-count-app-KSTREAM-AGGREGATE-STATE-STORE-0000000002-repartition
movie-ticket-sales
movie-tickets-sold
```

# Build an application docker image 
`gradle jibDockerBuild --image=io.confluent.developer/kstreams-aggregating-count:0.0.1`

# Run the application image
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/kstreams-aggregating-count:0.0.1 config.properties`