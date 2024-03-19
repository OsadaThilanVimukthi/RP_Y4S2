"""
This script dynamically extracts unique location names from both 
the wholesale and retail CSV files and generates 
the year-month-location data accordingly.

v0.0
"""

import csv

# Function to extract unique location names from a CSV file
def extract_locations(csv_file):
    locations = set()
    with open(csv_file, "r") as csvfile:
        csvreader = csv.reader(csvfile)
        next(csvreader)  # Skip the header row
        for row in csvreader:
            location = row[1]
            if location:
                locations.add(location)
    return list(locations)

# Define the range of years and months
start_year = 2017
end_year = 2022
start_month = 1
end_month = 12

# Extract location names from your wholesale and retail CSV files
wholesale_locations = extract_locations("./RawData/wholesale_price_data.csv")
retail_locations = extract_locations("./RawData/retail_price_data.csv")

# Merge unique location names from both sources
locations = list(set(wholesale_locations) | set(retail_locations))

# Create a list to store the generated data
data = []

# Generate the location and year-month data
for year in range(start_year, end_year + 1):
    for month in range(start_month, end_month + 1):
        for location in locations:
            data.append([year, month, location, None, None])

# Save the data to a CSV file
output_file = "./RawData/year_month_location_data.csv"
with open(output_file, "w", newline="") as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(["year", "month", "location", "wholesale_price", "retail_price"])
    csvwriter.writerows(data)

print(f"Location and year-month data saved to {output_file}")

