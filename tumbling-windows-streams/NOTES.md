# start docker-compose

`docker-compose up -d`

# build

`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Start app

`java -jar build/libs/kstreams-tumbling-windows-standalone-0.0.1.jar configuration/dev.properties`

# Observer output toic

`docker exec -it broker /usr/bin/kafka-console-consumer --topic rating-counts --bootstrap-server broker:9092 --from-beginning --property print.key=true`

# Produce input data

```
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic ratings --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/rating.avsc)"
```

```
{"title": "Die Hard", "release_year": 1998, "rating": 8.2, "timestamp": "2019-04-25T18:00:00-0700"}
{"title": "Die Hard", "release_year": 1998, "rating": 4.5, "timestamp": "2019-04-25T18:03:00-0700"}
{"title": "Die Hard", "release_year": 1998, "rating": 5.1, "timestamp": "2019-04-25T18:04:00-0700"}
{"title": "Die Hard", "release_year": 1998, "rating": 2.0, "timestamp": "2019-04-25T18:07:00-0700"}
{"title": "Die Hard", "release_year": 1998, "rating": 8.3, "timestamp": "2019-04-25T18:32:00-0700"}
{"title": "Die Hard", "release_year": 1998, "rating": 3.4, "timestamp": "2019-04-25T18:36:00-0700"}
{"title": "Die Hard", "release_year": 1998, "rating": 4.2, "timestamp": "2019-04-25T18:43:00-0700"}
{"title": "Die Hard", "release_year": 1998, "rating": 7.6, "timestamp": "2019-04-25T18:44:00-0700"}
{"title": "Tree of Life", "release_year": 2011, "rating": 4.9, "timestamp": "2019-04-25T20:01:00-0700"}
{"title": "Tree of Life", "release_year": 2011, "rating": 5.6, "timestamp": "2019-04-25T20:02:00-0700"}
{"title": "Tree of Life", "release_year": 2011, "rating": 9.0, "timestamp": "2019-04-25T20:03:00-0700"}
{"title": "Tree of Life", "release_year": 2011, "rating": 6.5, "timestamp": "2019-04-25T20:12:00-0700"}
{"title": "Tree of Life", "release_year": 2011, "rating": 2.1, "timestamp": "2019-04-25T20:13:00-0700"}
{"title": "A Walk in the Clouds", "release_year": 1995, "rating": 3.6, "timestamp": "2019-04-25T22:20:00-0700"}
{"title": "A Walk in the Clouds", "release_year": 1995, "rating": 6.0, "timestamp": "2019-04-25T22:21:00-0700"}
{"title": "A Walk in the Clouds", "release_year": 1995, "rating": 7.0, "timestamp": "2019-04-25T22:22:00-0700"}
{"title": "A Walk in the Clouds", "release_year": 1995, "rating": 4.6, "timestamp": "2019-04-25T22:23:00-0700"}
{"title": "A Walk in the Clouds", "release_year": 1995, "rating": 7.1, "timestamp": "2019-04-25T22:24:00-0700"}
{"title": "The Big Lebowski", "release_year": 1998, "rating": 9.9, "timestamp": "2019-04-25T21:15:00-0700"}
{"title": "The Big Lebowski", "release_year": 1998, "rating": 8.6, "timestamp": "2019-04-25T21:16:00-0700"}
{"title": "The Big Lebowski", "release_year": 1998, "rating": 4.2, "timestamp": "2019-04-25T21:17:00-0700"}
{"title": "The Big Lebowski", "release_year": 1998, "rating": 7.0, "timestamp": "2019-04-25T21:18:00-0700"}
{"title": "The Big Lebowski", "release_year": 1998, "rating": 9.5, "timestamp": "2019-04-25T21:19:00-0700"}
{"title": "The Big Lebowski", "release_year": 1998, "rating": 3.2, "timestamp": "2019-04-25T21:20:00-0700"}
{"title": "Super Mario Bros.", "release_year": 1993, "rating": 3.5, "timestamp": "2019-04-25T13:00:00-0700"}
{"title": "Super Mario Bros.", "release_year": 1993, "rating": 4.0, "timestamp": "2019-04-25T13:07:00-0700"}
{"title": "Super Mario Bros.", "release_year": 1993, "rating": 5.1, "timestamp": "2019-04-25T13:30:00-0700"}
{"title": "Super Mario Bros.", "release_year": 1993, "rating": 2.0, "timestamp": "2019-04-25T13:34:00-0700"}
```

# Run test

`./gradlew test`

# Build docker image

`./gradlew jibDockerBuild --image=io.confluent.developer/kstreams-tumbling-windows:0.0.1`

# Run docker container

`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/kstreams-tumbling-windows:0.0.1 config.properties`
