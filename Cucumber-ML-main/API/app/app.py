from fastapi import FastAPI
from pydantic import BaseModel
import pickle
import pandas as pd
import os
from datetime import datetime, timedelta
import joblib
from fastapi.middleware.cors import CORSMiddleware
from .function2_disease import router as cucumber_disease
from .Pests_in_Cucumber.function2_pets import router as cucumber_with_pests
from .function3_leaf import router as cucumber_leaf


app = FastAPI(
    title="Project Cucumber",
    description="FastAPI for Project Cucumber",
    version="0.0.0"
)

# Enable CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Root route
@app.get("/", tags=['Root'])
def home():
    return {'message': 'Welcome to Project Cucumber'}

# Get the directory of the current script
current_dir = os.path.dirname(os.path.abspath(__file__))

# Load the trained model
model_path = os.path.join(current_dir, 'src/fun4/soil_rf_model.pkl')
loaded_model = pickle.load(open(model_path, 'rb'))

class SoilConditionInput(BaseModel):
    soil_pH: float
    soil_moisture: float

@app.post("/soil_condition", tags=['Function 4 - Predict Soil Condition'])
def soil_condition(input_data: SoilConditionInput):
    soil_pH_input = input_data.soil_pH
    soil_moisture_input = input_data.soil_moisture

    # Divide soil_moisture by 100.0 to match the scale used during training
    soil_moisture_input /= 100.0
    
    # Create a DataFrame with the input values
    input_data_df = pd.DataFrame({'Soil_pH': [soil_pH_input], 'Soil_moisture': [soil_moisture_input]})
    
    # Make predictions
    prediction = loaded_model.predict(input_data_df)
    
    # Return the predicted result
    result = "Good" if prediction[0] == 1 else "Bad"
    return {"predicted_soil_condition": result}

# Function to load the forecast data for a specific location and target variable
def load_forecast(location, target_var):
    forecast_path = os.path.join(current_dir, "src", "fun4", "WeatherForecasts", location, f"{target_var}_forecast.csv")
    return pd.read_csv(forecast_path)

# Function to get the forecast for the upcoming days
def get_forecast(location, date, num_days): # date format: YYYY-MM-DD
    forecast_data = []

    # Set the target variables
    target_vars = ['y_max_temp', 'y_min_temp', 'y_mean_temp', 'y_shortwave_radiation_sum', 'y_rain_sum',
                    'y_rain_hours', 'y_windspeed_10m_max', 'y_windgusts_10m_max',
                    'y_winddirection_10m_dominant', 'y_et0_fao_evapotranspiration']

    # Iterate over the specified number of days
    for day in range(num_days):
        current_date = datetime.strptime(date, '%Y-%m-%d') + timedelta(days=day)
        current_date_str = current_date.strftime('%Y-%m-%d')

        # Store forecast for each target variable
        row = {'Date': current_date_str}
        for target_var in target_vars:
            forecast = load_forecast(location, target_var)
            value = round(forecast[forecast['ds'] == current_date_str]['yhat1'].values[0], 2)
            row[target_var] = value

        forecast_data.append(row)

    return pd.DataFrame(forecast_data)

@app.get("/weather_forecast", tags=['Function 4 - Weather Forecast'])
def weather_forecast(location: str, date: str, num_days: int):
    forecast_df = get_forecast(location, date, num_days)
    return forecast_df.to_dict(orient='records')

# Function 1

# Load the Random Forest model, encoder, and scalers
rf_model_filename = os.path.join(current_dir, 'src/fun1/rf_model.pkl')
encoder_filename = os.path.join(current_dir, 'src/fun1/encoder.pkl')
scaler_X_filename = os.path.join(current_dir, 'src/fun1/scaler_X.pkl')
scaler_y_filename = os.path.join(current_dir, 'src/fun1/scaler_y.pkl')

rf_model = joblib.load(rf_model_filename)
encoder = joblib.load(encoder_filename)
scaler_X = joblib.load(scaler_X_filename)
scaler_y = joblib.load(scaler_y_filename)

# Load the neighbor locations mapping
neighbor_mapping_file = os.path.join(current_dir, 'src/fun1/location_list_mapping.csv')
neighbor_mapping = pd.read_csv(neighbor_mapping_file, index_col='locations')

class Function1Input(BaseModel):
    location: str
    num_months: int
    expected_harvest_amount: float
    retail_ratio: float

@app.post("/function1", tags=['Function 1 - Predict Price'])
def function1(input_data: Function1Input):
    location = input_data.location
    num_months = input_data.num_months
    expected_harvest_amount = input_data.expected_harvest_amount
    retail_ratio = input_data.retail_ratio

    current_date = datetime.today()
    current_year = current_date.year
    current_month = current_date.month

    highest_income = 0
    highest_income_month = None
    selected_location_income = 0
    
    harvest_duration = 7
    
    # Function to calculate the next 12 months
    def get_upcoming_months(year, month, num_months):
        upcoming_months = []
        for _ in range(num_months):
            if month == 12:
                month = 1
                year += 1
            else:
                month += 1
            upcoming_months.append((year, month))
        return upcoming_months
    
    # Function to get price predictions
    def predict_price(year, month, location):
        # Create a DataFrame with the user input
        input_data = pd.DataFrame({'year': [year], 'month': [month], 'location': [location]})

        # Encode location using the loaded encoder
        location_encoded = encoder.transform(input_data[['location']])
        location_encoded_df = pd.DataFrame(location_encoded, columns=encoder.get_feature_names_out(['location']))
        location_encoded_df.columns = location_encoded_df.columns.str.split('_').str[-1]

        # Drop the 'location' column and concatenate the encoded 'location' columns
        input_data.drop(columns=['location'], inplace=True)
        input_data = pd.concat([input_data, location_encoded_df], axis=1)

        # Standardize the input data for independent variables (X)
        input_data_x = pd.DataFrame(scaler_X.transform(input_data), columns=input_data.columns)

        # Make price predictions using the Random Forest model
        price_predictions_y = rf_model.predict(input_data_x)

        # Inverse transform the predicted values for dependent variables (y) to get them back to their original scale
        price_predictions = scaler_y.inverse_transform(price_predictions_y)

        return price_predictions

    for year, month in get_upcoming_months(current_year, current_month, num_months):
        predicted_prices = predict_price(year, month, location)

        total_income = (
            predicted_prices[0][0] * (1 - retail_ratio)
            + predicted_prices[0][1] * retail_ratio
        ) * expected_harvest_amount

        if total_income > highest_income:
            highest_income = total_income
            highest_income_month = (year, month)
            selected_location_income = round(total_income, 2)

    if highest_income_month:
        harvest_year, harvest_month = highest_income_month
        start_date = datetime(harvest_year, harvest_month, 1) - timedelta(
            weeks=harvest_duration
        )
        start_month = start_date.month
        start_year = start_date.year

        highest_income_str = f"{highest_income:.2f}"
        highest_income_month_str = f"{datetime(harvest_year, harvest_month, 1).strftime('%B - %Y')}"
        cultivation_start_str = f"{datetime(start_year, start_month, 1).strftime('%B - %Y')}"

        result = {
            "location": location,
            "highest_income": highest_income_str,
            "harvest_month": highest_income_month_str,
            "cultivation_start": cultivation_start_str,
            "selected_location_income": selected_location_income,
        }

        neighbors = neighbor_mapping.loc[location].dropna().tolist()
        neighbor_incomes = []

        for neighbor in neighbors:
            neighbor_predicted_prices = predict_price(harvest_year, harvest_month, neighbor)
            neighbor_income = (
                neighbor_predicted_prices[0][0] * (1 - retail_ratio)
                + neighbor_predicted_prices[0][1] * retail_ratio
            ) * expected_harvest_amount
            neighbor_incomes.append((neighbor, round(neighbor_income, 2)))

        sorted_neighbors = sorted(neighbor_incomes, key=lambda x: x[1], reverse=True)

        result["neighbor_locations"] = [{"location": neighbor, "income": income} for neighbor, income in sorted_neighbors]

        best_neighbor = sorted_neighbors[0][0]
        best_neighbor_income = sorted_neighbors[0][1]

        result["best_neighbor"] = {"location": best_neighbor, "income": best_neighbor_income}

        if selected_location_income > best_neighbor_income:
            result["comparison_result"] = "The selected location has the highest income."
        elif selected_location_income < best_neighbor_income:
            result["comparison_result"] = f"The best neighbor location ({best_neighbor}) has the highest income."
        else:
            result["comparison_result"] = "The selected location and the best neighbor location have the same income."

        return result

    return {"message": "No predictions available."}


# Function 2
app.include_router(cucumber_disease)
app.include_router(cucumber_with_pests)

# Function 3
app.include_router(cucumber_leaf)

