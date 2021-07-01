# start docker-compose

`docker-compose up -d`

# Build it

`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Run it

`java -jar build/libs/kstreams-serialization-standalone-0.0.1.jar configuration/dev.properties`

# observe output topic

`docker exec -i schema-registry /usr/bin/kafka-protobuf-console-consumer --bootstrap-server broker:9092 --topic proto-movies --from-beginning`

# generate some input data

`docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic avro-movies --bootstrap-server broker:9092 --property value.schema="$(< src/main/avro/movie.avsc)"`

# run test

`./gradlew test`

# build docker image

`./gradlew jibDockerBuild --image=io.confluent.developer/kstreams-serialization:0.0.1`

# run docker container

`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/kstreams-serialization:0.0.1 config.properties`
