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

def preparar_data(dataset_path, dataset_file, mes_train, mes_test):
    data = pd.read_parquet(dataset_path + dataset_file)

    data['clase_peso'] = 1.0

    data.loc[data['clase_ternaria'] == 'BAJA+2', 'clase_peso'] = 1.00002
    data.loc[data['clase_ternaria'] == 'BAJA+1', 'clase_peso'] = 1.00001

    data['clase_binaria1'] = 0
    data['clase_binaria2'] = 0
    data['clase_binaria1'] = np.where(data['clase_ternaria'] == 'BAJA+2', 1, 0)
    data['clase_binaria2'] = np.where(data['clase_ternaria'] == 'CONTINUA', 0, 1)

    train_data = data.loc[data['foto_mes'].isin(mes_train)]
    test_data = data[data['foto_mes'] == mes_test]

    X_train = train_data.drop(['clase_ternaria', 'clase_peso', 'clase_binaria1','clase_binaria2'], axis=1)
    y_train_binaria1 = train_data['clase_binaria1']
    y_train_binaria2 = train_data['clase_binaria2']
    w_train = train_data['clase_peso']

    X_test = test_data.drop(['clase_ternaria', 'clase_peso', 'clase_binaria1','clase_binaria2'], axis=1)
    y_test_binaria1 = test_data['clase_binaria1']
    y_test_class = test_data['clase_ternaria']
    w_test = test_data['clase_peso']

    return X_train, y_train_binaria1, y_train_binaria2, w_train, X_test, y_test_class, y_test_binaria1, w_test



def predecir():

    top_5 = study.trials_dataframe().sort_values(by="value", ascending=False).iloc[:5]['number'].tolist()

    for i in top_5:

        trial_params = study.trials[i].params
        
        best_iter = study.trials[i].user_attrs['best_iter']
        
        for semilla in semillas:

            var_params = {'seed': semilla}

            params = {**fixed_params, **trial_params, **var_params}

            train_data = lgb.Dataset(X_train,
                                    label=y_train_binaria2,
                                    weight=w_train)

            model = lgb.train(params,
                            train_data,
                            num_boost_round=best_iter)

            model.save_model(modelos_path + 'lgbm-{study}-{trial}-{envios}-{semilla}.txt'.format(study = study_name, trial = i, envios = envios, semilla = semilla))

            y_pred_lgm = model.predict(X_test)

            rango = np.arange(min_envios, max_envios, paso_envios)

            for i in rango:
                data_export = X_test['numero_de_cliente'].to_frame()
                data_export['Prob'] = y_pred_lgm
                data_export = data_export.sort_values(by='Prob', ascending=False)
                data_export['Predicted'] = 0
                data_export.iloc[:i, data_export.columns.get_loc('Predicted')] = 1
                envios = data_export['Predicted'].sum()
                data_export = data_export[['numero_de_cliente', 'Predicted']]
                envio_path = dataset_path + 'lgbm-{study}-{trial}-{envios}-{semilla}.csv'.format(study = study_name, trial = i, envios = envios, semilla = semilla)
                data_export.to_csv(envio_path, index=False)
                # Define the command
                mensaje = 'Optuna study {study} trial {trial} semilla {semilla} - envios {envios}'.format(semilla = semilla, envios = envios, study = study_name, trial = study.best_trial.number)

                command = 'kaggle competitions submit -c dm-ey-f-2024-primera -f {envio_path} -m "{mensaje}"'.format(envio_path = envio_path, mensaje = mensaje)
                print(mensaje)
                # Execute the command
                os.system(command)

