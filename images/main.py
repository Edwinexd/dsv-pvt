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
from dotenv import load_dotenv
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, Header, Response
from typing import Annotated, BinaryIO
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from tempfile import NamedTemporaryFile
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from id_generator import IdGenerator
from io import BytesIO
from functools import lru_cache

load_dotenv()

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

id_generator = IdGenerator()

endpoint_url = os.getenv("AWS_ENDPOINT_URL")
api_key_id = os.getenv("API_KEY_ID")
api_key = os.getenv("API_KEY")
bucket_name = os.getenv("BUCKET_NAME")
api_key_self = os.getenv("API_KEY_SELF")


ALLOWED_FILE_TYPES = ["image/png", "image/jpeg"]

MAX_FILE_SIZE = 20_971_520  # 20MB

s3_client = boto3.client(
    service_name="s3",
    endpoint_url=endpoint_url,
    aws_access_key_id=api_key_id,
    aws_secret_access_key=api_key,
)


def validate_api_key(key: str = Header(alias="IMAGES-API-Key")):
    if key != api_key_self:
        raise HTTPException(status_code=403, detail="Invalid API-KEY")


@app.post("/images")
async def upload_image(
    image: UploadFile, _: Annotated[None, Depends(validate_api_key)]
):
    if image.content_type not in ALLOWED_FILE_TYPES:
        raise HTTPException(status_code=400, detail="Bad file type")

    if image.size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Bad file size")

    id = str(id_generator.generate_id())

    try:
        s3_client.upload_fileobj(
            image.file, bucket_name, id, ExtraArgs={"ContentType": image.content_type}
        )
        return {"image_id": id}
    except ClientError as e:
        raise HTTPException(
            status_code=500, detail=f"Something went wrong while uploading image: {e}"
        )


@lru_cache
def get_default_image() -> Response:
    b = BytesIO()
    s3_client.download_fileobj(bucket_name, "default404.jpg", b)
    content_type = s3_client.head_object(Bucket=bucket_name, Key="default404.jpg")[
        "ContentType"
    ]
    b.seek(0)
    return Response(
        content=b.read(),
        media_type=content_type,
        status_code=404,
    )


@lru_cache
def get_image(image_id: str):
    b = BytesIO()
    s3_client.download_fileobj(bucket_name, image_id, b)
    content_type = s3_client.head_object(Bucket=bucket_name, Key=image_id)[
        "ContentType"
    ]
    b.seek(0)
    return Response(
        content=b.read(),
        media_type=content_type,
    )


@app.get("/images/{image_id}")
async def download_image(image_id: str):
    try:
        return get_image(image_id)
    except ClientError as e:
        if e.response["Error"]["Code"] == "404":
            return get_default_image()


@app.delete("/images/{image_id}", status_code=204)
async def delete_image(image_id: str, _: Annotated[None, Depends(validate_api_key)]):
    try:
        s3_client.delete_object(Bucket=bucket_name, Key=image_id)
    except ClientError as e:
        if e.response["Error"]["Code"] == "404":
            raise HTTPException(status_code=404, detail="Object not found")
        else:
            raise
