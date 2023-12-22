#!/bin/bash

#For each api, call the py files every minute
BOOTSTRAP_SERVER="localhost:9092"


while true; do
    echo "Getting Data from APIS"

    #Run the producer scripts
    python3 data_collection/coinmarketcap.py $BOOTSTRAP_SERVER &
    python3 data_collection/coingecko.py $BOOTSTRAP_SERVER &

    #Run the consumer scripts
    python3 data_collection/consumer.py "coinmarketcap" $BOOTSTRAP_SERVER "coinmarketcap_data.txt" &
    python3 data_collection/consumer.py "coingecko" $BOOTSTRAP_SERVER "coingecko_data.txt" &



    sleep 60
done