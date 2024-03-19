"""
Random Forest Model Development
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
from sklearn.model_selection import train_test_split

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


# SVR Model Implementation for 'wholesale_price'
from sklearn.svm import SVR
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np

svr_model_wholesale = SVR(kernel='rbf', C=4.0, epsilon=0.6)
svr_model_wholesale.fit(X_train, y_train['wholesale_price'])

# SVR Model Implementation for 'retail_price'
svr_model_retail = SVR(kernel='rbf', C=4.0, epsilon=0.6)
svr_model_retail.fit(X_train, y_train['retail_price'])

# Predict 'wholesale_price' and 'retail_price' for the train and test sets
y_train_pred_wholesale = svr_model_wholesale.predict(X_train)
y_test_pred_wholesale = svr_model_wholesale.predict(X_test)
y_train_pred_retail = svr_model_retail.predict(X_train)
y_test_pred_retail = svr_model_retail.predict(X_test)

# Calculate RMSE and R-squared for train and test sets for 'wholesale_price'
train_rmse_wholesale = np.sqrt(mean_squared_error(y_train['wholesale_price'], y_train_pred_wholesale))
test_rmse_wholesale = np.sqrt(mean_squared_error(y_test['wholesale_price'], y_test_pred_wholesale))
train_r2_wholesale = r2_score(y_train['wholesale_price'], y_train_pred_wholesale)
test_r2_wholesale = r2_score(y_test['wholesale_price'], y_test_pred_wholesale)

# Calculate RMSE and R-squared for train and test sets for 'retail_price'
train_rmse_retail = np.sqrt(mean_squared_error(y_train['retail_price'], y_train_pred_retail))
test_rmse_retail = np.sqrt(mean_squared_error(y_test['retail_price'], y_test_pred_retail))
train_r2_retail = r2_score(y_train['retail_price'], y_train_pred_retail)
test_r2_retail = r2_score(y_test['retail_price'], y_test_pred_retail)

print("\nSVR Model:")
print("\n'wholesale_price' - Train RMSE: {:.2f}".format(train_rmse_wholesale))
print("'wholesale_price' - Test RMSE: {:.2f}".format(test_rmse_wholesale))
print("'wholesale_price' - Train R-squared: {:.2f}".format(train_r2_wholesale))
print("'wholesale_price' - Test R-squared: {:.2f}".format(test_r2_wholesale))

print("\n'retail_price' - Train RMSE: {:.2f}".format(train_rmse_retail))
print("'retail_price' - Test RMSE: {:.2f}".format(test_rmse_retail))
print("'retail_price' - Train R-squared: {:.2f}".format(train_r2_retail))
print("'retail_price' - Test R-squared: {:.2f}".format(test_r2_retail))


# Random Forest Model Implementation for 'wholesale_price'
from sklearn.ensemble import RandomForestRegressor
rf_model_wholesale = RandomForestRegressor()
rf_model_wholesale.fit(X_train, y_train['wholesale_price'])
# Random Forest Model Implementation for 'retail_price'
rf_model_retail = RandomForestRegressor()
rf_model_retail.fit(X_train, y_train['retail_price'])

# Predict 'wholesale_price' and 'retail_price' for the train and test sets
y_train_pred_wholesale_rf = rf_model_wholesale.predict(X_train)
y_test_pred_wholesale_rf = rf_model_wholesale.predict(X_test)
y_train_pred_retail_rf = rf_model_retail.predict(X_train)
y_test_pred_retail_rf = rf_model_retail.predict(X_test)

# Calculate RMSE and R-squared for train and test sets for 'wholesale_price'
train_rmse_wholesale_rf = np.sqrt(mean_squared_error(y_train['wholesale_price'], y_train_pred_wholesale_rf))
test_rmse_wholesale_rf = np.sqrt(mean_squared_error(y_test['wholesale_price'], y_test_pred_wholesale_rf))
train_r2_wholesale_rf = r2_score(y_train['wholesale_price'], y_train_pred_wholesale_rf)
test_r2_wholesale_rf = r2_score(y_test['wholesale_price'], y_test_pred_wholesale_rf)

# Calculate RMSE and R-squared for train and test sets for 'retail_price'
train_rmse_retail_rf = np.sqrt(mean_squared_error(y_train['retail_price'], y_train_pred_retail_rf))
test_rmse_retail_rf = np.sqrt(mean_squared_error(y_test['retail_price'], y_test_pred_retail_rf))
train_r2_retail_rf = r2_score(y_train['retail_price'], y_train_pred_retail_rf)
test_r2_retail_rf = r2_score(y_test['retail_price'], y_test_pred_retail_rf)

print("\nRF Model:")
print("\n'wholesale_price' - Train RMSE: {:.2f}".format(train_rmse_wholesale_rf))
print("'wholesale_price' - Test RMSE: {:.2f}".format(test_rmse_wholesale_rf))
print("'wholesale_price' - Train R-squared: {:.2f}".format(train_r2_wholesale_rf))
print("'wholesale_price' - Test R-squared: {:.2f}".format(test_r2_wholesale_rf))

print("\n'retail_price' - Train RMSE: {:.2f}".format(train_rmse_retail_rf))
print("'retail_price' - Test RMSE: {:.2f}".format(test_rmse_retail_rf))
print("'retail_price' - Train R-squared: {:.2f}".format(train_r2_retail_rf))
print("'retail_price' - Test R-squared: {:.2f}".format(test_r2_retail_rf))


