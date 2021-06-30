# Build it
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Run it 
`java -jar build/libs/kstreams-stream-table-join-standalone-0.0.1.jar configuration/dev.properties`

# Load in some movie data
```
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic movies --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/movie.avsc)"
{"id": 294, "title": "Die Hard", "release_year": 1988}
{"id": 354, "title": "Tree of Life", "release_year": 2011}
{"id": 782, "title": "A Walk in the Clouds", "release_year": 1995}
{"id": 128, "title": "The Big Lebowski", "release_year": 1998}
{"id": 780, "title": "Super Mario Bros.", "release_year": 1993}
```

# Observe output topic 
`docker exec -it schema-registry /usr/bin/kafka-avro-console-consumer --topic rated-movies --bootstrap-server broker:9092 --from-beginning`

# Produce some ratings 
`docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic ratings --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/rating.avsc)"`
```
{"id": 294, "rating": 8.2}
{"id": 294, "rating": 8.5}
{"id": 354, "rating": 9.9}
{"id": 354, "rating": 9.7}
{"id": 782, "rating": 7.8}
{"id": 782, "rating": 7.7}
{"id": 128, "rating": 8.7}
{"id": 128, "rating": 8.4}
{"id": 780, "rating": 2.1}
```

# Build docker image 
`gradle jibDockerBuild --image=io.confluent.developer/kstreams-stream-table-join:0.0.1`

# Run docker container
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/kstreams-stream-table-join:0.0.1 config.properties`
