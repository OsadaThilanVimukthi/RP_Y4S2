"""
Data Preprocessing - Dataset Analysis
The script is performing data preprocessing and analysis on the dataset.

v1.0
"""

import pandas as pd
import matplotlib.pyplot as plt

# Load the dataset
data_file = "./Datasets/final_wholesale_retail_dataset_v0.0.csv"
dataset = pd.read_csv(data_file)

# Display the first few rows of the dataset to get an overview
print(dataset.head())

# Separate independent (X) and dependent (y) variables
X = dataset.iloc[:, :-2]  # Select all columns except the last two
y = dataset.iloc[:, -2:]  # Select the last two columns

# Display the first few rows of X and y
print("Independent variables (X):")
print(X.head())

print("\nDependent variables (y):")
print(y.head())


# Dataset Analysis
## Summary Statistics
print("\nSummary Statistics:")
print(dataset.describe())

## Time Series Plot
plt.figure(figsize=(20, 8))
plt.plot(dataset['year'].astype(str) + '-' + dataset['month'].astype(str), 
             dataset['wholesale_price'], label='Wholesale Price', marker='o', linestyle='-', color='blue')
plt.plot(dataset['year'].astype(str) + '-' + dataset['month'].astype(str), 
             dataset['retail_price'], label='Retail Price', marker='o', linestyle='-', color='orange')
plt.title('Monthly Price Trends')
plt.xlabel('Year-Month')
plt.ylabel('Price')
plt.xticks(rotation=45)
plt.legend()
plt.grid(True)
plt.show()

# Correlation Analysis
correlation_matrix = dataset[['wholesale_price', 'retail_price']].corr()

# Create a heatmap to visualize the correlation matrix
plt.figure(figsize=(6, 6))
plt.imshow(correlation_matrix, cmap='coolwarm', interpolation='nearest')
plt.colorbar()
plt.title('Correlation Heatmap (wholesale_price & retail_price)')
plt.xticks([0, 1], ['wholesale_price', 'retail_price'])
plt.yticks([0, 1], ['wholesale_price', 'retail_price'])
plt.show()

## Histograms
### Distribution of Price data - After Imputation
plt.figure(figsize=(12, 6))
plt.subplot(1, 2, 1)
plt.hist(dataset['wholesale_price'], bins=20, color='skyblue', edgecolor='black')
plt.title('Distribution of Wholesale Prices')
plt.xlabel('Price')
plt.ylabel('Frequency')
plt.grid(axis='y', linestyle='--', alpha=0.7)

plt.subplot(1, 2, 2)
plt.hist(dataset['retail_price'], bins=20, color='skyblue', edgecolor='black')
plt.title('Distribution of Retail Prices')
plt.xlabel('Price')
plt.ylabel('Frequency')
plt.grid(axis='y', linestyle='--', alpha=0.7)

plt.tight_layout()
plt.show()

