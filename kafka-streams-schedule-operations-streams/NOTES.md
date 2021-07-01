# Start docker-compose 
`docker-compose up -d --build`

# Build it 
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Start datagen
```
curl -i -X PUT http://localhost:8083/connectors/datagen_local_01/config \
     -H "Content-Type: application/json" \
     -d '{
            "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
            "key.converter": "org.apache.kafka.connect.storage.StringConverter",
            "kafka.topic": "login-events",
            "schema.filename": "/tmp/datagen-logintime.avsc",
            "schema.keyfield": "userid",
            "max.interval": 1000,
            "iterations": 10000000,
            "tasks.max": "1"
        }'
```

# Run application 
`java -jar build/libs/kafka-streams-schedule-operations-standalone-0.0.1.jar configuration/dev.properties`

# Observe output topic
```
docker-compose exec broker kafka-console-consumer \
 --bootstrap-server broker:9092 \
 --topic output-topic \
 --property print.key=true \
 --value-deserializer "org.apache.kafka.common.serialization.LongDeserializer" \
 --property key.separator=" : "  \
 --from-beginning \
 --max-messages 10
```

# Run test 
`./gradlew test`

# Build docker image 
`gradle jibDockerBuild --image=io.confluent.developer/kafka-streams-schedule-operations-join:0.0.1`

# Launch container 
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/kafka-streams-schedule-operations-join:0.0.1 config.properties`