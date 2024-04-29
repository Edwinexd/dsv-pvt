from fastapi import HTTPException
import models
from datetime import datetime

def validate_id(current_user_id, requested_user_id):
    if current_user_id != requested_user_id:
        raise HTTPException(status_code=403, detail="User is not current user")
    
def validate_user_in_group(user: models.User, group: models.Group):
    if user not in group.users:
        raise HTTPException(status_code=403, detail="User is not in this group")
    
def validate_owns_group(user_id: str, group: models.Group):
    if group.owner_id != user_id:
        raise HTTPException(status_code=403, detail="User does not own this group!")
    
def validate_user_invited(user: models.User, invited_users: list[models.User]):
    if user not in invited_users:
        raise HTTPException(status_code=403, detail="You are not invited to this group!")
    
def validate_current_is_inviter(current_user: models.User, invitation: models.GroupInvitations):
    if current_user.id != invitation.invited_by:
        raise HTTPException(status_code=403, detail="You cannot delete another users invitation!")
    
def validate_isoformat(date: str):
    try:
        datetime.fromisoformat(date)
    except:
        raise HTTPException(status_code = 400, detail = "Scheduled date is not in ISO-format!")