from fastapi import HTTPException
import models

def validate_id(current_user_id, requested_user_id):
    if current_user_id != requested_user_id:
        raise HTTPException(status_code=403, detail="User is not current user")
    
def validate_user_in_group(user: models.User, group: models.Group):
    if user not in group.users:
        raise HTTPException(status_code=403, detail="User is not in this group")
    
def validate_owns_group(user_id: str, group: models.Group):
    if group.owner_id != user_id:
        raise HTTPException(status_code=403, detail="User does not own this group!")