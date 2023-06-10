import joblib
from fastapi import FastAPI
from pydantic import BaseModel
#from fastapi.staticfiles import StaticFiles

description_md = """# MLOps Stack Test
This is an example stack to publish ML models using FastAPI, Docker, and Terraform."""

tags_metadata = [
    {
        "name": "Home",
        "description": "*Home*",
    },
    {
        "name": "Advertising",
        "description": "Advertising endpoints.",
        "externalDocs": {
            "description": "This is a site about the Advertising ML prediction model.",
            "url": "https://google.com",
        },
    },
]

app = FastAPI(
    title="G-Ke | MLOps-Stack-1",
    description=description_md,
    version="0.0.1"
)
#app.mount("/", StaticFiles(directory="static", html=True), name="index")

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

@app.get("/", tags=["Home"])
async def root():
    return {"status": "up"}

@app.post("/advertising/predict", tags=["Advertising"], description="Endpoint to serve Advertising prediction")
def ads_predict(request: Ad):
    prediction = make_ads_prediction(ad_estimator_loaded, request.dict())
    return prediction

def make_ads_prediction(model, request):
    tv = request['tv']
    radio = request['radio']
    newspaper = request['newspaper']
    ads = [[tv, radio, newspaper]]
    prediction = model.predict(ads)
    return prediction[0]