"""
Collect Cucumber Wholesale and Retail Prices from 
market.ideabeam.com

The website doesn't have a download method.
This is a test script to extract data from the website.

V0.0
"""

import requests
from bs4 import BeautifulSoup
import pandas as pd

# Define the URL of the website
url = 'https://market.ideabeam.com/i/cucumber/price-history?page_p=1'

# Send an HTTP GET request
response = requests.get(url)

# Parse the HTML content
soup = BeautifulSoup(response.text, 'html.parser')

# Locate the table
table = soup.find('table', class_='table table-bordered table-hover table-condensed')

# Initialize lists to store data
dates = []
retail_prices = []
wholesale_prices = []

header_row = table.find('thead').find('tr')
cities = [city.text.strip() for city in header_row.find_all('th')[1:]]  # Skip the "Date" column

# Print the column headers
print('Date, Wholesale Prices, Retail Prices, City')

for row in table.find_all('tr')[1:]:
    columns = row.find_all('td')

    if len(columns) == 0:
        continue  # Skip rows with no data

    # Extract data from columns
    date = columns[0].text.strip()

    # Extract and print data for all cities on the same date
    for i, city in enumerate(cities):
        if len(columns) > i * 2 + 2:
            retail_price = columns[i * 2 + 1].find('span', class_='priceSpan retail_price_filter_p').text.strip()
            wholesale_price = columns[i * 2 + 2].find('span', class_='priceSpan wholesale_price_filter_p').text.strip()
        else:
            retail_price = 'NaN'
            wholesale_price = 'NaN'

        # Print the extracted data
        print(f'{date}, {wholesale_price}, {retail_price}, {city}')

        # Append data to lists
        dates.append(date)
        retail_prices.append(retail_price)
        wholesale_prices.append(wholesale_price)


# Create a DataFrame from the lists
data = {'Date': dates, 'Wholesale Prices': wholesale_prices, 'Retail Prices': retail_prices, 'City': cities * len(dates)}
df = pd.DataFrame(data)

# Print the first few rows of the dataframe
print('Data processing completed. Here are the first few rows of the dataframe:')
print(df.head())

# # Save the data to a CSV file
# df.to_csv('cucumber_prices.csv', index=False)
# print('Data saved to cucumber_prices.csv')





