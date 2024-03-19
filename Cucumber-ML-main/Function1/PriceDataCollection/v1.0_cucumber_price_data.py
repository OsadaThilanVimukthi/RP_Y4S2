"""
Collect Cucumber Wholesale and Retail Prices from 
market.ideabeam.com

The website doesn't have a download method.
This is a test script to extract data from the website.

v1.0
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
data = []

header_row = table.find('thead').find('tr')
cities = [city.text.strip() for city in header_row.find_all('th')[1:]]  # Skip the "Date" column

print('Processing data...')

for row in table.find_all('tr')[1:]:
    columns = row.find_all('td')

    if len(columns) == 0:
        continue  # Skip rows with no data

    # Extract data from columns
    date = columns[0].text.strip()
    date_data = [date]

    for i, city in enumerate(cities):
        if len(columns) > i * 2 + 2:
            retail_price = columns[i * 2 + 1].find('span', class_='priceSpan retail_price_filter_p')
            wholesale_price = columns[i * 2 + 2].find('span', class_='priceSpan wholesale_price_filter_p')
            
            if retail_price is not None:
                retail_price = retail_price.text.strip()
            else:
                retail_price = 'NaN'
                
            if wholesale_price is not None:
                wholesale_price = wholesale_price.text.strip()
            else:
                wholesale_price = 'NaN'
        else:
            retail_price = 'NaN'
            wholesale_price = 'NaN'

        date_data.extend([wholesale_price, retail_price])

    data.append(date_data)

# Create a dataframe
df = pd.DataFrame(data, columns=["Date"] + [f"{city} Wholesale Price" for city in cities] + [f"{city} Retail Price" for city in cities])

# Print the first few rows of the dataframe
print('Data processing completed. Here are the first few rows of the dataframe:')
print(df.head())




