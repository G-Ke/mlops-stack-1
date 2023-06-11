import joblib
import pandas as pd
from pydantic import BaseModel
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import r2_score
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split

class AdType(BaseModel):
    tv: float
    radio: float
    newspaper: float

    class Config:
        schema_extra = {
            "example": {
                "tv": 230.1,
                "radio": 37.8,
                "newspaper": 69.2
            }
        }

class Ad:
    def __init__(self):
        self.df = pd.read_csv("datasets/advertising.csv")
        self.model_fname_ = "saved_models/03.randomforest_with_advertising.pkl"
        try:
            self.model = joblib.load(self.model_fname_)
        except Exception as _:
            self.model = self._train_model()
            joblib.dump(self.model, self.model_fname_)
    
    def _train_model(self):
        X = self.df.iloc[:, 1:-1].values
        y = self.df.iloc[:, -1]
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.33, random_state=42)
        estimator = RandomForestRegressor(n_estimators=200)
        estimator.fit(X_train, y_train)
        y_pred = estimator.predict(X_test)
        r2_score(y_true=y_test, y_pred=y_pred)
        joblib.dump(estimator, "saved_models/03.randomforest_with_advertising.pkl")
        estimator_loaded = joblib.load("saved_models/03.randomforest_with_advertising.pkl")
        X_manual_test = [[230.1,37.8,69.2]]
        estimator_loaded.predict(X_manual_test)

    def predict_ad(self, tv, radio, newspaper):
        data_in = [[tv, radio, newspaper]]
        prediction = self.model.predict(data_in)
        return prediction[0]

class IrisSpecies(BaseModel):
    sepal_length: float
    sepal_width: float
    petal_length: float
    petal_width: float

    class Config:
        schema_extra = {
            "example": {
                "sepal_length": 5.1,
                "sepal_width": 3.5,
                "petal_length": 1.4,
                "petal_width": 1.2
            }
        }

class Iris:
    def __init__(self):
        self.df = pd.read_csv("datasets/iris.csv")
        self.model_fname_ = "saved_models/iris_randomforest.pkl"
        try:
            self.model = joblib.load(self.model_fname_)
        except Exception as _:
            self.model = self._train_model()
            joblib.dump(self.model, self.model_fname_)
    
    def _train_model(self):
        X = self.df.drop("species", axis=1)
        y = self.df["species"]
        rfc =  RandomForestClassifier()
        model = rfc.fit(X, y)
        return model
    
    def predict_species(self, sepal_length, sepal_width, petal_length, petal_width):
        data_in = [[sepal_length, sepal_width, petal_length, petal_width]]
        prediction = self.model.predict(data_in)
        probability = self.model.predict_proba(data_in).max()
        return prediction[0], probability