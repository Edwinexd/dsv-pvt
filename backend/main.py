from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import crud, models, schemas
from database import session_local, engine

models.base.metadata.create_all(bind = engine)

app = FastAPI()

def get_db_session():
    db_session = session_local()
    try:
        yield db_session
    finally:
        db_session.close()

#USER
# user creation
@app.post("/users", response_model = schemas.User)
def create_user(user: schemas.UserCreate, db_session: Session = Depends(get_db_session)):
    return crud.create_user(db_session=db_session, user=user)

# get a list of users from db using a offset and size limit
@app.get("/users", response_model = schemas.UserList)
def read_users(skip: int = 0, limit: int = 100, db_session: Session = Depends(get_db_session)):
    users = schemas.UserList(data=crud.get_users(db_session, skip=skip, limit=limit))
    return users

#get a user from db using specific user id
@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(user_id: int, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@app.patch("/users/{user_id}", response_model=schemas.User)
def update_user(user_id: int, user_update: schemas.UserUpdate, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return crud.update_user(db_session, db_user, user_update)

@app.delete("/users/{user_id}")
def delete_user(user_id: int, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    crud.delete_user(db_session, db_user)
    return {"message": "User deleted successfully"}

# group creation
@app.post("/groups", response_model = schemas.Group)
def create_group(group: schemas.GroupCreate, db_session: Session = Depends(get_db_session)):
    return crud.create_group(db_session=db_session, group=group)

@app.get("/groups/{group_id}", response_model=schemas.Group)
def read_group(group_id: int, db_session: Session = Depends(get_db_session)):
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    return db_group

@app.get("/groups", response_model=schemas.GroupList)
def read_groups(skip: int = 0, limit: int = 100, db_session: Session = Depends(get_db_session)):
    groups = schemas.GroupList(data=crud.get_groups(db_session, skip=skip, limit=limit))
    return groups

@app.patch("/groups/{group_id}", response_model=schemas.Group)
def update_group(group_id: int, group_update: schemas.GroupUpdate, db_session: Session = Depends(get_db_session)):
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    return crud.update_group(db_session, db_group, group_update)

@app.delete("/groups/{group_id}")
def delete_group(group_id: int, db_session: Session = Depends(get_db_session)):
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    crud.delete_group(db_session, db_group)
    return {"message": "Group deleted successfully"}

#MEMBERSHIPS
# join group
@app.put("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def join_group(user_id: int, group_id: int, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user_id=user_id, db_session=db_session)
    db_group = read_group(group_id=group_id, db_session=db_session)
    if db_user in db_group.users:
        raise HTTPException(status_code=400, detail="User already in group")
    return crud.join_group(db_session=db_session, db_user=db_user, db_group=db_group)

#leave group
@app.delete("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def leave_group(user_id: int, group_id: int, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user_id=user_id, db_session=db_session)
    db_group = read_group(group_id=group_id, db_session=db_session)
    if db_user not in db_group.users:
        raise HTTPException(status_code=400, detail="User not in group")
    return crud.leave_group(db_session=db_session, db_user=db_user, db_group=db_group)

# get all members in a group by group_id
@app.get("/groups/{group_id}/members", response_model = schemas.UserList)
def read_members_in_group(group_id: int, db_session: Session = Depends(get_db_session)):
    users = schemas.UserList(data=crud.get_group_users(db_session=db_session, group_id=group_id))
    return users

# get all groups a user has joined
@app.get("/users/{user_id}/groups", response_model = schemas.GroupList)
def read_user_groups(user_id: int, db_session: Session = Depends(get_db_session)):
    groups = schemas.GroupList(data=crud.get_user_groups(db_session=db_session, user_id=user_id))
    return groups

#TODO: activity creation, activity deletion, activity participation, activity reading
#TODO: challenge creation (by superusers), adding challenges to activities
#TODO: reading all challanges, challenge-trophy link (?), reading all challenges in activity
