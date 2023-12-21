import json
import requests
import pandas as pd
from time import sleep
from kafka import KafkaProducer

#initialise the kafka producer object
kafka_producer = KafkaProducer(bootstrap_servers = ['localhost:9092'],  
                value_serializer = lambda x:json.dumps(x).encode('utf-8'))

#read the data from api
url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"

headers = {
    'X-CMC_PRO_API_KEY': "a458f36f-26ab-41b3-b895-16b1770cbbfa",
    'Accepts' : 'application/json'
}

params = {
    'start' : '1',
    'limit' : '250',
    'convert' : 'USD'
}

data_json = requests.get(url, params=params, headers=headers).json()

data = data_json['data']


#iterating over list of dictionaries and sending each record to Kafka Cluster 
for coin in data:
    name = coin['name']
    price = coin['quote']['USD']['price']
    print(f"{name}: {price}")
    kafka_producer.send('data', value = f"{name}: {price},")
    # kafka_producer.send('data', value = f"{{\"{name}\": {price}}},")
    sleep(0.01)



