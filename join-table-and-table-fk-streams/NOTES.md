# Run docker-compose 
`docker-compose up -d`

# Build it 
`gradle wrapper`
`./gradlew build`
`./gradlew shadowJar`

# Run it 
`java -jar build/libs/ktable-fkjoins-standalone-0.0.1.jar configuration/dev.properties`

# Load some input data (on album)
```
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic albums --bootstrap-server broker:9092 \
--property "parse.key=true"\
--property 'key.schema={"type":"long"}'\
--property "key.separator=:"\
--property value.schema="$(< src/main/avro/album.avsc)"
```
```
5:{"id": 5, "title": "Physical Graffiti", "artist": "Led Zeppelin", "genre": "Rock"}
6:{"id": 6, "title": "Highway to Hell",   "artist": "AC/DC", "genre": "Rock"}
7:{"id": 7, "title": "Radio", "artist": "LL Cool J",  "genre": "Hip hop"}
8:{"id": 8, "title": "King of Rock", "artist": "Run-D.M.C", "genre": "Rap rock"}
```

# Observe output topic 
`docker exec -it schema-registry /usr/bin/kafka-avro-console-consumer --topic music-interest --bootstrap-server broker:9092 --from-beginning`

# Generate some more input data (on purchase)
```
docker exec -i schema-registry /usr/bin/kafka-avro-console-producer --topic purchases --bootstrap-server broker:9092 \
  --property "parse.key=true"\
  --property 'key.schema={"type":"long"}'\
  --property "key.separator=:"\
  --property value.schema="$(< src/main/avro/track-purchase.avsc)"
```
```
100:{"id": 100, "album_id": 5, "song_title": "Houses Of The Holy", "price": 0.99}
101:{"id": 101, "album_id": 8, "song_title": "King Of Rock", "price": 0.99}
102:{"id": 102, "album_id": 6, "song_title": "Shot Down In Flames", "price": 0.99}
103:{"id": 103, "album_id": 7, "song_title": "Rock The Bells", "price": 0.99}
104:{"id": 104, "album_id": 8, "song_title": "Can You Rock It Like This", "price": 0.99}
105:{"id": 105, "album_id": 6, "song_title": "Highway To Hell", "price": 0.99}
106:{"id": 106, "album_id": 5, "song_title": "Kashmir", "price": 0.99}
```

# Expect output in output topic
```
{"id": "5-100", "genre": "Rock", "artist": "Led Zeppelin"}
{"id": "8-101", "genre": "Rap rock", "artist": "Run-D.M.C"}
{"id": "6-102", "genre": "Rock", "artist": "AC/DC"}
{"id": "7-103", "genre": "Hip hop", "artist": "LL Cool J"}
{"id": "8-104", "genre": "Rap rock", "artist": "Run-D.M.C"}
{"id": "6-105", "genre": "Rock", "artist": "AC/DC"}
{"id": "5-106", "genre": "Rock", "artist": "Led Zeppelin"}
```

# Test it 
`./gradlew test`

# Build docker image 
`gradle jibDockerBuild --image=io.confluent.developer/ktable-fkjoins:0.0.1`

# RUn docker container 
`docker run -v $PWD/configuration/prod.properties:/config.properties io.confluent.developer/ktable-fkjoins:0.0.1 config.properties`