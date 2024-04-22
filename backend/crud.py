from datetime import datetime
from sqlalchemy.orm import Session
import models, schemas

def get_user(db_session: Session, user_id: int):
    return db_session.query(models.User).filter(models.User.id == user_id).first()

def get_users(db_session: Session, skip: int = 0, limit: int = 100):
    return db_session.query(models.User).offset(skip).limit(limit).all()

def create_user(db_session: Session, user: schemas.UserCreate):
    date_created = datetime.today().isoformat()
    db_user = models.User(username = user.username, full_name = user.full_name, date_created = date_created)
    db_session.add(db_user)
    db_session.commit()
    db_session.refresh(db_user)
    return db_user

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
