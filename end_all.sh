#!/bin/bash

# Directory containing Kafka configuration files
CONFIG_DIR="config"

# Check if the Kafka server stop command is available
KAFKA_SERVER_STOP="bin/kafka-server-stop.sh"

if [ ! -f "$KAFKA_SERVER_STOP" ]; then
  echo "Error: Kafka server stop script not found at $KAFKA_SERVER_STOP."
  exit 1
fi

# Directory where the PID and broker.id mapping text file is stored
PID_DIR="pid_data"

# Check if the pid_data directory exists
if [ ! -d "$PID_DIR" ]; then
  echo "Error: Directory $PID_DIR does not exist. Please run the broker startup script first."
  exit 1
fi

# Check if the pid_broker_mapping.txt file exists
pid_mapping_file="$PID_DIR/pid_broker_mapping.txt"
if [ ! -f "$pid_mapping_file" ]; then
  echo "Error: File $pid_mapping_file does not exist. Please run the broker startup script first."
  exit 1
fi

# Read the PID and broker.id mappings and stop Kafka brokers
while IFS= read -r line; do
  broker_id=$(echo "$line" | awk -F ', ' '{print $1}' | cut -d ' ' -f3)
  pid=$(echo "$line" | awk -F ', ' '{print $2}' | cut -d ' ' -f2)
  
  echo "Stopping Kafka broker (Broker ID: $broker_id, PID: $pid)..."
  "$KAFKA_SERVER_STOP" "$CONFIG_DIR/server-$broker_id.properties"
done < "$pid_mapping_file"

# Delete all files in the format server-x.properties
for configFile in "$CONFIG_DIR"/server-*.properties; do
  if [ -e "$configFile" ]; then
    echo "Deleting $configFile..."
    rm "$configFile"
  fi
done

# Prompt the user to delete specific data directories
read -p "Do you want to delete data directories? (Y/n): " answer
if [ "$answer" == "Y" ]; then
  rm -rf /tmp/kafka-logs-* /tmp/zookeeper /tmp/kraft-combined-logs
  echo "Data directories deleted."
else
  echo "Data directories were not deleted."
fi

rm "$PID_DIR/pid_broker_mapping.txt"