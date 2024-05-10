import os
import requests
from fastapi import HTTPException, UploadFile
from fastapi.responses import FileResponse
from tempfile import NamedTemporaryFile

IMAGES_URL = os.getenv("IMAGES_URL")
IMAGES_API_KEY = os.getenv("IMAGES_API_KEY")

def upload(image: UploadFile):
    response = requests.post(
        url=f"{IMAGES_URL}/images",
        headers={
            "IMAGES-API-Key": IMAGES_API_KEY,
        },
        files={
            "image": (
                'foo.png',
                image.file,
                image.content_type
            )
        }
    )
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])
    return response.json()["image_id"]

def delete(image_id: str):
    response = requests.delete(
        url=f"{IMAGES_URL}/images/{image_id}",
        headers={
            "IMAGES-API-Key": IMAGES_API_KEY,
        }
    )
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])