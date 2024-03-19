"""
This script will correctly match the year, month, 
and location to the corresponding wholesale and retail prices in the CSV files.  
Finally, it saves the merged data to the "all_price_data.csv" file.

v0.1 - Final
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
            data.append([str(year), str(month), location, None, None])

# Load the wholesale and retail price data
wholesale_data = []
with open("./RawData/wholesale_price_data.csv", "r") as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader)  # Skip the header row
    for row in csvreader:
        wholesale_data.append(row)

retail_data = []
with open("./RawData/retail_price_data.csv", "r") as csvfile:
    csvreader = csv.reader(csvfile)
    next(csvreader)  # Skip the header row
    for row in csvreader:
        retail_data.append(row)

# Update the data with wholesale and retail prices
for i in range(len(data)):
    year, month, location, _, _ = data[i]  # Extract year, month, and location

    for row in wholesale_data:
        w_year = row[0]
        w_location = row[1]
        if w_year == year and w_location == location:
            for j in range(2, 14):  # Columns with wholesale prices
                data[i][3] = row[int(month) + 1]

    for row in retail_data:
        r_year = row[0]
        r_location = row[1]
        if r_year == year and r_location == location:
            for j in range(2, 14):  # Columns with retail prices
                data[i][4] = row[int(month) + 1]

# Save the merged data to a new CSV file
output_file = "./RawData/all_price_data.csv"
with open(output_file, "w", newline="") as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(["year", "month", "location", "wholesale_price", "retail_price"])
    csvwriter.writerows(data)

print(f"Merged price data saved to {output_file}")

