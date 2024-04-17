from fastapi import FastAPI, Depends, HTTPException
from typing import Optional, Annotated, Union
from pydantic import BaseModel
# fastapi.tiangolo.com/tutorial/sql-databases

from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

models.Base.metadata.create_all(bind = engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

#TODO: faulty data handling

# user creation
@app.post("/users", response_model = schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    return crud.create_user(db=db, user=user)

# get a list of users from db using a offset and size limit
@app.get("/users", response_model=list[schemas.User])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = crud.get_users(db, skip=skip, limit=limit)
    return users

#get a user from db using specific user id
@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(user_id: int, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

# group creation
@app.post("/groups", response_model = schemas.Group)
def create_group(group: schemas.GroupCreate, db: Session = Depends(get_db)):
    return crud.create_group(db=db, group=group)

@app.get("/groups/{group_id}", response_model=schemas.Group)
def read_group(group_id: int, db: Session = Depends(get_db)):
    db_group = crud.get_group(db, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    return db_group

@app.get("/groups", response_model=list[schemas.Group])
def read_groups(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    groups = crud.get_groups(db, skip=skip, limit=limit)
    return groups

# join group
@app.post("/groups/{group_id}/users", response_model=schemas.Group)
def join_group(user_id: int, group_id: int, db: Session = Depends(get_db)):
    db_user = read_user(user_id=user_id, db=db)
    db_group = read_group(group_id=group_id, db=db)
    if db_user in db_group.users:
        raise HTTPException(status_code=400, detail="User already in group")
    return crud.join_group(db=db, db_user=db_user, db_group=db_group)

#leave group
@app.delete("/groups/{group_id}/users", response_model=schemas.Group)
def leave_group(user_id: int, group_id: int, db: Session = Depends(get_db)):
    db_user = read_user(user_id=user_id, db=db)
    db_group = read_group(group_id=group_id, db=db)
    if db_user not in db_group.users:
        raise HTTPException(status_code=400, detail="User not in group")
    return crud.leave_group(db=db, db_user=db_user, db_group=db_group)

# get all members in a group by group_id
@app.get("/groups/{group_id}/users", response_model = list[schemas.User])
def read_members_in_group(group_id: int, db: Session = Depends(get_db)):
    users = crud.get_group_users(db=db, group_id=group_id)
    return users

# get all groups a user has joined
@app.get("/users/{user_id}/groups", response_model = list[schemas.Group])
def read_user_groups(user_id: int, db: Session = Depends(get_db)):
    groups = crud.get_user_groups(db=db, user_id=user_id)
    return groups

#TODO: activity creation, activity deletion, activity participation, activity reading
#TODO: challenge creation (by superusers), adding challenges to activities, reading all challanges, challenge-trophy link (?), reading all challenges in activity
