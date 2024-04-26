import os
from datetime import datetime
from typing import Annotated

import requests
from fastapi import Depends, FastAPI, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi.security.base import SecurityBase
from sqlalchemy.orm import Session

import crud
import models
import schemas
import auth
from validations import validate_id, validate_user_in_group, validate_owns_group
from database import engine, session_local
from sessions import create_session, get_session

models.base.metadata.create_all(bind = engine)


app = FastAPI()

def get_db_session():
    db_session = session_local()
    try:
        yield db_session
    finally:
        db_session.close()

header_scheme = HTTPBearer()

def get_current_user(token: Annotated[HTTPAuthorizationCredentials, Depends(header_scheme)]) -> schemas.SessionUser:
    session = get_session(token.credentials)
    if session is None:
        raise HTTPException(status_code=401, detail="Unauthorized", headers={"WWW-Authenticate": "Bearer"})
    
    return session


#USER
#login
# TODO: Properly annotate in OPENAPI that it requires credentials
@app.post("/users/login")
def login(credentials: schemas.UserCreds):
    user_id = auth.login(credentials)
    session = create_session(user_id)
    return {"bearer": f"Bearer {session}"}

# user creation
@app.post("/users", response_model = schemas.User)
def create_user(user_payload: schemas.UserCreate, db_session: Session = Depends(get_db_session)):
    user_id = auth.create_user(user_payload)
    user = schemas.User(id=user_id, username=user_payload.username, full_name=user_payload.full_name, date_created = datetime.today().isoformat())
    return crud.create_user(db_session=db_session, user=user)

# get a list of users from db using a offset and size limit
@app.get("/users", response_model = schemas.UserList)
def read_users(user: Annotated[schemas.SessionUser, Depends(get_current_user)], skip: int = 0, limit: int = 100, db_session: Session = Depends(get_db_session)):
    users = schemas.UserList(data=crud.get_users(db_session, skip=skip, limit=limit))
    return users

#get a user from db using specific user id
@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@app.patch("/users/{user_id}", response_model=schemas.User)
def update_user(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, user_update: schemas.UserUpdate, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    validate_id(user.id, user_id)
    return crud.update_user(db_session, db_user, user_update)

@app.delete("/users/{user_id}")
def delete_user(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    validate_id(user.id, user_id)
    crud.delete_user(db_session, db_user)
    return {"message": "User deleted successfully"}

#PROFILE
@app.put("/users/{user_id}/profile", response_model=schemas.Profile)
def create_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], profile: schemas.ProfileCreate, user_id: str, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    validate_id(user.id, user_id)
    return crud.create_profile(db_session, profile, user_id)

@app.get("/users/{user_id}/profile", response_model=schemas.Profile)
def read_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    db_profile = crud.get_profile(db_session, user_id)
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    if db_profile.is_private:
        validate_id(user.id, user_id)
    return db_profile

@app.patch("/users/{user_id}/profile", response_model=schemas.Profile)
def update_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, profile_update: schemas.ProfileUpdate, db_session: Session = Depends(get_db_session)):
    db_profile = crud.get_profile(db_session, user_id)
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    validate_id(user.id, user_id)
    return crud.update_profile(db_session, db_profile, profile_update)

@app.delete("/users/{user_id}/profile")
def delete_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    db_profile = crud.get_profile(db_session, user_id)
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    validate_id(user.id, user_id)
    crud.delete_profile(db_session, db_profile)
    return {"message": "Profile deleted successfully"}

#GROUP
# group creation
@app.post("/groups", response_model = schemas.Group)
def create_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group: schemas.GroupCreate, db_session: Session = Depends(get_db_session)):
    return crud.create_group(db_session=db_session, group=group, owner_id = user.id)

@app.get("/groups/{group_id}", response_model=schemas.Group)
def read_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, db_session: Session = Depends(get_db_session)):
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    return db_group

@app.get("/groups", response_model=schemas.GroupList)
def read_groups(user: Annotated[schemas.SessionUser, Depends(get_current_user)], skip: int = 0, limit: int = 100, db_session: Session = Depends(get_db_session)):
    groups = schemas.GroupList(data=crud.get_groups(db_session, skip=skip, limit=limit))
    return groups

@app.patch("/groups/{group_id}", response_model=schemas.Group)
def update_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, group_update: schemas.GroupUpdate, db_session: Session = Depends(get_db_session)):
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    validate_owns_group(user.id, db_group)
    return crud.update_group(db_session, db_group, group_update)

@app.delete("/groups/{group_id}")
def delete_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, db_session: Session = Depends(get_db_session)):
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    validate_owns_group(user.id, db_group)
    crud.delete_group(db_session, db_group)
    return {"message": "Group deleted successfully"}

#MEMBERSHIPS
# join group
@app.put("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def join_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, group_id: int, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user_id=user_id, db_session=db_session)
    db_group = read_group(group_id=group_id, db_session=db_session)
    if db_user in db_group.users:
        raise HTTPException(status_code=400, detail="User already in group")
    validate_id(user.id, user_id)
    #TODO: if private, check if user is invited
    return crud.join_group(db_session=db_session, db_user=db_user, db_group=db_group)

#leave group
@app.delete("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def leave_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, group_id: int, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user_id=user_id, db_session=db_session)
    db_group = read_group(group_id=group_id, db_session=db_session)
    if db_user not in db_group.users:
        raise HTTPException(status_code=400, detail="User not in group")
    validate_id(user.id, user_id)
    return crud.leave_group(db_session=db_session, db_user=db_user, db_group=db_group)

# get all members in a group by group_id
@app.get("/groups/{group_id}/members", response_model = schemas.UserList)
def read_members_in_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, db_session: Session = Depends(get_db_session)):
    users = schemas.UserList(data=crud.get_group_users(db_session=db_session, group_id=group_id))
    return users

# get all groups a user has joined
@app.get("/users/{user_id}/groups", response_model = schemas.GroupList)
def read_user_groups(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    groups = schemas.GroupList(data=crud.get_user_groups(db_session=db_session, user_id=user_id))
    return groups

#TODO: activity creation, activity deletion, activity participation, activity reading
#TODO: challenge creation (by superusers), adding challenges to activities
#TODO: reading all challanges, challenge-trophy link (?), reading all challenges in activity