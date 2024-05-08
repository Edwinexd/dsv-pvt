import os
from dotenv import load_dotenv
from fastapi import FastAPI, File, UploadFile, HTTPException
from b2sdk.v2 import InMemoryAccountInfo, B2Api

load_dotenv()

app = FastAPI()

acc_info = InMemoryAccountInfo()
b2_api = B2Api(acc_info)
api_key_id = os.getenv("API_KEY_ID")
api_key = os.getenv("API_KEY")
b2_api.authorize_account("production", api_key_id, api_key)

bucket_name = "dsv-pvt-images-service"
bucket = b2_api.get_bucket_by_name(bucket_name)

ALLOWED_FILE_TYPES = ["image/png", "image/jpeg"]

MAX_FILE_SIZE = 2_097_152

@app.post("/upload")
async def upload_image(image: UploadFile):
    if image.content_type not in ALLOWED_FILE_TYPES:
        raise HTTPException(status_code=400, detail="Bad file type")
    
    if image.size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Bad file size")
    
    try:
        bucket.upload_bytes(image.file.read(), image.filename)
        return {"message" : f"image uploaded successfully, file name={image.filename}"}
    except Exception as e:
        return {"message" : f"error uploading image: {e}"}
    
@app.post("/download")
async def download_image(file_name: str):
    print(file_name)