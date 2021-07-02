# start docker-compose 
`docker-compose up -d`

# build it 
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# run it 
`java -jar build/libs/session-windows-standalone-0.0.1.jar configuration/dev.properties`

# observe output topic
```
docker-compose exec broker kafka-console-consumer \
 --bootstrap-server broker:9092 \
 --topic output-topic \
 --property print.key=true \
 --property key.separator=" : "  \
 --from-beginning \
 --max-messages 4
```

# run test 
`./gradlew test`

# topics created 
```
$ kafka-topics --bootstrap-server localhost:29092 --list
__consumer_offsets
_schemas
output-topic
page-views
session-windows-KSTREAM-AGGREGATE-STATE-STORE-0000000001-changelog
```

# build docker image
`gradle jibDockerBuild --image=io.confluent.developer/session-windows-join:0.0.1`

# run docker container
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/session-windows-join:0.0.1 config.properties`


