#!/bin/bash

#For each api, call the py files every minute
BOOTSTRAP_SERVER = "localhost:9092"


while true; do
    echo "Getting Data from APIS"

    #Run the producer scripts
    bash ./coinmarketcap.py $BOOTSTRAP_SERVER
    bash ./coingecko.py $BOOTSTRAP_SERVER

    #Run the consumer scripts
    bash ./consumer.py "coinmarketcap" $BOOTSTRAP_SERVER "coinmarketcap_data.txt"
    bash ./consumer.py "coingecko" $BOOTSTRAP_SERVER "coingecko_data.txt"



    sleep 60
done