"""
Support Vector Regressor (SVR) Model Development
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


# SVR Model Implementation for Multi-Output Regression
from sklearn.multioutput import MultiOutputRegressor
from sklearn.svm import SVR
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np

# Define SVR model with hyperparameters
svr_model = SVR(kernel='rbf', C=4.0, epsilon=0.6)

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

print("\nSVR Model - Train RMSE: {:.2f}".format(train_rmse))
print("SVR Model - Test RMSE: {:.2f}".format(test_rmse))
print("SVR Model - Train R-squared: {:.2f}".format(train_r2))
print("SVR Model - Test R-squared: {:.2f}".format(test_r2))


# Random Forest Model Implementation for Multi-Output Regression
from sklearn.ensemble import RandomForestRegressor

# Define Random Forest model with hyperparameters
rf_model = RandomForestRegressor(n_estimators=100, bootstrap=True,
                                    max_depth=None, random_state=42)

# Train the Random Forest model
rf_model.fit(X_train, y_train)

# Predict both 'wholesale_price' and 'retail_price' for the train and test sets
y_train_pred_rf = rf_model.predict(X_train)
y_test_pred_rf = rf_model.predict(X_test)

# Calculate RMSE and R-squared for Random Forest model on train and test sets
train_rmse_rf = np.sqrt(mean_squared_error(y_train, y_train_pred_rf))
test_rmse_rf = np.sqrt(mean_squared_error(y_test, y_test_pred_rf))

train_r2_rf = r2_score(y_train, y_train_pred_rf)
test_r2_rf = r2_score(y_test, y_test_pred_rf)

print("\nRF Model - Train RMSE: {:.2f}".format(train_rmse_rf))
print("RF Model - Test RMSE: {:.2f}".format(test_rmse_rf))
print("RF Model - Train R-squared: {:.2f}".format(train_r2_rf))
print("RF Model - Test R-squared: {:.2f}".format(test_r2_rf))


# Comprehensive Evaluation of SVR and RF models
## Residual Plots
import matplotlib.pyplot as plt

# Calculate residuals for both models
residuals_svr = y_test - y_test_pred
residuals_rf = y_test - y_test_pred_rf

# Create residual plots
plt.figure(figsize=(12, 6))

plt.subplot(1, 2, 1)
plt.scatter(y_test, residuals_svr, alpha=0.5)
plt.xlabel("Actual Values")
plt.ylabel("Residuals")
plt.title("Residuals for SVR Model")

plt.subplot(1, 2, 2)
plt.scatter(y_test, residuals_rf, alpha=0.5)
plt.xlabel("Actual Values")
plt.ylabel("Residuals")
plt.title("Residuals for Random Forest Model")

plt.show()


## Distribution of Residuals
import seaborn as sns

plt.figure(figsize=(12, 6))

plt.subplot(1, 2, 1)
sns.histplot(residuals_svr, kde=True)
plt.xlabel("Residuals")
plt.title("Residual Distribution for SVR Model")

plt.subplot(1, 2, 2)
sns.histplot(residuals_rf, kde=True)
plt.xlabel("Residuals")
plt.title("Residual Distribution for Random Forest Model")

plt.show()


## Actual vs. Predicted Values
plt.figure(figsize=(12, 6))

plt.subplot(1, 2, 1)
plt.scatter(y_test, y_test_pred, alpha=0.5)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'k--', lw=2)
plt.xlabel("Actual Values")
plt.ylabel("Predicted Values")
plt.title("Actual vs. Predicted Values for SVR Model")

plt.subplot(1, 2, 2)
plt.scatter(y_test, y_test_pred_rf, alpha=0.5)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'k--', lw=2)
plt.xlabel("Actual Values")
plt.ylabel("Predicted Values")
plt.title("Actual vs. Predicted Values for Random Forest Model")

plt.show()


## Feature Importances (Random Forest Only)
feature_importances = rf_model.feature_importances_
sorted_idx = np.argsort(feature_importances)

plt.figure(figsize=(10, 6))
plt.barh(range(X_train.shape[1]), feature_importances[sorted_idx], align="center")
plt.yticks(range(X_train.shape[1]), X_train.columns[sorted_idx])
plt.xlabel("Feature Importance")
plt.title("Random Forest Feature Importance")

plt.show()