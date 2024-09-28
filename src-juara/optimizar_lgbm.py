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
import lgbm_globales
import funciones_lgbm

X_train, y_train_binaria1, y_train_binaria2, w_train, X_test, y_test_class, y_test_binaria1, w_test = funciones_lgbm.preparar_data(lgbm_globales.dataset_path,
                                                                                                                   lgbm_globales.dataset_file,
                                                                                                                    lgbm_globales.mes_train,
                                                                                                                    lgbm_globales.mes_test)


def lgb_gan_eval(y_pred, data):
    weight = data.get_weight()
    ganancia = np.where(weight == 1.00002, lgbm_globales.ganancia_acierto, 0) - np.where(weight < 1.00002, lgbm_globales.costo_estimulo, 0)
    ganancia = ganancia[np.argsort(y_pred)[::-1]]
    ganancia = np.cumsum(ganancia)

    return 'gan_eval', np.max(ganancia) , True



def objective(trial):

    params_objetivo = {
    'num_leaves' : trial.suggest_int('num_leaves', 20, 5000),
    'learning_rate' : trial.suggest_float('learning_rate', 0.005, 0.4), # mas bajo, más iteraciones necesita
    'min_data_in_leaf' : trial.suggest_int('min_data_in_leaf', 1, 1000),
    'feature_fraction' : trial.suggest_float('feature_fraction', 0.1, .8),
    'feature_fraction_bynode' : trial.suggest_float('feature_fraction_bynode', 0.1, .8), 
    'bagging_fraction' : trial.suggest_float('bagging_fraction', 0.05, .8),
    'drop_rate': trial.suggest_float('drop_rate', 0.05, 0.3)
    }

    semilla = np.random.choice(lgbm_globales.semillas)

    params_objetivo['seed'] = semilla

    params = {**lgbm_globales.fixed_params, **params_objetivo}

    learning_rate = params['learning_rate']

    train_data = lgb.Dataset(X_train,
                              label=y_train_binaria2, # eligir la clase
                              weight=w_train)
    cv_results = lgb.cv(
        params,
        train_data,
        num_boost_round=lgbm_globales.boost_rounds, # modificar, subit y subir... y descomentar la línea inferior
        callbacks=[lgb.early_stopping(stopping_rounds= int(50 + 5 / learning_rate ))],
        feval=lgb_gan_eval,
        stratified=True,
        nfold=5
    )

    max_gan = max(cv_results['valid gan_eval-mean'])
    best_iter = cv_results['valid gan_eval-mean'].index(max_gan) + 1

    # Guardamos cual es la mejor iteración del modelo
    trial.set_user_attr("best_iter", best_iter)

    return max_gan * 5 / len(lgbm_globales.mes_train)


study = optuna.create_study(
    direction="maximize",
    study_name=lgbm_globales.study_name,
    storage=lgbm_globales.storage_name,
    load_if_exists=True
)


if lgbm_globales.optimizar:
    study.optimize(objective, n_trials= lgbm_globales.intentos) # subir subir

