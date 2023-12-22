from json import loads
from kafka import KafkaConsumer
import datetime 
import sys

# Check if the correct number of command-line arguments is provided
if len(sys.argv) != 4:
    print("Error\nUse format: python3 consumer.py <topic> <host> <file_name>")
    sys.exit(1)

# Assign command-line arguments to variables
topic = sys.argv[1]
host = sys.argv[2]
file_name = sys.argv[3]

# Open/Create collection file 
f = open(file_name, 'a')

# Generating the Kafka Consumer  
kafka_consumer = KafkaConsumer(topic, bootstrap_servers = [host], auto_offset_reset = 'latest', 
                 value_deserializer = lambda x : loads(x.decode('utf-8')), consumer_timeout_ms=5000)

# Log current time
now = str(datetime.datetime.now())
f.write('Timestamp:' + now + '\n')

for message in kafka_consumer:
    #inserting the messages to the collection file
    f.write(str(message.value) + '\n')

kafka_consumer.close()
f.close()