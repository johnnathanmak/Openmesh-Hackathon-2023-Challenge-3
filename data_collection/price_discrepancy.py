import json

def compare_prices(api_files):
    # Create a dictionary to store prices for each API
    api_prices = {}

    # Load data from files
    for api_file in api_files:
        with open(api_file, 'r') as file:
            api_prices[api_file] = {key: float(value) for key, value in (line.strip().strip(',').split(':')\
                for line in file if "timestamp" not in line.lower())}
    
    # Extract the list of cryptocurrencies
    cryptocurrencies = set().union(*(api.keys() for api in api_prices.values()))

    # Compare prices for each cryptocurrency
    for coin in cryptocurrencies:
        prices = [api_prices[api].get(coin, None) for api in api_files]
        if all(prices):  # Check if the coin is present in all APIs
            discrepancies = [prices[i] - prices[i - 1] for i in range(1, len(prices))]
            print(f"{coin}: Prices - {', '.join(map(str, prices))}, Discrepancies - {', '.join(map(str, discrepancies))}")

if __name__ == "__main__":
    api_files = ["./coinmarketcap_data.txt", "./coingecko_data.txt"]  

    compare_prices(api_files)