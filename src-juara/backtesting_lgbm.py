#%%
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

#%%

X_train, y_train_binaria1, y_train_binaria2, w_train, X_test, y_test_class, y_test_binaria1, w_test = funciones_lgbm.preparar_data(lgbm_globales.dataset_path, lgbm_globales.dataset_file, lgbm_globales.mes_train, lgbm_globales.mes_test)

#%%

study = optuna.create_study(
    direction="maximize",
    study_name=lgbm_globales.study_name,
    storage=lgbm_globales.storage_name,
    load_if_exists=True,
)


#%%

def backtesting_lgbm():
  
    top_5 = study.trials_dataframe().sort_values(by="value", ascending=False).iloc[:5]['number'].tolist()

    ganancia = np.where(y_test_binaria1 == 1, lgbm_globales.ganancia_acierto, 0) - np.where(y_test_binaria1 == 0, lgbm_globales.costo_estimulo, 0)

    for i in top_5:

        trial_params = study.trials[i].params
        
        best_iter = study.trials[i].user_attrs['best_iter']
        
        for semilla in lgbm_globales.semillas:

            var_params = {'seed': semilla}

            params = {**lgbm_globales.fixed_params, **trial_params, **var_params}

            train_data = lgb.Dataset(X_train,
                                    label=y_train_binaria2,
                                    weight=w_train)

            model = lgb.train(params,
                            train_data,
                            num_boost_round=best_iter)

            y_pred_lgm = model.predict(X_test)

            idx = np.argsort(y_pred_lgm)[::-1]

            ganancia = ganancia[idx]
            y_pred_lgm = y_pred_lgm[idx]

            df_cut_point = pd.DataFrame({'ganancia': ganancia, 'y_pred_lgm': y_pred_lgm})

            private_idx, public_idx = train_test_split(df_cut_point.index, test_size=0.3, random_state=semilla, stratify=y_test_binaria1)

            df_cut_point['public'] = 0.0
            df_cut_point['private'] = 0.0
            df_cut_point.loc[private_idx, 'private'] = ganancia[private_idx] / 0.7
            df_cut_point.loc[public_idx, 'public'] = ganancia[public_idx] / 0.3

            df_cut_point['nro_envios'] = df_cut_point.reset_index().index

            df_cut_point['public_cum'] = df_cut_point['public'].cumsum()
            df_cut_point['private_cum'] = df_cut_point['private'].cumsum()


            df_cut_point.to_csv(lgbm_globales.dataset_path + 'df_cut_point-{study}-{trial}-{semilla}.csv'.format(study = lgbm_globales.study_name, trial = i, semilla = semilla), index=False)

#%%
backtesting_lgbm()

