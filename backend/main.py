import os
from datetime import datetime
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Header
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

import crud
import models
import schemas
import auth
import validations
from user_roles import Roles
from database import engine, session_local
from sessions import create_session, get_session, revoke_session
from validations import validate_api_key

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

#should maybe be delete?
@app.post("/users/logout", status_code=204)
def logout(token: Annotated[HTTPAuthorizationCredentials, Depends(header_scheme)]):
    revoke_session(token.credentials)

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

#get current user
@app.get("/users/me", response_model=schemas.User)
def read_user_me(user: Annotated[schemas.SessionUser, Depends(get_current_user)], db_session: Session = Depends(get_db_session)):
    return crud.get_user(db_session, user.id)

#get a user from db using specific user id
@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@app.patch("/users/{user_id}", response_model=schemas.User)
def update_user(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, user_update: schemas.UserUpdate, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    if current_user.role is not Roles.ADMIN:
        validations.validate_id(user.id, user_id)
    return crud.update_user(db_session, db_user, user_update) #TODO: if name is updated, it needs to be mirrored in auth DB!

@app.delete("/users/{user_id}")
def delete_user(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    if current_user.role is not Roles.ADMIN:
        validations.validate_id(user.id, user_id)
    crud.delete_user(db_session, db_user)
    return {"message": "User deleted successfully"}

# ADMINS
@app.post("/admins")
def create_admin(admin_payload: schemas.UserCreate, db_session: Session = Depends(get_db_session), _: None = Depends(validate_api_key)):
    user_id = auth.create_user(admin_payload)
    user = schemas.User(id=user_id, username=admin_payload.username, full_name=admin_payload.full_name, date_created = datetime.today().isoformat(), role = Roles.ADMIN)
    return crud.create_user(db_session=db_session, user=user)

#PROFILE
@app.put("/users/{user_id}/profile", response_model=schemas.Profile)
def create_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], profile: schemas.ProfileCreate, user_id: str, db_session: Session = Depends(get_db_session)):
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    validations.validate_id(user.id, user_id)
    return crud.create_profile(db_session, profile, user_id)

@app.get("/users/{user_id}/profile", response_model=schemas.Profile)
def read_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_profile = crud.get_profile(db_session, user_id)
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    if db_profile.is_private != 0 and current_user.role is not Roles.ADMIN:
        validations.validate_id(user.id, user_id)
    return db_profile

@app.patch("/users/{user_id}/profile", response_model=schemas.Profile)
def update_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, profile_update: schemas.ProfileUpdate, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_profile = crud.get_profile(db_session, user_id)
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    if current_user.role is not Roles.ADMIN:
        validations.validate_id(user.id, user_id)
    return crud.update_profile(db_session, db_profile, profile_update)

@app.delete("/users/{user_id}/profile")
def delete_profile(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session) #TODO: refactor later
    db_profile = crud.get_profile(db_session, user_id)
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    if current_user.role is not Roles.ADMIN:
        validations.validate_id(user.id, user_id)
    crud.delete_profile(db_session, db_profile)
    return {"message": "Profile deleted successfully"}

#GROUP
# group creation
@app.post("/groups", response_model = schemas.Group)
def create_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group: schemas.GroupCreate, db_session: Session = Depends(get_db_session)):
    validations.validate_id(user.id, group.owner_id)
    return crud.create_group(db_session=db_session, group=group)

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
    current_user = read_user_me(user, db_session)
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    if current_user.role is not Roles.ADMIN:
        validations.validate_owns_group(user.id, db_group)
    return crud.update_group(db_session, db_group, group_update)

@app.delete("/groups/{group_id}")
def delete_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_group = crud.get_group(db_session, group_id=group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    if current_user.role is not Roles.ADMIN:
        validations.validate_owns_group(user.id, db_group)
    crud.delete_group(db_session, db_group)
    return {"message": "Group deleted successfully"}

#MEMBERSHIPS
# join group
@app.put("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def join_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, group_id: int, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user, user_id=user_id, db_session=db_session)
    db_group = read_group(user, group_id=group_id, db_session=db_session)
    if db_user in db_group.users:
        raise HTTPException(status_code=400, detail="User already in group")
    validations.validate_id(user.id, user_id)
    if db_group.is_private != 0:
        validations.validate_user_invited(read_user_me(user, db_session), crud.get_invited_users(db_session, db_group))
        crud.delete_invitation(db_session, user.id, group_id)
    return crud.join_group(db_session=db_session, db_user=db_user, db_group=db_group)

#leave group
@app.delete("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def leave_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, group_id: int, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = read_user(user, user_id=user_id, db_session=db_session)
    db_group = read_group(user, group_id=group_id, db_session=db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_user_in_group(db_user, db_group)
        validations.validate_id(user.id, user_id)
    return crud.leave_group(db_session=db_session, db_user=db_user, db_group=db_group)

# get all members in a group by group_id
@app.get("/groups/{group_id}/members", response_model = schemas.UserList) # TODO: skip,limit
def read_members_in_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, db_session: Session = Depends(get_db_session)):
    db_group = read_group(user, group_id, db_session)
    users = schemas.UserList(data=crud.get_group_users(db_session=db_session, db_group=db_group))
    return users

@app.get("/users/me/groups", response_model = schemas.GroupList) #TODO: skip,limit
def read_user_groups_me(user: Annotated[schemas.SessionUser, Depends(get_current_user)], db_session: Session = Depends(get_db_session)):
    db_user = read_user_me(user, db_session)
    groups = schemas.GroupList(data=crud.get_user_groups(db_session=db_session, db_user=db_user))
    return groups

# get all groups a user has joined
@app.get("/users/{user_id}/groups", response_model = schemas.GroupList) #TODO: skip,limit
def read_user_groups(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user, user_id, db_session)
    groups = schemas.GroupList(data=crud.get_user_groups(db_session=db_session, db_user=db_user))
    return groups

#INVITATIONS
# All of this needs extensive testing
@app.put("/groups/{group_id}/invites/{user_id}", response_model = schemas.Invite)
def invite_user(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, group_id: int, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user, user_id=user_id, db_session=db_session)
    db_group = read_group(user, group_id=group_id, db_session=db_session)
    if db_group.is_private == 0:
        raise HTTPException(status_code=400, detail="Can't create invite to public group!")
    
    validations.validate_user_in_group(crud.get_user(db_session, user.id), db_group) # user can only invite to group if user is in the group

    if db_user in crud.get_invited_users(db_session, db_group):
        raise HTTPException(status_code=400, detail="User already invited to group!")
    if db_user in db_group.users:
        raise HTTPException(status_code=400, detail="User already in group!")
    return crud.invite_user(db_session, db_user, db_group, user.id)

#get invited users in group
@app.get("/groups/{group_id}/invites", response_model = schemas.UserList) #TODO: skip, limit
def read_invited_users_in_group(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_group = read_group(user, group_id=group_id, db_session=db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_user_in_group(current_user, db_group)
    invited_users = schemas.UserList(data=crud.get_invited_users(db_session, db_group))
    return invited_users

#get groups current user is invited to
@app.get("/users/me/invites", response_model = schemas.GroupList) #TODO: skip, limit
def read_groups_invited_to(user: Annotated[schemas.SessionUser, Depends(get_current_user)], db_session: Session = Depends(get_db_session)):
    db_user = read_user(user, user.id, db_session)
    invited_to = schemas.GroupList(data=crud.get_groups_invited_to(db_session, db_user))
    return invited_to

@app.delete("/groups/{group_id}/invites/me")
def decline_invitation(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, db_session: Session = Depends(get_db_session)):
    db_group = read_group(user, group_id, db_session)
    invitation = crud.get_invitation(db_session, user.id, group_id)
    if invitation is None:
        raise HTTPException(status_code=404, detail="Invitation not found")
    crud.delete_invitation(db_session, user.id, group_id)
    return {"message" : "invitation successfully declined!"}

@app.delete("/groups/{group_id}/invites/{user_id}")
def delete_invitation(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, group_id: int, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = read_user(user, user_id, db_session)
    db_group = read_group(user, group_id, db_session)

    if db_group.is_private == 0:
        raise HTTPException(status_code=400, detail="Can't delete invite from public group!")
    
    invitation = crud.get_invitation(db_session, user_id, group_id)

    if invitation is None:
        raise HTTPException(status_code=404, detail="Invitation not found")
    
    if current_user.role is not Roles.ADMIN:
        validations.validate_current_is_inviter(current_user, invitation)
    crud.delete_invitation(db_session, user_id, group_id)
    return {"message": "Invitation successfully deleted!"}

# ACTIVITIES
@app.post("/groups/{group_id}/activities", response_model = schemas.Activity)
def create_activity(user: Annotated[schemas.SessionUser, Depends(get_current_user)], activity: schemas.ActivityCreate, group_id: int, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = read_user_me(user, db_session)
    db_group = read_group(user, group_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_user_in_group(db_user, db_group)

    activity_payload = schemas.ActivityPayload(
        activity_name=activity.activity_name,
        scheduled_date=activity.scheduled_date,
        difficulty_code=activity.difficulty_code,
        group_id=group_id,
        owner_id=user.id
    )
    return crud.create_activity(db_session, activity_payload)

@app.get("/groups/{group_id}/activities", response_model = schemas.ActivityList)
def read_activities(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, skip: int = 0, limit: int = 100, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = read_user_me(user, db_session)
    db_group = read_group(user, group_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_user_in_group(db_user, db_group)

    return schemas.ActivityList(data=crud.get_activities(db_session, group_id, skip, limit))

@app.get("/groups/{group_id}/activities/{activity_id}", response_model = schemas.Activity)
def read_activity(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, activity_id: int, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = read_user_me(user, db_session)
    db_group = read_group(user, group_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_user_in_group(db_user, db_group)

    db_activity = crud.get_activity(db_session, group_id, activity_id)
    if db_activity is None:
        raise HTTPException(status_code=404, detail="Activity not found")
    return db_activity

@app.patch("/groups/{group_id}/activities/{activity_id}", response_model = schemas.Activity)
def update_activity(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, activity_id, activity_update: schemas.ActivityUpdate, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_activity = read_activity(user, group_id, activity_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_owns_activity(user.id, db_activity)
    return crud.update_activity(db_session, db_activity, activity_update)

@app.delete("/groups/{group_id}/activities/{activity_id}")
def delete_activity(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, activity_id: int, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_activity = read_activity(user, group_id, activity_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_owns_activity(user.id, db_activity)
    crud.delete_activity(db_session, db_activity)
    return {"message" : "Activity successfully deleted!"}

# ACTIVITY PARTICIPATION
@app.put("/group/{group_id}/activities/{activity_id}/participants/{participant_id}")
def join_activity(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, activity_id: int, participant_id: str, db_session: Session = Depends(get_db_session)):
    db_user = read_user(user, participant_id, db_session)
    db_group = read_group(user, group_id, db_session)
    validations.validate_user_in_group(db_user, db_group)
    validations.validate_id(user.id, participant_id)

    db_activity = read_activity(user, group_id, activity_id, db_session)
    if db_user in db_activity.participants:
        raise HTTPException(status_code=400, detail="User already in activity")
    
    crud.join_activity(db_session, db_user, db_activity)
    return {"message" : "Activity successfully joined!"}

@app.get("/group/{group_id}/activities/{activity_id}/participants", response_model = schemas.UserList)
def read_participants(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, activity_id: int, skip: int = 0, limit: int = 100, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_group = read_group(user, group_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_user_in_group(current_user, db_group)

    db_activity = read_activity(user, group_id, activity_id, db_session)

    return schemas.UserList(data=crud.get_participants(db_session, db_activity, skip, limit))

@app.get("/users/{user_id}/activities", response_model = schemas.ActivityList)
def read_user_activities(user: Annotated[schemas.SessionUser, Depends(get_current_user)], user_id: str, skip: int = 0, limit: int = 100, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = read_user(user, user_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_id(user.id, user_id)
    return schemas.ActivityList(data=crud.get_user_activities(db_session, db_user, skip, limit))

@app.delete("/groups/{group_id}/activities/{activity_id}/participants/{participant_id}")
def leave_activity(user: Annotated[schemas.SessionUser, Depends(get_current_user)], group_id: int, activity_id: int, participant_id: str, db_session: Session = Depends(get_db_session)):
    current_user = read_user_me(user, db_session)
    db_user = read_user(user, participant_id, db_session)
    db_group = read_group(user, group_id, db_session)
    db_activity = read_activity(user, group_id, activity_id, db_session)
    if current_user.role is not Roles.ADMIN:
        validations.validate_id(user.id, participant_id)
        validations.validate_user_in_group(db_user, db_group)
        validations.validate_user_in_activity(db_user, db_activity)
    
    crud.leave_activity(db_session, db_user, db_activity)
    return {"message": "activity successfully left!"}


#TODO: moderators, admins
#TODO: challenge creation (by superusers), adding challenges to activities
#TODO: reading all challanges, challenge-trophy link (?), reading all challenges in activity