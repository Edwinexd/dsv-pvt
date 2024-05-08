import os
from dotenv import load_dotenv
from fastapi import FastAPI, File, UploadFile, HTTPException
from tempfile import NamedTemporaryFile
import boto3
from botocore.config import Config

load_dotenv()

app = FastAPI()

endpoint_url = os.getenv("AWS_ENDPOINT_URL")
api_key_id = os.getenv("API_KEY_ID")
api_key = os.getenv("API_KEY")

s3 = boto3.resource(service_name='s3', endpoint_url=endpoint_url, aws_access_key_id=api_key_id, aws_secret_access_key=api_key, config = Config(signature_version='s3v4',))

ALLOWED_FILE_TYPES = ["image/png", "image/jpeg"]

MAX_FILE_SIZE = 2_097_152

#s3.Bucket("dsv-pvt-images-service").upload_file("/home/alfred/Pictures/Screenshots/testimage.png", "test.png")
#s3.Bucket("dsv-pvt-images-service").download_file("test.png","/home/alfred/testB2.png")

@app.post("/upload")
async def upload_image(image: UploadFile):
    if image.content_type not in ALLOWED_FILE_TYPES:
        raise HTTPException(status_code=400, detail="Bad file type")
    
    if image.size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Bad file size")

    temp = NamedTemporaryFile(delete=False)
    c = image.file.read()

    with temp as f:
        f.write(c)

    image.file.close()

    #os.remove(temp.name)
    
    try:
        #bucket.upload_bytes(image.file.read(), image.filename)
        s3.Bucket("dsv-pvt-images-service").upload_file(temp.name, image.filename)
        return {"message" : f"image uploaded successfully, file name={image.filename}"}
    except Exception as e:
        return {"message" : f"error uploading image: {e}"}
    
    
@app.post("/download")
async def download_image(file_name: str):
    print(file_name)