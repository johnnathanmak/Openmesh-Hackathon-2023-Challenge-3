import json
import requests
import pandas as pd
from time import sleep
from kafka import KafkaProducer

#initialise the kafka producer object
kafka_producer = KafkaProducer(bootstrap_servers = ['localhost:9092'],  \
                value_serializer = lambda x:json.dumps(x).encode('utf-8'))

#read the data from api
url = "https://api.coingecko.com/api/v3/coins/markets"

headers = {
    'x-cg-demo-api-key': "CG-8NYK8fom6VEfGCw3K3gjZM4p",
    'Accepts' : 'application/json'
}

params = {
    'vs_currency' : 'usd',
    'per_page' : '250',
    'precision' : 'full'
}

data_json = requests.get(url, params=params, headers=headers).json()

#iterating over list of dictionaries and sending each record to Kafka Cluster 
for coin in data_json:
    name = coin['name']
    price = coin['current_price']
    # print(f"{name}: {price}")
    kafka_producer.send('coingecko', value = f"{name}: {price},")
    sleep(0.01)

