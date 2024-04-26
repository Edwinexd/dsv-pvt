from fastapi import HTTPException

def validate_id(current_user_id, requested_user_id):
    if current_user_id != requested_user_id:
        raise HTTPException(status_code=403, detail="User is not current user")