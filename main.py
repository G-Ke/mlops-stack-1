import joblib
from models import Ad, IrisSpecies, Iris
from fastapi import FastAPI

description_md = """
# MLOps Stack Test

This is an example stack to publish ML models using FastAPI, Docker, and Terraform.

## Endpoints
- `/advertising/predict`: Endpoint to serve Advertising predictions.
- `/iris/predict`: Endpoint to serve predictions on the species of Iris flower based on sepal and petal sizes.

"""

tags_metadata = [
    {
        "name": "Home",
        "description": "Home endpoints.",
    },
    {
        "name": "Advertising",
        "description": "Advertising endpoints.",
    },
        {
        "name": "Iris",
        "description": "Iris endpoints.",
    },
]

app = FastAPI(
    title="G-Ke | MLOps-Stack-1",
    description=description_md,
    version="0.0.1",
    openapi_tags=tags_metadata
)

ad_estimator_loaded = joblib.load("saved_models/03.randomforest_with_advertising.pkl")

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
