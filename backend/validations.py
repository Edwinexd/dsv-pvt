import os
from fastapi import HTTPException, Header
import models
from datetime import datetime

API_KEY = os.getenv("API_KEY")

def validate_id(current_user_id, requested_user_id):
    if current_user_id != requested_user_id:
        raise HTTPException(status_code=403, detail="User is not current user")
    
def validate_user_in_group(user: models.User, group: models.Group):
    if user not in group.users:
        raise HTTPException(status_code=403, detail="User is not in this group")
    
def validate_user_in_activity(user: models.User, activity: models.Activity):
    if user not in activity.participants:
        raise HTTPException(status_code=403, detail="User is not in this activity")
    
def validate_owns_group(user_id: str, group: models.Group):
    if group.owner_id != user_id:
        raise HTTPException(status_code=403, detail="User does not own this group!")
    
def validate_owns_activity(user_id: str, activity: models.Activity):
    if activity.owner_id != user_id:
        raise HTTPException(status_code=403, detail="User does not own this activity!")
    
def validate_user_invited(user: models.User, invited_users: list[models.User]):
    if user not in invited_users:
        raise HTTPException(status_code=403, detail="You are not invited to this group!")
    
def validate_current_is_inviter(current_user: models.User, invitation: models.GroupInvitations):
    if current_user.id != invitation.invited_by:
        raise HTTPException(status_code=403, detail="You cannot delete another users invitation!")
    
def validate_api_key(api_key: str = Header(alias="ADMIN-API-Key")):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API-key")