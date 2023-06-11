import joblib
from models import AdType, Ad, IrisSpecies, Iris
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

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
        "description": "Random endpoints.",
    },
    {
        "name": "Advertising",
        "description": "Endpoint to serve Advertising predictions.",
    },
        {
        "name": "Iris",
        "description": "Endpoint to serve Iris predictions.",
    },
]

app = FastAPI(
    title="G-Ke | MLOps-Stack-1",
    description=description_md,
    version="0.0.1",
    openapi_tags=tags_metadata
)

@app.get("/", tags=["Home"], response_class=HTMLResponse, description="A crude html page to welcome you to the API.")
async def homepage():
    return """
    <html>
        <head>
            <title>MLOps Stack Test</title>
        </head>
        <body>
            <h1>Welcome to the MLOps Stack Test</h1>
            <div>
                <h2>Swagger and Redocly Docs:</h2>
                <ul>
                    <li><a href="/docs">/docs</a></li>
                    <li><a href="/redoc">/redoc</a></li>
                </ul>
            </div>
        </body>
    </html>
    """


@app.get("/test", tags=["Home"], description="Test endpoint to check if the API is up and running.")
async def test():
    return {
        'Greeting': 'Hello, thanks for visiting. Check out /docs 😁',
        'Author': 'G-Ke',
        'Purpose': 'This is an example stack to publish ML models using FastAPI, Docker, and Terraform. Check out the docs if you want to know more.'
    }

@app.post("/advertising/predict", tags=["Advertising"], description="Endpoint to serve Advertising predictions.")
def predict_ads(request: AdType):
    model = Ad()
    data = request.dict()
    prediction = model.predict_ad(data['tv'], data['radio'], data['newspaper'])
    return {'prediction': prediction}

@app.post("/iris/predict", tags=["Iris"], description="Predict the species of an Iris flower based on the provided sepal and petal heights and widths.")
def predict_species(iris: IrisSpecies):
    model = Iris()
    data = iris.dict()
    prediction, probability = model.predict_species(
        data['sepal_length'], data['sepal_width'], data['petal_length'], data['petal_width']
    )
    return {
        'prediction': prediction,
        'probability': probability
    }
