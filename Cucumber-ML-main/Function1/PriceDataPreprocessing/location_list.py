"""
This script extract and print all the unique location names available 
in all_price_data.csv files.

"""

import csv

# Function to extract unique location names from a CSV file
def extract_locations(csv_file):
    locations = set()
    with open(csv_file, "r") as csvfile:
        csvreader = csv.reader(csvfile)
        next(csvreader)  # Skip the header row
        for row in csvreader:
            location = row[2]
            if location:
                locations.add(location)
    return list(locations)

# Extract location names from your dataset
data_file = "./Datasets/all_price_data.csv"
data_locations = extract_locations(data_file)

# Print the list of unique location names from the dataset
print("Unique location names in all_price_data.csv:")
for location in data_locations:
    print(location)

