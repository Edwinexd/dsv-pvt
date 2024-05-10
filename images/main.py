import os
from dotenv import load_dotenv
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, Header, Response
from typing import Annotated, BinaryIO
from fastapi.responses import FileResponse
from tempfile import NamedTemporaryFile
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from id_generator import IdGenerator

load_dotenv()

app = FastAPI()

id_generator = IdGenerator()

endpoint_url = os.getenv("AWS_ENDPOINT_URL")
api_key_id = os.getenv("API_KEY_ID")
api_key = os.getenv("API_KEY")
bucket_name = os.getenv("BUCKET_NAME")
api_key_self = os.getenv("API_KEY_SELF")

s3_resource = boto3.resource(
    service_name="s3",
    endpoint_url=endpoint_url,
    aws_access_key_id=api_key_id,
    aws_secret_access_key=api_key,
    config=Config(
        signature_version="s3v4",
    ),
)
s3_client = boto3.client(
    service_name="s3",
    endpoint_url=endpoint_url,
    aws_access_key_id=api_key_id,
    aws_secret_access_key=api_key,
)

ALLOWED_FILE_TYPES = ["image/png", "image/jpeg"]

MAX_FILE_SIZE = 20_971_520 #20MB

def validate_api_key(key: str = Header(alias = "IMAGES-API-Key")):
    if key != api_key_self:
        raise HTTPException(status_code=403, detail="Invalid API-KEY")

# TODO: better error handling for both of these
# TODO: caching with functools (?)

@app.post("/images")
async def upload_image(image: UploadFile, _: Annotated[None, Depends(validate_api_key)]):
    if image.content_type not in ALLOWED_FILE_TYPES:
        raise HTTPException(status_code=400, detail="Bad file type")

    if image.size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Bad file size")    

    #TODO: id gen
    id = id_generator.generate_id()

    try:
        s3_client.upload_fileobj(image.file, bucket_name, id, ExtraArgs={'ContentType': image.content_type})
        return {"image_id": id}
    except ClientError as e:
        raise HTTPException(status_code=500, detail=f"Something went wrong while uploading image: {e}")

def get_default_image() -> FileResponse:
    f = NamedTemporaryFile(delete=False)
    s3_resource.Bucket(bucket_name).download_file("default404.jpg", f.name)
    return FileResponse(
        path=f.name,
        filename=f.name,
        media_type="image/jpeg",
    )

@app.get("/download")
async def download_image(dir: str):
    try:
        f = NamedTemporaryFile(delete=False)
        s3_resource.Bucket(bucket_name).download_file(dir, f.name)
        return FileResponse(
            path=f.name,
            filename=f.name,
            media_type=f"image/{dir.split('.')[1]}",
        )
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            return get_default_image()
    #finally:
    #    os.remove(f.name)

@app.delete("/delete")
async def delete_image(file_name: str, _: Annotated[None, Depends(validate_api_key)]):
    objects = [
        {
            'Key': file_name
        }
    ]
    try:
        s3_resource.Bucket(bucket_name).delete_objects(Delete={'Objects': objects})
    except ClientError as e:
        if e.response['Error']['Code'] == "404":
            raise HTTPException(status_code=404, detail="Object not found")
        else:
            raise