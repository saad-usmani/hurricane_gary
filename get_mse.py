
import pandas as pd
import numpy as np
import statsmodels.api as sm
import matplotlib.pyplot as plt
import warnings
import itertools
from collections import namedtuple

# read data & do preprocessing
data = pd.read_csv("hurricanes_augmented.csv", dtype={"Date_string": np.object_, "Time_string": np.object_})
data["Time_string"] = data["Time_string"].str.pad(width=4, fillchar='0')
data["timestamp"] = pd.to_datetime(data["Date_string"] + " " + data["Time_string"], format="%Y%m%d %H")
data["Name"] = data["Name"].str.strip()
data = data[["id", "Name", "timestamp", "Status", "Latitude", "Longitude", "MaxiumWind", "MinimumPressure", "sst"]]
data.columns = ["id", "name", "timestamp", "status", "latitude", "longitude", "wind_kt", "min_pressure_mbar", "sea_temp_degc"]

# NHC makes regular observations *plus* observations at landfall. Let's get only the regular observations.
data = data[data.timestamp.dt.hour.isin([0, 6, 12, 18])]

# I am using machine learning to get the best model for the new prediction target
# Define the p, d and q parameters to take any value between 0 and 2
p = d = q = range(0, 2 + 1)

# Generate all different combinations of p, q and q triplets
pdq = list(itertools.product(p, d, q))

# Generate all different combinations of seasonal p, q and q triplets
seasonal_pdq = [(x[0], x[1], x[2], 7) for x in list(itertools.product(p, d, q))]

ModelSelectionResults = namedtuple('ModelSelectionResults', ["order", "seasonal_order", "aic"])

# training an average model
model_results = []
hurricanes_with_results = []

for key, group in data.groupby("id"):
    
    hurricane = group.copy()
    
    # There are other observations that don't occur on a regular schedule. Ignore any tropical event with those observations.
    try:
        date_index = pd.DatetimeIndex(hurricane["timestamp"], freq="6H")
    except ValueError as e:
        # print(e)
        continue # Reminder: "continue" means skip everything else and go to the next item in the loop
    hurricane = hurricane.set_index(date_index)
    
    
    max_seasonality_frequency = 10
    
    # Ignore hurricanes that do not have at least 10 observations
    if hurricane.shape[0] <= max_seasonality_frequency:
        # print("too short!")
        continue
 
    try:
        with warnings.catch_warnings():
            warnings.filterwarnings("ignore")
            mod = sm.tsa.statespace.SARIMAX(hurricane['min_pressure_mbar'],
                                            order=(1, 1, 1),
                                            seasonal_order=(2, 1, 0, 7),
                                            enforce_stationarity=False,
                                            enforce_invertibility=False)

            results = mod.fit()
        params = results.params
        coefficients = params[:-1] #remove the sigma squared/SE parameter
        if ((coefficients < 1.0) & (coefficients > -1.0)).all():
            model_results.append(results)
            hurricanes_with_results.append(key)
    except ValueError as e:
        if str(e) == "maxlag should be < nobs":
            pass
        else:
            print("ValueError:", e)
    except np.linalg.linalg.LinAlgError as e:
        if str(e)[:54] == "Non-positive-definite forecast error covariance matrix":
            pass
        else:
            print("LinAlgError:", e)


# filter out complete hurricanes  
result_params_list = []
hurricanes_with_valid_results = []
for hurricane_id, result in zip(hurricanes_with_results, model_results):
    try:
        result_params_list.append(result.params)
        hurricanes_with_valid_results.append(hurricane_id)
    except ValueError:
        continue

# df for coefficients
result_params = pd.DataFrame(result_params_list, index=hurricanes_with_valid_results)

# try forecasting: get min pressure means
mean_params = result_params.mean()




# subset out Irene to play with
# df = data[data.name == "IRENE"]
hurricane_irene = data[data.name == "IRENE"]
hurricane_irene = hurricane_irene.set_index(pd.DatetimeIndex(hurricane_irene["timestamp"], freq="6H"))


def get_mse(hurricane_irene, mean_params):

    irene_mod = sm.tsa.statespace.SARIMAX(hurricane_irene['min_pressure_mbar'],
                                      order=(1, 1, 1),
                                      seasonal_order=(2, 1, 0, 7),
                                      enforce_stationarity=False,
                                      enforce_invertibility=False)

    irene_results = irene_mod.filter(mean_params)

    pred = irene_results.get_prediction(start=pd.to_datetime('2011-08-26'), dynamic=False)

    y_forecasted = pred.predicted_mean
    # y_forecasted = irene_results.get_prediction(start=pd.to_datetime('2011-08-21'), dynamic=False)
    y_truth = hurricane_irene['min_pressure_mbar']['2011-08-21':]
    mse = ((y_forecasted - y_truth) ** 2).mean()
    print('The Mean Squared Error of our forecasts is {}'.format(round(mse, 2)))

get_mse(hurricane_irene, params)


    
   