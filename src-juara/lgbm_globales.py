import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.model_selection import ShuffleSplit, StratifiedShuffleSplit
from sklearn.ensemble import RandomForestClassifier
import lightgbm as lgb
import optuna
from optuna.visualization import plot_optimization_history, plot_param_importances, plot_slice, plot_contour
from time import time
import pickle
import os
from dotenv import load_dotenv
import urllib
# Load environment variables from .env file

# parametros a setear
dataset_file = 'competencia_01_aum_nonimp.parquet'
mes_train = [202102, 202103]
mes_test = 202104
study_name = "lgbm_binaria_t2"
boost_rounds = 5000
intentos = 500
optimizar = True
min_envios = 8000
max_envios = 16000
paso_envios = 500

#

# params_objetivo = {
#     'num_leaves' : trial.suggest_int('num_leaves', 20, 1000),
#     'learning_rate' : trial.suggest_float('learning_rate', 0.005, 0.4), # mas bajo, más iteraciones necesita
#     'min_data_in_leaf' : trial.suggest_int('min_data_in_leaf', 1, 1000),
#     'feature_fraction' : trial.suggest_float('feature_fraction', 0.1, .8),
#     'feature_fraction_bynode' : trial.suggest_float('feature_fraction_bynode', 0.1, .8), 
#     'bagging_fraction' : trial.suggest_float('bagging_fraction', 0.05, .08),
#     'drop_rate': trial.suggest_float('drop_rate', 0.1, 3.0),
# }
    

fixed_params = {
    'objective': 'binary',
    'metric': 'custom',
    'boosting_type': 'gbdt',
    'first_metric_only': True,
    'boost_from_average': True,
    'feature_pre_filter': False,
    'max_bin': 31,
    'force_col_wise' : True,
    'verbose': -1
}

# variables ambiente fijas
load_dotenv()
semillas = os.getenv("semillas")
semillas = [int(x) for x in semillas.split(",")]
ganancia_acierto = 273000
costo_estimulo = 7000
base_path = '../'
dataset_path = base_path + 'datasets/'
modelos_path = base_path + 'modelos/'
db_path = base_path + 'db/'
storage_name = "mysql+mysqldb://{u}:{p}@{ip}:3306/optuna_rf_db".format(p=urllib.parse.quote_plus(os.getenv("password")), u = os.getenv("usersrv"), ip = os.getenv("ip"))
