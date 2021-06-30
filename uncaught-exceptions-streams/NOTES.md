# Build 
`gralde wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Run 
`java -jar build/libs/error-handling-standalone-0.0.1.jar configuration/dev.properties`

# Observe output topic
`docker-compose exec broker kafka-console-consumer \
--bootstrap-server broker:9092 \
--topic output-topic \
--from-beginning \
--max-messages 12
`

# Test it 
`./gradlew test`

# Build docker image
`gradle jibDockerBuild --image=io.confluent.developer/error-handling-join:0.0.1`

# Run docker container 
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/error-handling-join:0.0.1 config.properties`