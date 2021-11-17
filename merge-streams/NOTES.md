# Run docker-compose
`docker-compose up -d`

# Build it
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Run it
`java -jar build/libs/kstreams-merge-standalone-0.0.1.jar configuration/dev.properties`

# Produce sample input
```
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic rock-song-events --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/song_event.avsc)"
{"artist": "Metallica", "title": "Fade to Black"}
{"artist": "Smashing Pumpkins", "title": "Today"}
{"artist": "Pink Floyd", "title": "Another Brick in the Wall"}
{"artist": "Van Halen", "title": "Jump"}
{"artist": "Led Zeppelin", "title": "Kashmir"}
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic classical-song-events --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/song_event.avsc)"
{"artist": "Wolfgang Amadeus Mozart", "title": "The Magic Flute"}
{"artist": "Johann Pachelbel", "title": "Canon"}
{"artist": "Ludwig van Beethoven", "title": "Symphony No. 5"}
{"artist": "Edward Elgar", "title": "Pomp and Circumstance"}
```

# Consume sample output
```
docker exec -it schema-registry /usr/bin/kafka-avro-console-consumer --topic all-song-events --bootstrap-server broker:9092 --from-beginning

You should see
{"artist":"Metallica","title":"Fade to Black"}
{"artist":"Smashing Pumpkins","title":"Today"}
{"artist":"Pink Floyd","title":"Another Brick in the Wall"}
{"artist":"Van Halen","title":"Jump"}
{"artist":"Led Zeppelin","title":"Kashmir"}
{"artist":"Wolfgang Amadeus Mozart","title":"The Magic Flute"}
{"artist":"Johann Pachelbel","title":"Canon"}
{"artist":"Ludwig van Beethoven","title":"Symphony No. 5"}
{"artist":"Edward Elgar","title":"Pomp and Circumstance"}
```

# Run test
`./gradlew test`

# Build a docker image
`./gradlew jibDockerBuild --image=io.confluent.developer/kstreams-merge:0.0.1`

# Run the docker image
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/kstreams-merge:0.0.1 config.properties`
