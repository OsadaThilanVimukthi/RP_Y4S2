"""
Support Vector Regressor (SVR) Model Development
Train & Test Percentages: 
    Train set percentage: 66.18%
    Test set percentage: 33.82%

v1.0
"""

import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import OneHotEncoder

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
years = X['year'].unique()
print("\nUnique years:", years)

## Sort the unique years in descending order and select the two highest years
test_years = sorted(years, reverse=True)[:2]

## Split the data into train and test based on the year column
X_train = X[~X['year'].isin(test_years)]
X_test = X[X['year'].isin(test_years)]
y_train = y[~X['year'].isin(test_years)]
y_test = y[X['year'].isin(test_years)]

## Calculate the percentage of train and test set
total_samples = len(X)
train_samples = len(X_train)
test_samples = len(X_test)

train_percentage = (train_samples / total_samples) * 100
test_percentage = (test_samples / total_samples) * 100

print(f"Train set percentage: {train_percentage:.2f}%")
print(f"Test set percentage: {test_percentage:.2f}%")


# SVR Model Implementation for Multi-Output Regression
from sklearn.multioutput import MultiOutputRegressor
from sklearn.svm import SVR
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np

# Define SVR model with hyperparameters
svr_model = SVR(kernel='rbf', C=1.0, epsilon=0.2)

# Wrap the SVR model for multi-output regression
multioutput_svr_model = MultiOutputRegressor(svr_model)

# Train the multi-output SVR model
multioutput_svr_model.fit(X_train, y_train)

# Predict both 'wholesale_price' and 'retail_price' for the train and test sets
y_train_pred = multioutput_svr_model.predict(X_train)
y_test_pred = multioutput_svr_model.predict(X_test)

# Calculate RMSE and R-squared for train and test sets
train_rmse = np.sqrt(mean_squared_error(y_train, y_train_pred))
test_rmse = np.sqrt(mean_squared_error(y_test, y_test_pred))

train_r2 = r2_score(y_train, y_train_pred)
test_r2 = r2_score(y_test, y_test_pred)

print("\nTrain RMSE: {:.2f}".format(train_rmse))
print("Test RMSE: {:.2f}".format(test_rmse))
print("Train R-squared: {:.2f}".format(train_r2))
print("Test R-squared: {:.2f}".format(test_r2))


