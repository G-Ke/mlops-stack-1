import joblib
import pandas as pd
from fastapi import FastAPI
from pydantic import BaseModel
from sklearn.ensemble import RandomForestClassifier

description_md = """# MLOps Stack Test
This is an example stack to publish ML models using FastAPI, Docker, and Terraform."""

tags_metadata = [
    {
        "name": "Advertising",
        "description": "Advertising endpoints.",
        "externalDocs": {
            "description": "This is a site about the Advertising ML prediction model.",
            "url": "https://google.com",
        },
    },
        {
        "name": "Iris",
        "description": "Iris endpoints.",
        "externalDocs": {
            "description": "This is a about the Iris ML prediction model.",
            "url": "https://google.com",
        },
    },
]

app = FastAPI(
    title="G-Ke | MLOps-Stack-1",
    description=description_md,
    version="0.0.1"
)
# I wanted to experiment with a static homepage, but decided against it.
# app.mount("/", StaticFiles(directory="static", html=True), name="index")

ad_estimator_loaded = joblib.load("saved_models/03.randomforest_with_advertising.pkl")

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
        self.df = pd.read_csv("iris.csv")
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

@app.get("/", tags=["Home"])
async def root():
    return {"status": "up"}

@app.post("/advertising/predict", tags=["Advertising"], description="Endpoint to serve Advertising predictions.")
def predict_ads(request: Ad):
    prediction = make_ads_prediction(ad_estimator_loaded, request.dict())
    return {"prediction": prediction}

def make_ads_prediction(model, request):
    tv = request['tv']
    radio = request['radio']
    newspaper = request['newspaper']
    ads = [[tv, radio, newspaper]]
    prediction = model.predict(ads)
    return prediction[0]

@app.post("/iris/predict", tags=["Iris"], description="Endpoint to serve predictions on the species of Iris flower based on sepal and petal sizes.")
def predict_species(iris: IrisSpecies):
    model = Iris()
    data = iris.dict()
    prediction, probability = model.predict_species(
        data['sepal_length'], data['sepal_width'], data['petal_length'], data['petal_width']
    )
    return {
        'predcition': prediction,
        'probability': probability
    }
