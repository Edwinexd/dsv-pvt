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
                image.file.name,
                image.file,
                image.content_type
            )
        }
    )
    image.file.close()
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])
    return response.json()["image_id"]