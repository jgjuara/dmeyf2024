import funciones_lgbm
import lgbm_globales

X_train, y_train_binaria2, y_train_binaria1, w_train, X_test, y_test_class, w_test = preparar_data(dataset_path, dataset_file, mes_train = [202102, 202103, 202104], mes_test = 202106)


study = optuna.create_study(
    direction="maximize",
    study_name=study_name,
    storage=storage_name,
    load_if_exists=True,
)


# prediccion
predecir()
