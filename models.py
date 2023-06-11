import joblib
import pandas as pd
from pydantic import BaseModel
from sklearn.ensemble import RandomForestClassifier

class Ad(BaseModel):
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

class IrisSpecies(BaseModel):
    sepal_length: float
    sepal_width: float
    petal_length: float
    petal_width: float

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