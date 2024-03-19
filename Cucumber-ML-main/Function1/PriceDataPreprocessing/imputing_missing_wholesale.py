"""
Data Preprocessing

The code performs data preprocessing on the dataset by handling missing wholesale_price values 
and filling them using the mean percentage difference between wholesale and retail prices for each month.

:param group: The "group" parameter is a group of rows from the dataset that have been grouped based
on the "year" and "month" columns
:return: The code does not explicitly return any value. It performs data preprocessing tasks such as
handling missing values and filling them based on calculated mean percentage differences. It also
saves the preprocessed dataset to a new CSV file.

v0.3
"""

import pandas as pd

# Load the dataset
data_file = "./Datasets/imputed_wholesale_retail_part2_dataset.csv"
dataset = pd.read_csv(data_file)

# Display the first few rows of the dataset to get an overview
print(dataset.head())

# Handle Missing Values
## Count the number of missing values in each column
print("Before Imputation:")
print(dataset.isnull().sum())

# Define a function to calculate the percentage difference
def calculate_percentage_difference(group):
    wholesale_price = group['wholesale_price']
    retail_price = group['retail_price']
    
    # Calculate percentage difference only if both prices are available
    if not pd.isnull(wholesale_price).all() and not pd.isnull(retail_price).all():
        return ((retail_price - wholesale_price) / wholesale_price).mean()
    return None

# Group the data by year and month
grouped = dataset.groupby(['year', 'month'])

# Calculate the mean percentage difference for each month
mean_percentage_differences = grouped.apply(calculate_percentage_difference)

# Fill missing values based on the calculated mean percentage differences
for index, row in dataset.iterrows():
    if pd.isnull(row['wholesale_price']) and not pd.isnull(row['retail_price']):
        # Fill missing wholesale_price using the mean percentage difference for the month
        month = row['month']
        dataset.at[index, 'wholesale_price'] = round(row['retail_price'] / (1 + mean_percentage_differences.get((row['year'], month), 0)), 2)

# Save the dataset with filled missing values
dataset.to_csv("./Datasets/final_wholesale_retail_dataset_v0.0.csv", index=False)

# Reload the original dataset to see the difference
dataset_original = pd.read_csv(data_file)

# After Imputation
## Count the number of missing values in each column
print("After Imputation:")
print(dataset.isnull().sum())

## Handle Missing Values - Completed