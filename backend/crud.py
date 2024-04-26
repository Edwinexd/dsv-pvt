import os
from datetime import datetime
from sqlalchemy.orm import Session
import models, schemas
import requests #synchronous http
from fastapi import HTTPException

#USERS
def get_user(db_session: Session, user_id: int):
    return db_session.query(models.User).filter(models.User.id == user_id).first()

def get_users(db_session: Session, skip: int = 0, limit: int = 100):
    return db_session.query(models.User).offset(skip).limit(limit).all()

def create_user(db_session: Session, user: schemas.UserCreate):
    payload = {
        "username": user.username,
        "password": user.password
    }

    # maybe theres a better way to do this
    try:
        response = requests.post(os.getenv("AUTH_URL")+"/users", json=payload)
        response.raise_for_status()
    except requests.exceptions.HTTPError as e:
        raise HTTPException(e.response.status_code, detail=e.response.json()["detail"])

    user_id = response.json()["id"]

    date_created = datetime.today().isoformat()
    db_user = models.User(id=user_id, username = user.username, full_name = user.full_name, date_created = date_created)
    db_session.add(db_user)
    db_session.commit()
    db_session.refresh(db_user)
    return db_user

def update_user(db_session: Session, db_user: models.User, user_update: schemas.UserUpdate):
    update_data = user_update.model_dump(exclude_unset=True)
    for k, v in update_data.items():
        setattr(db_user, k, v)
    db_session.commit()
    db_session.refresh(db_user)
    return db_user

def delete_user(db_session: Session, db_user: models.User):
    db_session.delete(db_user)
    db_session.commit()

#PROFILES
def get_profile(db_session: Session, user_id: int):
    return get_user(db_session, user_id).profile

def create_profile(db_session: Session, profile: schemas.ProfileCreate, user_id: int):
    db_profile = models.Profile(
        description=profile.description,
        age=profile.age,
        interests=profile.interests,
        skill_level=profile.skill_level,
        is_private=profile.is_private
    )
    db_user = get_user(db_session, user_id)
    db_session.delete(db_user.profile)
    db_user.profile = db_profile
    db_session.add(db_user)
    db_session.commit()
    db_session.refresh(db_user)
    return db_profile

def update_profile(db_session: Session, db_profile: models.Profile, profile_update: schemas.ProfileUpdate):
    update_data = profile_update.model_dump(exclude_unset=True)
    for k, v in update_data.items():
        setattr(db_profile, k, v)
    db_session.commit()
    db_session.refresh(db_profile)
    return db_profile

def delete_profile(db_session: Session, db_profile: models.Profile):
    db_session.delete(db_profile)
    db_session.commit()

#GROUPS
def create_group(db_session: Session, group: schemas.GroupCreate):
    db_group = models.Group(group_name = group.group_name, description = group.description, private = group.private)
    db_session.add(db_group)
    db_session.commit()
    db_session.refresh(db_group)
    return db_group

# get a group from group_id
def get_group(db_session: Session, group_id: int):
    return db_session.query(models.Group).filter(models.Group.id == group_id).first()

# get a list of groups
def get_groups(db_session: Session, skip: int = 0, limit: int = 100):
    return db_session.query(models.Group).offset(skip).limit(limit).all()

def update_group(db_session: Session, db_group: models.Group, group_update: schemas.GroupUpdate):
    update_data = group_update.model_dump(exclude_unset=True)
    for k, v in update_data.items():
        setattr(db_group, k, v)
    db_session.commit()
    db_session.refresh(db_group)
    return db_group

def delete_group(db_session: Session, db_group: models.Group):
    db_session.delete(db_group)
    db_session.commit()

#MEMBERSHIPS
# join a user to a group
def join_group(db_session: Session, db_user: models.User, db_group: models.Group):
    db_group.users.append(db_user)
    db_session.add(db_group)
    db_session.commit()
    db_session.refresh(db_group)
    return db_group

def leave_group(db_session: Session, db_user: models.User, db_group: models.Group):
    db_group.users.remove(db_user)
    db_session.add(db_group)
    db_session.commit()
    db_session.refresh(db_group)
    return db_group

# get all groups a user is member of
def get_user_groups(db_session: Session, user_id: int):
    db_user = get_user(db_session, user_id)
    return db_user.groups

# get all users in a group
def get_group_users(db_session: Session, group_id: int):
    db_group = get_group(db_session, group_id)
    return db_group.users
