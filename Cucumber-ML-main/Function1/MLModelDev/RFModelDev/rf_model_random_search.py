"""
Random Forest Model Development - Random Search
Train & Test Percentages: 
    Train set percentage: 79.97%
    Test set percentage: 20.03%

v2.0
"""

import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import OneHotEncoder
from sklearn.model_selection import train_test_split

# Load the dataset
data_file = "./Datasets/final_wholesale_retail_dataset_v0.0.csv"
dataset = pd.read_csv(data_file)

# Display the first few rows of the dataset to get an overview
print(dataset.head())

# Separate independent (X) and dependent (y) variables
X = dataset.iloc[:, :-2]  # Select all columns except the last two
y = dataset.iloc[:, -2:]  # Select the last two columns

# Display the first few rows of X and y
print("\nIndependent variables (X):")
print(X.head())

print("\nDependent variables (y):")
print(y.head())

# One-Hot Encoding for the 'location' column
encoder = OneHotEncoder(sparse_output=False)
X_encoded = encoder.fit_transform(X[['location']])
X_encoded_df = pd.DataFrame(X_encoded, columns=encoder.get_feature_names_out(['location']))

## Simplify header names by keeping only city names
X_encoded_df.columns = X_encoded_df.columns.str.split('_').str[-1]
X.drop(columns=['location'], inplace=True)  # Drop the original 'location' column
X = pd.concat([X, X_encoded_df], axis=1)  # Concatenate the encoded 'location' columns

# Standardization
scaler = StandardScaler()
X = pd.DataFrame(scaler.fit_transform(X), columns=X.columns)
y = pd.DataFrame(scaler.fit_transform(y), columns=y.columns)

# Display the first few rows of the updated X and y
print("\nUpdated Independent variables (X) after encoding and standardization:")
print(X.head())

print("\nUpdated Dependent variables (y) after standardization:")
print(y.head())


# Train & Test Split
## Split the data into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

## Calculate the percentage of train and test set
total_samples = len(X)
train_samples = len(X_train)
test_samples = len(X_test)

train_percentage = (train_samples / total_samples) * 100
test_percentage = (test_samples / total_samples) * 100

print(f"Train set percentage: {train_percentage:.2f}%")
print(f"Test set percentage: {test_percentage:.2f}%")


# Random Search
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import RandomizedSearchCV
import numpy as np

# Define the parameter distribution for random search
param_dist = {
    'n_estimators': [100, 200, 300, 400, 500],
    'max_depth': [None, 10, 20, 30, 40],
    'min_samples_split': [2, 5, 10, 15, 20],
    'min_samples_leaf': [1, 2, 4, 6, 8],
}

# Create the Random Forest model
rf_model = RandomForestRegressor(random_state=42)

# Create a random search object
random_search = RandomizedSearchCV(rf_model, param_distributions=param_dist, n_iter=10, cv=5, scoring='neg_mean_squared_error')

# Fit the random search to your training data
random_search.fit(X_train, y_train)

# Print the best hyperparameters and the corresponding performance
print("Best Hyperparameters:", random_search.best_params_)
print("Best Negative Mean Squared Error:", random_search.best_score_)

# Convert negative mean squared error to RMSE
best_rmse = np.sqrt(-random_search.best_score_)
print("Best RMSE:", best_rmse)


### Output ###

# Best Hyperparameters: {'n_estimators': 500, 'min_samples_split': 5, 'min_samples_leaf': 1, 'max_depth': None}
# Best Negative Mean Squared Error: -0.21472825598914755
# Best RMSE: 0.4633878030215594

