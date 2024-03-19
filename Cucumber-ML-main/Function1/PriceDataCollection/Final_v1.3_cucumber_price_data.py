"""
Collect Cucumber Wholesale and Retail Prices from 
market.ideabeam.com

The website doesn't have a download method.
This is a test script to extract data from the website.

v1.3 - Final

Collect all pages at once
"""

import requests
from bs4 import BeautifulSoup
import pandas as pd

# Initialize lists to store data
data = []

# Define the base URL
base_url = 'https://market.ideabeam.com/i/cucumber/price-history?page_p='

# Iterate through all 19 pages
for page_number in range(1, 20):
    # Define the URL for the current page
    url = f'{base_url}{page_number}'

    # Send an HTTP GET request
    response = requests.get(url)

    # Parse the HTML content
    soup = BeautifulSoup(response.text, 'html.parser')

    # Locate the table
    table = soup.find('table', class_='table table-bordered table-hover table-condensed')

    print(f'Processing data from page {page_number}...')

    for row in table.find_all('tr'):
        columns = row.find_all(['td', 'th'])

        if not columns:
            continue  # Skip rows with no data

        # Extract data from columns
        date = columns[0].text.strip()
        date_data = [date]

        for col in columns[1:]:
            retail_price_span = col.find('span', class_='priceSpan retail_price_filter_p')
            wholesale_price_span = col.find('span', class_='priceSpan wholesale_price_filter_p')

            retail_price = retail_price_span.text.strip() if retail_price_span else 'NaN'
            wholesale_price = wholesale_price_span.text.strip() if wholesale_price_span else 'NaN'

            date_data.extend([wholesale_price, retail_price])

        data.append(date_data)

# Extract city names from the first row (header)
header_row = table.find('thead').find('tr')
cities = [city.text.strip() for city in header_row.find_all('th')][1:]

# Create a dataframe with reordered columns
columns_order = []
for city in cities:
    columns_order.extend([f"{city} Wholesale Price", f"{city} Retail Price"])
df = pd.DataFrame(data, columns=["Date"] + columns_order)

# Print the first few rows of the dataframe
print('Data processing completed. Here are the first few rows of the dataframe from all pages:')
print(df.head())

# Save the DataFrame to a CSV file
csv_file = './PriceData/cucumber_prices_all_pages.csv'
df.to_csv(csv_file, index=False)

print(f'Data from all pages saved to {csv_file}.')

