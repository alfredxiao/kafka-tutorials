# Build 
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Run it
`java -jar build/libs/streams-to-table-standalone-0.0.1.jar configuration/dev.properties`

# Generate sample input
`docker-compose exec broker kafka-console-producer --topic input-topic --bootstrap-server broker:9092 \
--property parse.key=true \
--property key.separator=":"`
```
key_one:foo
key_one:bar
key_one:baz
key_two:foo
key_two:bar
key_two:baz
```

# Observe output topics 
`docker-compose exec broker kafka-console-consumer --topic streams-output-topic --bootstrap-server broker:9092 \
--from-beginning \
--property print.key=true \
--property key.separator=" - "`
`docker-compose exec broker kafka-console-consumer --topic table-output-topic --bootstrap-server broker:9092 \
--from-beginning \
--property print.key=true \
--property key.separator=" - "`

# Cleanup 
`docker-compose down --volume`