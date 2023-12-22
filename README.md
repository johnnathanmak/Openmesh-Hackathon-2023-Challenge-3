# Openmesh-Hackathon-2023-Challenge-3
## Dependencies
To make sure this project runs on your local, please pip install kafka-python

## Run the project
You will need three cmd terminals open to run this project. 
1. Start Zookeepers: In terminal 1, run the following code from the root of the repository:
    ./bin/

2. Build Brokers and create Topics: After the zookeepers are running from step 1, type the following code into terminal 2 from the root of the repository:
    ./bin

3. Trigger API calls: Once the brokers and topics are created from step 2, run the following code in terminal 2 from the root of the repository:
    run_api_calls.sh

4. Run discrepancy finding script: Once the coinmarketcap.txt and coingecko.txt files are created run the following code in terminal 3:
    python3 price_discrepancy.py

To manually confirm price discrepancies, choose a crypto with a high price discrepancy and search on the CoinGecko and CoinMarketCap web interfaces for discrepancies. 
