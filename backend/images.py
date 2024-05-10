import os
import requests
from fastapi import HTTPException, UploadFile
from fastapi.responses import FileResponse
from tempfile import NamedTemporaryFile


IMAGES_URL = os.getenv("IMAGES_URL")
IMAGES_API_KEY = os.getenv("IMAGES_API_KEY")

def upload(dir: str, image: UploadFile):
    temp = NamedTemporaryFile(delete=False)
    c = image.file.read()
    with temp as f:
        f.write(c)
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
    image.file.close()
    os.remove(temp.name)
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])

def download(dir: str) -> FileResponse:
    response = requests.get(
        url=f"{IMAGES_URL}/download?dir={dir}",
        headers={
            "IMAGES-API-Key" : IMAGES_API_KEY,
        },
    )
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.json()["detail"])
    temp = NamedTemporaryFile(delete=False)
    with temp as f:
        f.write(response.content)
    return FileResponse(
        path=f.name,
        filename=f.name,
        media_type=f"image/jpeg"
    )