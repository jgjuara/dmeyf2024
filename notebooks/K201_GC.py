# K201_GC

# Seguimos con el dataset en python
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.model_selection import ShuffleSplit, StratifiedShuffleSplit
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer

import lightgbm as lgb

import optuna
from optuna.visualization import plot_optimization_history, plot_param_importances, plot_slice, plot_contour

from time import time

import pickle
dataset_path = 'buckets/b1/datasets/' 
dataset_file = 'competencia_02_sql_v2.csv'



base_path = 'buckets/b1/'
modelos_path = base_path + 'modelos/'
db_path = base_path + 'db/'

ganancia_acierto = 273000
costo_estimulo = 7000

data = pd.read_csv(dataset_path+dataset_file)
semillas = [165229,165211,165203,165237,165247]

mes_train = 202106
mes_test = 202108

data['clase_peso'] = 1.0

data.loc[data['clase_ternaria'] == 'BAJA+2', 'clase_peso'] = 1.00002
data.loc[data['clase_ternaria'] == 'BAJA+1', 'clase_peso'] = 1.00001
#data['clase_binaria1'] = 0
data['clase_binaria2'] = 0
#data['clase_binaria1'] = np.where(data['clase_ternaria'] == 'BAJA+2', 1, 0)
data['clase_binaria2'] = np.where(data['clase_ternaria'] == 'CONTINUA', 0, 1) # la binaria2 incluye a los BAJA+1

# tirar la que no usas
data.drop(columns=['mprestamos_personales', 'cprestamos_personales'], inplace = True)
train_data = data[data['foto_mes'] == mes_train]
test_data = data[data['foto_mes'] == mes_test]

X_train = train_data.drop(['clase_ternaria', 'clase_peso','clase_binaria2'], axis=1)  # , 'clase_binaria1'
#y_train_binaria1 = train_data['clase_binaria1']
y_train_binaria2 = train_data['clase_binaria2']
w_train = train_data['clase_peso']

X_test = test_data.drop(['clase_ternaria', 'clase_peso','clase_binaria2'], axis=1)  # , 'clase_binaria1'
# y_test_binaria1 = test_data['clase_binaria1']
y_test_binaria2 = test_data['clase_binaria2']
y_test_class = test_data['clase_ternaria']
w_test = test_data['clase_peso']
imp_mean = SimpleImputer(missing_values=np.nan, strategy='mean')  # podemos intentar otras imputaciones y ver que tal
Xif = imp_mean.fit_transform(X_test)
def lgb_gan_eval(y_pred, data):
    weight = data.get_weight()
    ganancia = np.where(weight == 1.00002, ganancia_acierto, 0) - np.where(weight < 1.00002, costo_estimulo, 0)
    ganancia = ganancia[np.argsort(y_pred)[::-1]]
    ganancia = np.cumsum(ganancia)

    return 'gan_eval', np.max(ganancia) , True





# Parámetros del modelos.
params = {
    'objective': 'binary',
    'metric': 'gan_eval',
    'boosting_type': 'gbdt',
    'max_bin': 31,
    'num_leaves': 31,
    'learning_rate': 0.01,
    'feature_fraction': 0.3,
    'bagging_fraction': 0.7,
    'verbose': 0
}
# train_data1 = lgb.Dataset(X_train, label=y_train_binaria1, weight=w_train)
train_data2 = lgb.Dataset(X_train, label=y_train_binaria2, weight=w_train)





# LGBM

def objective(trial):

    num_leaves = trial.suggest_int('num_leaves', 8, 100),
    learning_rate = trial.suggest_float('learning_rate', 0.005, 0.3), # mas bajo, más iteraciones necesita
    min_data_in_leaf = trial.suggest_int('min_data_in_leaf', 1, 1000),
    feature_fraction = trial.suggest_float('feature_fraction', 0.1, 1.0),
    bagging_fraction = trial.suggest_float('bagging_fraction', 0.1, 1.0),

    params = {
        'objective': 'binary',
        'metric': 'custom',
        'boosting_type': 'gbdt',
        'first_metric_only': True,
        'boost_from_average': True,
        'feature_pre_filter': False,
        'max_bin': 31,
        'num_leaves': num_leaves,
        'learning_rate': learning_rate,
        'min_data_in_leaf': min_data_in_leaf,
        'feature_fraction': feature_fraction,
        'bagging_fraction': bagging_fraction,
        'seed': semillas[0],
        'verbose': -1
    }
    train_data = lgb.Dataset(X_train,
                              label=y_train_binaria2, # eligir la clase
                              weight=w_train)
    cv_results = lgb.cv(
        params,
        train_data,
        num_boost_round=100, # modificar, subit y subir... y descomentar la línea inferior
        # early_stopping_rounds= int(50 + 5 / learning_rate),
        feval=lgb_gan_eval,
        stratified=True,
        nfold=5,
        seed=semillas[0]
    )
    max_gan = max(cv_results['valid gan_eval-mean'])
    best_iter = cv_results['valid gan_eval-mean'].index(max_gan) + 1

    # Guardamos cual es la mejor iteración del modelo
    trial.set_user_attr("best_iter", best_iter)

    return max_gan * 5



storage_name = "sqlite:///" + db_path + "optimization_lgbm.db"
study_name = "exp_201_lgbm"  # cambiar acá si es otra corrida

study = optuna.create_study(
    direction="maximize",
    study_name=study_name,
    storage=storage_name,
    load_if_exists=True,
)
study.optimize(objective, n_trials=10) # subir subir
best_iter = study.best_trial.user_attrs["best_iter"]
print(f"Mejor cantidad de árboles para el mejor model {best_iter}")
params = {
    'objective': 'binary',
    'boosting_type': 'gbdt',
    'first_metric_only': True,
    'boost_from_average': True,
    'feature_pre_filter': False,
    'max_bin': 31,
    'num_leaves': study.best_trial.params['num_leaves'],
    'learning_rate': study.best_trial.params['learning_rate'],
    'min_data_in_leaf': study.best_trial.params['min_data_in_leaf'],
    'feature_fraction': study.best_trial.params['feature_fraction'],
    'bagging_fraction': study.best_trial.params['bagging_fraction'],
    'seed': semillas[0],
    'verbose': 0
}

train_data = lgb.Dataset(X_train,
                          label=y_train_binaria2,
                          weight=w_train)

model = lgb.train(params,
                  train_data,
                  num_boost_round=best_iter)
# guardamos modelos

model.save_model(modelos_path + 'lgb_k201.txt')
# levantamos modelo

model = lgb.Booster(model_file=modelos_path + 'lgb_k201.txt')
# predecimos

y_pred_lgm = model.predict(X_test)
def ganancia_prob(y_pred, y_true, prop = 1):
  ganancia = np.where(y_true == 1, ganancia_acierto, 0) - np.where(y_true == 0, costo_estimulo, 0)
  return ganancia[y_pred >= 0.025].sum() / prop

print("Ganancia LGBM:", ganancia_prob(y_pred_lgm, y_test_binaria2))

## Entrenamos en Junio
mes_train = 202106
mes_test = 202108
X_futuro = data[data['foto_mes'] == mes_test]
# y_futuro = X_futuro['clase_ternaria'] # tiene valores pero porque armaste el target como el orto
X_futuro = X_futuro.drop(columns=['clase_ternaria', 'clase_peso','clase_binaria2'])
Xif = imp_mean.fit_transform(X_futuro)
y_pred_rf = model.predict(Xif)
### Salida a Kaggle
# GProbabilidades predichas
predicted_prob = model.predict(Xif, raw_score=False, pred_leaf=False, pred_contrib=False)

# Tomamos numero de cliente y proba
df_predictions = pd.DataFrame({
    'numero_de_cliente': X_futuro['numero_de_cliente'],
    'probability': predicted_prob
})

# Ordenamos por proba de mayor a menor
df_predictions = df_predictions.sort_values(by='probability', ascending=False)

# Nos quedamos con los 12k de mayor probabilidad
df_predictions['Predicted'] = 0  # Default to 0
df_predictions.iloc[:12000, df_predictions.columns.get_loc('Predicted')] = 1  # Set top 10,000 to 1


# Formato Kaggle

K201_002 = df_predictions[['numero_de_cliente', 'Predicted']]
# Guardamos

file_path = 'buckets/b1/exp/KA2000/K201_002.csv'

K201_002.to_csv(file_path, index=False)
