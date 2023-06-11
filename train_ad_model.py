import joblib
import pandas as pd
from sklearn.metrics import r2_score
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split

df = pd.read_csv("datasets/advertising.csv")
print(df.head())

X = df.iloc[:, 1:-1].values
print(X.shape)
print(X[:3])

y = df.iloc[:, -1]
print(y.shape)
print(y[:6])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.33, random_state=42)

estimator = RandomForestRegressor(n_estimators=200)
estimator.fit(X_train, y_train)

y_pred = estimator.predict(X_test)

r2 = r2_score(y_true=y_test, y_pred=y_pred)
print("R2: ".format(r2))

joblib.dump(estimator, "saved_models/03.randomforest_with_advertising.pkl")
estimator_loaded = joblib.load("saved_models/03.randomforest_with_advertising.pkl")
X_manual_test = [[230.1,37.8,69.2]]
print("X_manual_test", X_manual_test)
prediction = estimator_loaded.predict(X_manual_test)
print(f"prediction: {prediction}")