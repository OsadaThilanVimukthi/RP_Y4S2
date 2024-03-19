"""
Data Preprocessing
Check how many records will be dropped if remove rows where 
both "wholesale_price" and "retail_price" have missing values.

The code is performing data preprocessing tasks on a dataset. Specifically, it is checking how many
records will be dropped if rows where both "wholesale_price" and "retail_price" have missing values
are removed. It loads the dataset from a CSV file, displays the first few rows of the dataset,
counts the number of missing values in each column, drops rows with missing values in both
"wholesale_price" and "retail_price", and calculates the number of records dropped. It also checks
the number of missing values after cleaning and extracts unique location names from the cleaned
dataset. Finally, it prints the list of unique location names.

v0.0
"""

# Import the required libraries
import pandas as pd
import numpy as np

# Load the dataset
data_file = "./Datasets/all_price_data.csv"
dataset = pd.read_csv(data_file)

# Display the first few rows of the dataset to get an overview
print(dataset.head())

# Handle Missing Values
## Count the number of missing values in each column
print(dataset.isnull().sum())

# Count the number of records before dropping
num_records_before = len(dataset)

# Drop rows where both 'wholesale_price' and 'retail_price' are missing
dataset_cleaned = dataset.dropna(subset=['wholesale_price', 'retail_price'], how='all')

# Count the number of records after dropping
num_records_after = len(dataset_cleaned)

# Calculate how many records were dropped
num_records_dropped = num_records_before - num_records_after

# Display the number of records dropped
print("Number of records dropped:", num_records_dropped)

# Check the number of missing values after cleaning
print(dataset_cleaned.isnull().sum())

# Extract location names from your dataset
data_locations = dataset_cleaned['location'].unique()

# Print the list of unique location names from the cleaned dataset
print("\nUnique location names in the cleaned dataset:")
for location in data_locations:
    print(location)

