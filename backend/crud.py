from sqlalchemy.orm import Session
from datetime import datetime

import models, schemas

def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()

def create_user(db: Session, user: schemas.UserCreate):
    date_created = datetime.today().isoformat()
    db_user = models.User(username = user.username, full_name = user.full_name, date_created = date_created)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_group(db: Session, group: schemas.GroupCreate):
    db_group = models.Group(group_name = group.group_name, description = group.description, private = group.private)
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    return db_group

# get a group from group_id
def get_group(db: Session, group_id: int):
    return db.query(models.Group).filter(models.Group.id == group_id).first()

# get a list of groups
def get_groups(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Group).offset(skip).limit(limit).all()

# join a user to a group
def join_group(db: Session, db_user: models.User, db_group: models.Group):
    db_group.users.append(db_user)
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    return db_group

# get all groups a user is member of
def get_user_groups(db: Session, user_id: int):
    db_user = get_user(db, user_id)
    return db_user.groups

# get all users in a group
def get_group_users(db: Session, group_id: int):
    db_group = get_group(db, group_id)
    return db_group.users
