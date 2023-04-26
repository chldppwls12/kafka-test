## Kafka CDC test with Docker compose

![](https://velog.velcdn.com/images/chldppwls12/post/64b7ad5f-3368-4365-80db-21ac274afe76/image.png)

docker compose를 사용해 Kafka CDC를 이용하는 간단한 예시

주키퍼 3개로 구성된 주키퍼 클러스터와 브로커 3개로 구성된 브로커(=카프카) 클러스터가 있으며 MySQL -> MySQL로 백업하기 위한 코드

### How to use
#### 1. Start docker compose
```
$ sudo docker-compose up -d
```
#### 2. Set Connector by Rest API
**source Connector**
```
curl -d '{
  "name": "testdb-connector",  
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "tasks.max": "1",
    "database.hostname": "mysql",
    "database.port": "3306",
    "database.user": "mysqluser",
    "database.password": "mysqlpw",
    "database.server.id": "184054",
    "topic.prefix": "dbserver1",
    "database.include.list": "testdb", 
    "database.allowPublicKeyRetrieval":"true",
    "schema.history.internal.kafka.bootstrap.servers": "kafka1:9092,kafka2:9092,kafka3:9092",
    "schema.history.internal.kafka.topic": "schema-changes.testdb"  
  }
}' \
-H "Content-Type: application/json" \
-X http://${ip_address}:${port}/connectors
```
**sink Connector**
```
curl -d '{
    "name": "sink-testdb-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": "1",
        "connection.url": "jdbc:mysql://sink-mysql:3306/testdb",
        "connection.user": "mysqluser",
        "connection.password": "mysqlpw",
        "auto.create": "false",
        "auto.evolve": "false",
        "delete.enabled": "true",
        "insert.mode": "upsert",
        "pk.mode": "record_key",
        "topics.regex": "dbserver1.testdb.(.*)",
        "table.name.format": "${topic}",
        "tombstones.on.delete": "true",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "true",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "true",
        "transforms": "unwrap,route,TimestampConverter",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": false,
        "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.route.regex": "([^.]+)\\.([^.]+)\\.([^.]+)",
        "transforms.route.replacement": "$3",
        "transforms.TimestampConverter.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value", 
        "transforms.TimestampConverter.format": "yyyy-MM-dd HH:mm:ss", 
        "transforms.TimestampConverter.target.type": "Timestamp", 
        "transforms.TimestampConverter.field": "update_date"
    }
}' \
-H "Content-Type: application/json" \
-X http://146.56.151.86:8083/connector
```
##