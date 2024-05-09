import os
import requests
from fastapi import HTTPException, UploadFile
from tempfile import NamedTemporaryFile


IMAGES_URL = os.getenv("IMAGES_URL")
IMAGES_API_KEY = os.getenv("IMAGES_API_KEY")

def upload(dir: str, image: UploadFile):
    temp = NamedTemporaryFile(delete=False)
    c = image.file.read()
    with temp as f:
        f.write(c)
    #image.file.close()
    response = requests.post(
        url=f"{IMAGES_URL}/upload?dir={dir}",
        headers={
            "IMAGES-API-Key": IMAGES_API_KEY,
        },
        files={
            "image": (
                dir,
                open(temp.name, 'rb'),
                image.content_type
            )
        }
    )
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])
