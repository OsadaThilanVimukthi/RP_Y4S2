"""
Particle Swarm Optimization (PSO)
Perform PSO optimization to find the best hyperparameters

Error:
    raise ValueError(
ValueError: y should be a 1d array, got an array of shape (1400, 2) instead.

v0.0
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import OneHotEncoder
from sklearn.multioutput import MultiOutputRegressor
from sklearn.svm import SVR
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
import pyswarms as ps


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


from sklearn.model_selection import GridSearchCV

# Define SVR model
svr_model = SVR(kernel='rbf')

# Define hyperparameter grid to search
param_grid = {
    'C': [1, 2, 4],
    'gamma': [0.001, 0.002, 0.004],
    'epsilon': [0.001, 0.002, 0.004]
}

# Create a grid search with cross-validation
grid_search = GridSearchCV(estimator=svr_model, param_grid=param_grid, cv=3, scoring='neg_mean_squared_error', n_jobs=-1)

# Fit the grid search to find the best hyperparameters
grid_search.fit(X_train, y_train)

# Get the best hyperparameters
best_params = grid_search.best_params_
print("Best Hyperparameters:", best_params)

# Train the SVR model with the best hyperparameters
best_svr_model = SVR(kernel='rbf', C=best_params['C'], gamma=best_params['gamma'], epsilon=best_params['epsilon'])
multioutput_svr_model = MultiOutputRegressor(best_svr_model)
multioutput_svr_model.fit(X_train, y_train)

# Evaluate the model
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

