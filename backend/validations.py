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
    # Type issues with relationship attributes
    if user not in group.users and current_user.role is not Roles.ADMIN:  # type: ignore
        raise HTTPException(status_code=403, detail="User is not in this group")


def validate_user_in_activity(
    current_user: models.User, user: models.User, activity: models.Activity
):
    # Type issues with relationship attributes
    if user not in activity.participants and current_user.role is not Roles.ADMIN:  # type: ignore
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


def validate_is_admin(current_user: models.User):
    if current_user.role is not Roles.ADMIN:
        raise HTTPException(status_code=403, detail="User is not admin")


def validate_api_key(api_key: str = Header(alias="ADMIN-API-Key")):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API-key")


def validate_activity_is_not_completed(
    current_user: models.User, activity: models.Activity
):
    if activity.is_completed != 0 and current_user.role is not Roles.ADMIN:
        raise HTTPException(
            status_code=400,
            detail="Activity is already completed and as such cannot be updated",
        )


def validate_has_achievement(user: models.User, achivement: models.Achievement):
    # Type issues with relationship attributes
    if achivement not in user.completed_achievements:  # type: ignore
        raise HTTPException(
            status_code=403, detail="User does not have this achievement"
        )
