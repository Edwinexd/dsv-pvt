from sqlalchemy.orm import Session
from datetime import datetime

import models, schemas

def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()

def create_user(db: Session, user: schemas.UserCreate):
    date_created = datetime.today().strftime('%Y-%m-%d')
    db_user = models.User(username = user.username, full_name = user.full_name, date_created = date_created)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
