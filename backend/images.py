"""
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
"""
import os
import requests
from fastapi import HTTPException, UploadFile
from fastapi.responses import FileResponse
from tempfile import NamedTemporaryFile
from dataclasses import dataclass

IMAGES_URL = os.getenv("IMAGES_URL")
IMAGES_API_KEY = os.getenv("IMAGES_API_KEY")


def upload(image: UploadFile):
    response = requests.post(
        url=f"{IMAGES_URL}/images",
        headers={
            "IMAGES-API-Key": IMAGES_API_KEY,
        },
        files={"image": ("foo.png", image.file, image.content_type)},
    )
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )
    return response.json()["image_id"]


def delete(image_id: str):
    response = requests.delete(
        url=f"{IMAGES_URL}/images/{image_id}",
        headers={
            "IMAGES-API-Key": IMAGES_API_KEY,
        },
    )
    if not response.ok:
        raise HTTPException(
            status_code=response.status_code, detail=response.json()["detail"]
        )


@dataclass
class ImageResponse:
    content: bytes
    media_type: str


def download(image_id: str):
    response = requests.get(url=f"https://images-pvt.edt.cx/images/{image_id}")
    return ImageResponse(
        content=response.content, media_type=response.headers["Content-Type"]
    )
