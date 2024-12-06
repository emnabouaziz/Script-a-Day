#!/bin/bash

# Check if Kafka container is running
KAFKA_CONTAINER=$(docker ps -qf "ancestor=wurstmeister/kafka")
if [ -z "$KAFKA_CONTAINER" ]; then
  echo "Error: Kafka container is not running. Please start it with 'docker-compose up -d'."
  exit 1
fi

# Main menu
echo "Select an operation:"
echo "1. Create a topic"
echo "2. Produce messages"
echo "3. Consume messages"
read -p "Enter your choice (1/2/3): " CHOICE

# Create a topic
if [ "$CHOICE" -eq 1 ]; then
  read -p "Enter topic name: " TOPIC_NAME
  read -p "Enter number of partitions: " PARTITIONS
  read -p "Enter replication factor: " REPLICATION_FACTOR

  docker exec -it "$KAFKA_CONTAINER" kafka-topics.sh \
    --create \
    --topic "$TOPIC_NAME" \
    --bootstrap-server localhost:9092 \
    --partitions "$PARTITIONS" \
    --replication-factor "$REPLICATION_FACTOR"

  if [ $? -eq 0 ]; then
    echo "Topic '$TOPIC_NAME' created successfully with $PARTITIONS partition(s) and replication factor of $REPLICATION_FACTOR."
  else
    echo "Error: Failed to create topic '$TOPIC_NAME'."
  fi

# Produce messages
elif [ "$CHOICE" -eq 2 ]; then
  read -p "Enter topic name: " TOPIC_NAME

  echo "Producing messages to topic '$TOPIC_NAME'. Type messages and press Enter (Ctrl+C to stop):"
  docker exec -it "$KAFKA_CONTAINER" kafka-console-producer.sh \
    --broker-list localhost:9092 \
    --topic "$TOPIC_NAME"

# Consume messages
elif [ "$CHOICE" -eq 3 ]; then
  read -p "Enter topic name: " TOPIC_NAME

  echo "Consuming messages from topic '$TOPIC_NAME':"
  docker exec -it "$KAFKA_CONTAINER" kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic "$TOPIC_NAME" \
    --from-beginning

else
  echo "Invalid choice. Please select 1, 2, or 3."
fi
