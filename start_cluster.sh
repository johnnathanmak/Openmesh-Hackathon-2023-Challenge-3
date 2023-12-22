#!/bin/bash

# Check if the user provided the number of brokers
if [ $# -ne 1 ]; then
  echo "Usage: $0 <number_of_brokers>"
  exit 1
fi

NUM_BROKERS=$1

# Base port number for the first broker
BASE_PORT=9092

# Directory containing Kafka configuration files
CONFIG_DIR="config"

# Check if the Kafka server start command is available
KAFKA_SERVER_START="bin/kafka-server-start.sh"

if [ ! -f "$KAFKA_SERVER_START" ]; then
  echo "Error: Kafka server start script not found at $KAFKA_SERVER_START."
  exit 1
fi

# Directory to store PID and broker.id mapping
PID_DIR="pid_data"

# Ensure the PID_DIR directory exists
mkdir -p "$PID_DIR"

# Get a list of Kafka configuration files matching the pattern server-*.properties
config_files=("$CONFIG_DIR"/server-*.properties)

# Check if there are any configuration files
if [ ${#config_files[@]} -eq 0 ]; then
  echo "No Kafka configuration files found in $CONFIG_DIR."
  exit 1
fi

# Start Kafka brokers for each configuration file and record PID
for ((i=0; i<NUM_BROKERS; i++)); do
  CONFIG_FILE="$CONFIG_DIR/server-$i.properties"
  
  # Calculate the listener port for this broker
  LISTENER_PORT=$((BASE_PORT + i))
  
  # Create a new server-x.properties file if it doesn't exist
  if [ ! -e "$CONFIG_FILE" ]; then
    echo "Creating $CONFIG_FILE..."
    cat <<EOF > "$CONFIG_FILE"
############################# Server Basics #############################

# The id of the broker. This must be set to a unique integer for each broker.
broker.id=$i

############################# Socket Server Settings #############################

# The address the socket server listens on. If not configured, the host name will be equal to the value of
# java.net.InetAddress.getCanonicalHostName(), with PLAINTEXT listener name, and port 9092.
#   FORMAT:
#     listeners = listener_name://host_name:port
#   EXAMPLE:
#     listeners = PLAINTEXT://your.host.name:9092
listeners=PLAINTEXT://localhost:$LISTENER_PORT

# Listener name, hostname and port the broker will advertise to clients.
# If not set, it uses the value for "listeners".
#advertised.listeners=PLAINTEXT://your.host.name:$LISTENER_PORT

# Maps listener names to security protocols, the default is for them to be the same. See the config documentation for more details
#listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

# The number of threads that the server uses for receiving requests from the network and sending responses to the network
num.network.threads=3

# The number of threads that the server uses for processing requests, which may include disk I/O
num.io.threads=8

# The send buffer (SO_SNDBUF) used by the socket server
socket.send.buffer.bytes=102400

# The receive buffer (SO_RCVBUF) used by the socket server
socket.receive.buffer.bytes=102400

# The maximum size of a request that the socket server will accept (protection against OOM)
socket.request.max.bytes=104857600

############################# Log Basics #############################

# A comma separated list of directories under which to store log files
log.dirs=/tmp/kafka-logs-$i

# The default number of log partitions per topic. More partitions allow greater
# parallelism for consumption, but this will also result in more files across
# the brokers.
num.partitions=1

# The number of threads per data directory to be used for log recovery at startup and flushing at shutdown.
# This value is recommended to be increased for installations with data dirs located in RAID array.
num.recovery.threads.per.data.dir=1

############################# Internal Topic Settings  #############################
# The replication factor for the group metadata internal topics "__consumer_offsets" and "__transaction_state"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

############################# Log Flush Policy #############################

# Messages are immediately written to the filesystem but by default we only fsync() to sync
# the OS cache lazily. The following configurations control the flush of data to disk.
# There are a few important trade-offs here:
#    1. Durability: Unflushed data may be lost if you are not using replication.
#    2. Latency: Very large flush intervals may lead to latency spikes when the flush does occur as there will be a lot of data to flush.
#    3. Throughput: The flush is generally the most expensive operation, and a small flush interval may lead to excessive seeks.
# The settings below allow one to configure the flush policy to flush data after a period of time or
# every N messages (or both). This can be done globally and overridden on a per-topic basis.

# The number of messages to accept before forcing a flush of data to disk
#log.flush.interval.messages=10000

# The maximum amount of time a message can sit in a log before we force a flush
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################

# The following configurations control the disposal of log segments. The policy can
# be set to delete segments after a period of time, or after a given size has accumulated.
# A segment will be deleted whenever *either* of these criteria are met. Deletion always happens
# from the end of the log.

# The minimum age of a log file to be eligible for deletion due to age
log.retention.hours=168

# A size-based retention policy for logs. Segments are pruned from the log unless the remaining
# segments drop below log.retention.bytes. Functions independently of log.retention.hours.
#log.retention.bytes=1073741824

# The maximum size of a log segment file. When this size is reached a new log segment will be created.
#log.segment.bytes=1073741824

# The interval at which log segments are checked to see if they can be deleted according
# to the retention policies
log.retention.check.interval.ms=300000

############################# Zookeeper #############################

# Zookeeper connection string (see zookeeper docs for details).
# This is a comma separated host:port pairs, each corresponding to a zk
# server. e.g. "127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002".
# You can also append an optional chroot string to the urls to specify the
# root directory for all kafka znodes.
zookeeper.connect=localhost:2181

# Timeout in ms for connecting to zookeeper
zookeeper.connection.timeout.ms=18000

############################# Group Coordinator Settings #############################

# The following configuration specifies the time, in milliseconds, that the GroupCoordinator will delay the initial consumer rebalance.
# The rebalance will be further delayed by the value of group.initial.rebalance.delay.ms as new members join the group, up to a maximum of max.poll.interval.ms.
# The default value for this is 3 seconds.
# We override this to 0 here as it makes for a better out-of-the-box experience for development and testing.
# However, in production environments the default value of 3 seconds is more suitable as this will help to avoid unnecessary, and potentially expensive, rebalances during application startup.
group.initial.rebalance.delay.ms=0
EOF
  else
    echo "$CONFIG_FILE already exists. Skipping..."
  fi

  # Start Kafka broker for this configuration file and record PID
  "$KAFKA_SERVER_START" "$CONFIG_FILE" > "$PID_DIR/broker-$i.log" 2>&1 &
  broker_pid=$!
  echo "Started Kafka broker $i using configuration: $CONFIG_FILE (PID: $broker_pid)"

  # Store the PID and broker.id mapping in a text file
  echo "Broker ID: $i, PID: $broker_pid" >> "$PID_DIR/pid_broker_mapping.txt"
  
  # Create a temporary file to indicate broker has started
  touch "$PID_DIR/broker-$i.started"
done

# Wait for all Kafka brokers to start by checking the temporary files
echo "Waiting for all Kafka brokers to start..."
for ((i=0; i<NUM_BROKERS; i++)); do
  while true; do
    if [ -f "$PID_DIR/broker-$i.started" ]; then
      echo "Broker $i is running."
      break
    else
      echo "Waiting for Broker $i to start..."
      sleep 2
    fi
  done
done

# Name of the text file containing topic information
TOPIC_FILE="topics.txt"

# Check if the Kafka topics command is available
KAFKA_TOPICS_CMD="bin/kafka-topics.sh"  # Update with the correct path
if [ ! -x "$KAFKA_TOPICS_CMD" ]; then
  echo "Error: Kafka topics command ($KAFKA_TOPICS_CMD) not found or not executable."
  exit 1
fi

# Check if the topic file exists
if [ ! -e "$TOPIC_FILE" ]; then
  echo "Error: $TOPIC_FILE not found."
  exit 1
fi

# Loop through each line in the topic file (skipping the first line)
while IFS=: read -r topic_name num_partitions replication_factor; do
  # Create the Kafka topic
  "$KAFKA_TOPICS_CMD" --create --topic "$topic_name" --partitions "$num_partitions" --replication-factor "$replication_factor" --bootstrap-server localhost:9092

  if [ $? -eq 0 ]; then
    echo "Created Kafka topic: $topic_name (Partitions: $num_partitions, Replication Factor: $replication_factor)"
  else
    echo "Failed to create Kafka topic: $topic_name"
  fi
done < <(tail -n +2 "$TOPIC_FILE")

# Remove temporary files indicating broker startup
rm -f "$PID_DIR/broker-*.started"
rm -f "$PID_DIR/broker-*.log"

echo "All Kafka brokers are running, and topics have been created."