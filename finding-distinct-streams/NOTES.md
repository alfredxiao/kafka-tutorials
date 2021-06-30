# Build it 
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Run it 
`java -jar build/libs/kstreams-find-distinct-standalone-0.0.1.jar configuration/dev.properties`

# Observe output topic
`docker exec -it schema-registry /usr/bin/kafka-avro-console-consumer --topic distinct-clicks --bootstrap-server broker:9092 --from-beginning`

# Produce sample input events
`docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic clicks --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/click.avsc)"`
```
{"ip":"10.0.0.1","url":"https://docs.confluent.io/current/tutorials/examples/kubernetes/gke-base/docs/index.html","timestamp":"2019-09-16T14:53:43+00:00"}
{"ip":"10.0.0.2","url":"https://www.confluent.io/hub/confluentinc/kafka-connect-datagen","timestamp":"2019-09-16T14:53:43+00:01"}
{"ip":"10.0.0.3","url":"https://www.confluent.io/hub/confluentinc/kafka-connect-datagen","timestamp":"2019-09-16T14:53:43+00:03"}
{"ip":"10.0.0.1","url":"https://docs.confluent.io/current/tutorials/examples/kubernetes/gke-base/docs/index.html","timestamp":"2019-09-16T14:53:43+00:00"}
{"ip":"10.0.0.2","url":"https://www.confluent.io/hub/confluentinc/kafka-connect-datagen","timestamp":"2019-09-16T14:53:43+00:01"}
{"ip":"10.0.0.3","url":"https://www.confluent.io/hub/confluentinc/kafka-connect-datagen","timestamp":"2019-09-16T14:53:43+00:03"}
```

# Run test 
`./gradlew test`

# Topics created
```
kafka-topics --bootstrap-server localhost:29092 --list

__consumer_offsets
_schemas
clicks
distinct-clicks
find-distinct-app-eventId-store-changelog
```

# Build docker image 
`gradle jibDockerBuild --image=io.confluent.developer/kstreams-find-distinct:0.0.1`

# Launch docker container 
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/kstreams-find-distinct:0.0.1 config.properties`