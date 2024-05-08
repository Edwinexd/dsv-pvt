import os
from fastapi import HTTPException, Header, Query
import models
from user_roles import Roles
from datetime import datetime
import re

API_KEY = os.getenv("API_KEY")


def validate_id(current_user: models.User, requested_user_id: str):
    if current_user.id != requested_user_id and current_user.role is not Roles.ADMIN:
        raise HTTPException(status_code=403, detail="User is not current user")


def validate_user_in_group(
    current_user: models.User, user: models.User, group: models.Group
):
    if user not in group.users and current_user.role is not Roles.ADMIN:
        raise HTTPException(status_code=403, detail="User is not in this group")


def validate_user_in_activity(
    current_user: models.User, user: models.User, activity: models.Activity
):
    if user not in activity.participants and current_user.role is not Roles.ADMIN:
        raise HTTPException(status_code=403, detail="User is not in this activity")


def validate_owns_group(current_user: models.User, group: models.Group):
    if group.owner_id != current_user.id and current_user.role is not Roles.ADMIN:
        raise HTTPException(status_code=403, detail="User does not own this group!")


def validate_owns_activity(current_user: models.User, activity: models.Activity):
    if activity.owner_id != current_user.id and current_user.role is not Roles.ADMIN:
        raise HTTPException(status_code=403, detail="User does not own this activity!")


def validate_user_invited(current_user: models.User, invited_users: list[models.User]):
    if current_user not in invited_users and current_user.role is not Roles.ADMIN:
        raise HTTPException(
            status_code=403, detail="You are not invited to this group!"
        )


def validate_current_is_inviter(
    current_user: models.User, invitation: models.GroupInvitations
):
    if (
        current_user.id != invitation.invited_by
        and current_user.role is not Roles.ADMIN
    ):
        raise HTTPException(
            status_code=403, detail="You cannot delete another users invitation!"
        )


def validate_api_key(api_key: str = Header(alias="ADMIN-API-Key")):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API-key")


def validate_has_achievement(user: models.User, achivement: models.Achievement):
    if achivement not in user.completed_achievements:
        raise HTTPException(
            status_code=403, detail="User does not have this achievement"
        )
