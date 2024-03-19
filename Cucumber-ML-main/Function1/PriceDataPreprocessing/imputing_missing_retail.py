"""
Data Preprocessing

The code performs data preprocessing on the dataset by filling missing retail prices using neighboring
locations and dropping records with missing retail prices in months where no suitable values can be
found.

:param group: The "group" parameter refers to a group of data that is grouped by year and month. It
is used in the function "fill_missing_retail_prices_group" to fill missing retail prices for each
month
:return: The code does not explicitly return any value. It performs data preprocessing tasks such as
handling missing values, filling missing retail prices using neighbor mapping, dropping records with
missing retail prices, and saving the cleaned dataset to a new file.

v0.2
"""

import pandas as pd

# Load the dataset
data_file = "./Datasets/imputed_wholesale_retail_part1_dataset.csv"
dataset = pd.read_csv(data_file)

# Load the neighbor mapping data
neighbor_mapping_file = "./SriLankaCityMapping/location_list_mapping.csv"
neighbor_mapping = pd.read_csv(neighbor_mapping_file)

# Handle Missing Values
## Count the number of missing values in each column
print("Before Imputation:")
print(dataset.isnull().sum())

# Group the data by year and month
grouped = dataset.groupby(['year', 'month'])

# Function to fill missing retail prices using neighbors for each month
def fill_missing_retail_prices_group(group):
    for index, row in group.iterrows():
        if pd.isnull(row['retail_price']):
            location = row['location']
        
            # Check if there are two neighbor locations with retail prices
            neighbors = neighbor_mapping.loc[neighbor_mapping['locations'] == location].values[0][1:3]
            for neighbor in neighbors:
                neighbor_retail_prices = group.loc[group['location'] == neighbor, 'retail_price']
                if not neighbor_retail_prices.isnull().all():
                    group.at[index, 'retail_price'] = round(neighbor_retail_prices.mean(), 2)
                    break

            # If no neighbors with retail prices are found, use an iterative approach
            if pd.isnull(group.at[index, 'retail_price']):
                for neighbor_column in neighbor_mapping.columns[1:]:
                    for neighbor in neighbor_mapping[neighbor_column]:
                        neighbor_retail_prices = group.loc[group['location'] == neighbor, 'retail_price']
                        if not neighbor_retail_prices.isnull().all():
                            group.at[index, 'retail_price'] = round(neighbor_retail_prices.mean(), 2)
                            break

    return group

# Apply the function to fill missing retail prices for each month
dataset = grouped.apply(fill_missing_retail_prices_group)

# Reset the index
dataset.reset_index(drop=True, inplace=True)


# Reload the original dataset to see the difference
dataset_original = pd.read_csv(data_file)

# After Imputation
## Count the number of missing values in each column
print("After Imputation:")
print(dataset.isnull().sum())

# Drop Records
## Drop records with missing retail_price in months where no suitable values can be found
dataset = dataset.dropna(subset=['retail_price'])

# Reset the index
dataset.reset_index(drop=True, inplace=True)

# Save the dataset with filled missing retail prices and cleaned
dataset.to_csv("./Datasets/imputed_wholesale_retail_part2_dataset.csv", index=False)

# After cleaning
## Count the number of missing values in each column
print("After Drop Records:")
print(dataset.isnull().sum())

