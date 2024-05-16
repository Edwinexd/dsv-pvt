import logging
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, UploadFile
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

import crud
import models
import schemas
import auth
import validations
import images
from user_roles import Roles
from database import engine, session_local
from sessions import create_session, get_session, revoke_session
from validations import validate_api_key
import requests

models.base.metadata.create_all(bind=engine)

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"(https://pvt\.edt\.cx)|(http://localhost:\d{2,5})|(http://10\.97\.231\.1:81)",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db_session():
    db_session = session_local()
    try:
        yield db_session
    finally:
        db_session.close()


DbSession = Annotated[Session, Depends(get_db_session)]

header_scheme = HTTPBearer()


def get_current_user(
    token: Annotated[HTTPAuthorizationCredentials, Depends(header_scheme)]
) -> schemas.SessionUser:
    session = get_session(token.credentials)
    if session is None:
        raise HTTPException(
            status_code=401,
            detail="Unauthorized",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return session


def get_db_user(
    user: Annotated[schemas.SessionUser, Depends(get_current_user)],
    db_session: DbSession,
):
    return crud.get_user(db_session, user.id)


DbUser = Annotated[models.User, Depends(get_db_user)]


def get_user(user_id: str, db_session: DbSession):
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


RequestedUser = Annotated[models.User, Depends(get_user)]


def get_profile(user_id: str, db_session: DbSession):
    db_profile = crud.get_profile(db_session, user_id)
    if db_profile is None:
        raise HTTPException(status_code=404, detail="Profile not found")
    return db_profile


RequestedProfile = Annotated[models.Profile, Depends(get_profile)]


def get_group(group_id: int, db_session: DbSession):
    db_group = crud.get_group(db_session, group_id)
    if db_group is None:
        raise HTTPException(status_code=404, detail="Group not found")
    return db_group


RequestedGroup = Annotated[models.Group, Depends(get_group)]


def get_activity(group_id: int, activity_id: int, db_session: DbSession):
    db_activity = crud.get_activity(db_session, group_id, activity_id)
    if db_activity is None:
        raise HTTPException(status_code=404, detail="Activity not found")
    return db_activity


RequestedActivity = Annotated[models.Activity, Depends(get_activity)]


def get_achievement(achievement_id: int, db_session: DbSession):
    db_achievement = crud.get_achievement(db_session, achievement_id)
    if db_achievement is None:
        raise HTTPException(status_code=404, detail="Achievement not found")
    return db_achievement


RequestedAchievement = Annotated[models.Achievement, Depends(get_achievement)]


def get_challenge(challenge_id: int, db_session: DbSession):
    db_challenge = crud.get_challenge(db_session, challenge_id)
    if db_challenge is None:
        raise HTTPException(status_code=404, detail="Challenge not found")
    return db_challenge


RequestedChallenge = Annotated[models.Challenge, Depends(get_challenge)]


# IMAGES
# profile pic
@app.put("/users/{user_id}/profile/picture", status_code=204)
def upload_pfp(
    current_user: DbUser,
    db_session: DbSession,
    requested_profile: RequestedProfile,
    image: UploadFile,
):
    validations.validate_id(current_user, requested_profile.owner_id)
    if requested_profile.image_id is not None:
        images.delete(requested_profile.image_id)
    id = images.upload(image=image)
    crud.update_profile(
        db_session, requested_profile, schemas.ProfileImageUpdate(image_id=str(id))
    )


@app.delete("/users/{user_id}/profile/picture", status_code=204)
def delete_pfp(
    current_user: DbUser, db_session: DbSession, requested_profile: RequestedProfile
):
    validations.validate_id(current_user, requested_profile.owner_id)
    if requested_profile.image_id is None:
        raise HTTPException(status_code=404, detail="Profile picture not found")
    images.delete(requested_profile.image_id)
    crud.update_profile(
        db_session, requested_profile, schemas.ProfileImageUpdate(image_id=None)
    )


# group pic
@app.put("/groups/{group_id}/picture", status_code=204)
def upload_group_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    image: UploadFile,
):
    validations.validate_owns_group(current_user, requested_group)
    if requested_group.image_id is not None:
        images.delete(requested_group.image_id)
    id = images.upload(image=image)
    crud.update_group(
        db_session, requested_group, schemas.GroupImageUpdate(image_id=str(id))
    )


@app.delete("/groups/{group_id}/picture", status_code=204)
def delete_group_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
):
    validations.validate_owns_group(current_user, requested_group)
    if requested_group.image_id is None:
        raise HTTPException(status_code=404, detail="Group picture not found")
    images.delete(requested_group.image_id)
    crud.update_group(
        db_session, requested_group, schemas.GroupImageUpdate(image_id=None)
    )


# activity pic
@app.put("/groups/{group_id}/activites/{activity_id}/picture", status_code=204)
def upload_activity_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    requested_activity: RequestedActivity,
    image: UploadFile,
):
    validations.validate_owns_activity(current_user, requested_group)
    if requested_activity.image_id is not None:
        images.delete(requested_activity.image_id)
    id = images.upload(image=image)
    crud.update_activity(
        db_session, requested_activity, schemas.ActivityImageUpdate(image_id=str(id))
    )


@app.delete("/groups/{group_id}/activites/{activity_id}/picture", status_code=204)
def delete_activity_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    requested_activity: RequestedActivity,
):
    validations.validate_owns_activity(current_user, requested_group)
    if requested_activity.image_id is None:
        raise HTTPException(status_code=404, detail="Activity picture not found")
    images.delete(requested_activity.image_id)
    crud.update_activity(
        db_session, requested_activity, schemas.ActivityImageUpdate(image_id=None)
    )


# challenge pic
@app.put("/challenges/{challenge_id}/picture", status_code=204)
def upload_challenge_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_challenge: RequestedChallenge,
    image: UploadFile,
):
    validations.validate_is_admin(current_user)
    if requested_challenge.image_id is not None:
        images.delete(requested_challenge.image_id)
    id = images.upload(image=image)
    crud.update_challenge(
        db_session, requested_challenge, schemas.ChallengeImageUpdate(image_id=str(id))
    )


# dunno if this is even needed but keeping it anyway
@app.delete("/challenges/{challenge_id}/picture", status_code=204)
def delete_challenge_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_challenge: RequestedChallenge,
):
    validations.validate_is_admin(current_user)
    if requested_challenge.image_id is None:
        raise HTTPException(status_code=404, detail="Challenge picture not found")
    images.delete(requested_challenge.image_id)
    crud.update_challenge(
        db_session, requested_challenge, schemas.ChallengeImageUpdate(image_id=None)
    )


# achievement pic
@app.put("/achievements/{achievement_id}/picture", status_code=204)
def upload_achievement_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_achievement: RequestedAchievement,
    image: UploadFile,
):
    validations.validate_is_admin(current_user)
    if requested_achievement.image_id is not None:
        images.delete(requested_achievement.image_id)
    id = images.upload(image=image)
    crud.update_achievement(
        db_session,
        requested_achievement,
        schemas.AchievementImageUpdate(image_id=str(id)),
    )


@app.delete("/achivements/{achievement_id}/picture", status_code=204)
def delete_achievement_pic(
    current_user: DbUser,
    db_session: DbSession,
    requested_achievement: RequestedAchievement,
):
    validations.validate_is_admin(current_user)
    if requested_achievement.image_id is None:
        raise HTTPException(status_code=404, detail="Achievement picture not found")
    images.delete(requested_achievement.image_id)
    crud.update_achievement(
        db_session, requested_achievement, schemas.AchievementImageUpdate(image_id=None)
    )


# USER
# login
# TODO: Properly annotate in OPENAPI that it requires credentials
@app.post("/users/login")
def login(credentials: schemas.UserCreds, db_session: DbSession):
    user_id = auth.login(credentials)
    # Attempt to get user from db before creating session
    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        logging.error("User (id: %s) not found in database!", user_id)
        raise HTTPException(status_code=500, detail="State mismatch")

    session = create_session(user_id)
    return {"bearer": f"Bearer {session}"}


@app.post("/users/login/oauth/google")
async def login_with_google(token_data: schemas.AccessToken, db_session: DbSession):
    user_id = auth.login_ouath(token_data.access_token, "google")

    db_user = crud.get_user(db_session, user_id)
    if db_user is None:
        logging.error("User (id: %s) not found in database!", user_id)
        raise HTTPException(status_code=500, detail="State mismatch")

    session = create_session(user_id)
    return {"bearer": f"Bearer {session}"}


@app.post("/users/logout", status_code=204)
def logout(token: Annotated[HTTPAuthorizationCredentials, Depends(header_scheme)]):
    revoke_session(token.credentials)


# user creation
@app.post("/users", response_model=schemas.User)
def create_user(user_payload: schemas.UserCreate, db_session: DbSession):
    user_id = auth.create_user(user_payload)
    user = schemas.UserModel(
        id=user_id,
        email=user_payload.email,
        username=user_payload.username,
        full_name=user_payload.full_name,
    )
    return crud.create_user(db_session=db_session, user=user)


# get a list of users from db using a offset and size limit
@app.get("/users", response_model=schemas.UserList)
def read_users(
    current_user: DbUser, db_session: DbSession, skip: int = 0, limit: int = 100
):
    users = schemas.UserList(data=crud.get_users(db_session, skip=skip, limit=limit))
    return users


# get current user
@app.get("/users/me", response_model=schemas.User)
def read_user_me(current_user: DbUser, db_session: DbSession):
    return current_user


# get a user from db using specific user id
@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(current_user: DbUser, requested_user: RequestedUser):
    return requested_user


# TODO: is there any way to send this dbsession to the requested_user dependency?
@app.patch("/users/{user_id}", response_model=schemas.User)
def update_user(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    user_update: schemas.UserUpdate,
):
    validations.validate_id(current_user, requested_user.id)
    return crud.update_user(
        db_session, requested_user, user_update
    )  # TODO: if name is updated, it needs to be mirrored in auth DB!


@app.delete("/users/{user_id}")
def delete_user(
    current_user: DbUser, db_session: DbSession, requested_user: RequestedUser
):
    validations.validate_id(current_user, requested_user.id)
    crud.delete_user(db_session, requested_user.id)
    return {"message": "User deleted successfully"}


# ADMINS
@app.post("/admins")
# TODO Switch to Annotated
def create_admin(
    admin_payload: schemas.UserCreate,
    db_session: DbSession,
    _: Annotated[None, Depends(validate_api_key)],
):
    user_id = auth.create_user(admin_payload)
    user = schemas.UserModel(
        id=user_id,
        email=admin_payload.email,
        username=admin_payload.username,
        full_name=admin_payload.full_name,
        role=Roles.ADMIN,
    )
    return crud.create_user(db_session=db_session, user=user)


# PROFILE
@app.put("/users/{user_id}/profile", response_model=schemas.Profile)
def create_profile(
    current_user: DbUser,
    db_session: DbSession,
    profile: schemas.ProfileCreate,
    requested_user: RequestedUser,
):
    validations.validate_id(current_user, requested_user.id)
    return crud.create_profile(db_session, profile, requested_user.id)


@app.get("/users/{user_id}/profile", response_model=schemas.Profile)
def read_profile(
    current_user: DbUser,
    requested_user: RequestedUser,
    requested_profile: RequestedProfile,
):
    if requested_profile.is_private != 0:
        validations.validate_id(current_user, requested_user.id)
    return requested_profile


@app.patch("/users/{user_id}/profile", response_model=schemas.Profile)
def update_profile(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    requested_profile: RequestedProfile,
    profile_update: schemas.ProfileUpdate,
):
    validations.validate_id(current_user, requested_user.id)
    return crud.update_profile(db_session, requested_profile, profile_update)


@app.delete("/users/{user_id}/profile", status_code=204)
def delete_profile(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    requested_profile: RequestedProfile,
):
    validations.validate_id(current_user, requested_user.id)
    crud.delete_profile(db_session, requested_profile)


# GROUP
# group creation
@app.post("/groups", response_model=schemas.Group)
def create_group(
    current_user: DbUser, db_session: DbSession, group: schemas.GroupCreate
):
    validations.validate_id(current_user, group.owner_id)
    return crud.create_group(db_session=db_session, group=group)


@app.get("/groups/{group_id}", response_model=schemas.Group)
def read_group(
    current_user: DbUser, db_session: DbSession, requested_group: RequestedGroup
):
    return schemas.Group(
        group_name=requested_group.group_name,
        description=requested_group.description,
        is_private=requested_group.is_private,
        owner_id=requested_group.owner_id,
        id=requested_group.id,
        points=crud.get_group_points(requested_group),
        image_id=requested_group.image_id,
        latitude=requested_group.latitude,
        longitude=requested_group.longitude,
        address=requested_group.address,
    )


@app.get("/groups", response_model=schemas.GroupList)
def read_groups(
    current_user: DbUser, db_session: DbSession, skip: int = 0, limit: int = 100
):
    groups = schemas.GroupList(data=crud.get_groups(db_session, skip=skip, limit=limit))
    for g in groups.data:
        g.points = crud.get_group_points(crud.get_group(db_session, g.id))
    return groups


@app.patch("/groups/{group_id}", response_model=schemas.Group)
def update_group(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    group_update: schemas.GroupUpdate,
):
    validations.validate_owns_group(current_user, requested_group)
    return crud.update_group(db_session, requested_group, group_update)


@app.delete("/groups/{group_id}", status_code=204)
def delete_group(
    current_user: DbUser, requested_group: RequestedGroup, db_session: DbSession
):
    validations.validate_owns_group(current_user, requested_group)
    crud.delete_group(db_session, requested_group)


# MEMBERSHIPS
# join group
@app.put("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def join_group(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    requested_group: RequestedGroup,
):
    if requested_user in requested_group.users:
        raise HTTPException(status_code=400, detail="User already in group")
    validations.validate_id(current_user, requested_user.id)
    if requested_group.is_private != 0:
        validations.validate_user_invited(current_user, requested_group.invited_users)
        crud.delete_invitation(db_session, current_user.id, requested_group.id)
    return crud.join_group(
        db_session=db_session, db_user=requested_user, db_group=requested_group
    )


# leave group
@app.delete("/groups/{group_id}/members/{user_id}", response_model=schemas.Group)
def leave_group(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    requested_group: RequestedGroup,
):
    validations.validate_user_in_group(current_user, requested_user, requested_group)
    validations.validate_id(current_user, requested_user.id)
    return crud.leave_group(
        db_session=db_session, db_user=requested_user, db_group=requested_group
    )


# get all members in a group by group_id
@app.get(
    "/groups/{group_id}/members", response_model=schemas.UserList
)  # TODO: skip,limit
def read_members_in_group(current_user: DbUser, requested_group: RequestedGroup):
    users = schemas.UserList(data=requested_group.users)
    return users


@app.get("/users/me/groups", response_model=schemas.GroupList)  # TODO: skip,limit
def read_user_groups_me(current_user: DbUser):
    groups = schemas.GroupList(data=current_user.groups)
    return groups


# get all groups a user has joined
@app.get(
    "/users/{user_id}/groups", response_model=schemas.GroupList
)  # TODO: skip,limit
def read_user_groups(current_user: DbUser, requested_user: RequestedUser):
    groups = schemas.GroupList(data=requested_user.groups)
    return groups


# INVITATIONS
@app.put("/groups/{group_id}/invites/{user_id}", response_model=schemas.Invite)
def invite_user(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    requested_group: RequestedGroup,
):
    if requested_group.is_private == 0:
        raise HTTPException(
            status_code=400, detail="Can't create invite to public group!"
        )

    validations.validate_user_in_group(
        current_user, current_user, requested_group
    )  # user can only invite to group if user is in the group

    if requested_user in crud.get_invited_users(db_session, requested_group):
        raise HTTPException(status_code=400, detail="User already invited to group!")
    if requested_user in requested_group.users:
        raise HTTPException(status_code=400, detail="User already in group!")
    return crud.invite_user(
        db_session, requested_user, requested_group, current_user.id
    )


# get invited users in group
@app.get(
    "/groups/{group_id}/invites", response_model=schemas.UserList
)  # TODO: skip, limit
def read_invited_users_in_group(current_user: DbUser, requested_group: RequestedGroup):
    validations.validate_user_in_group(current_user, current_user, requested_group)
    invited_users = schemas.UserList(data=requested_group.invited_users)
    return invited_users


# get groups current user is invited to
@app.get("/users/me/invites", response_model=schemas.GroupList)  # TODO: skip, limit
def read_groups_invited_to(current_user: DbUser):
    invited_to = schemas.GroupList(data=current_user.groups_invited_to)
    return invited_to


@app.delete("/groups/{group_id}/invites/me", status_code=204)
def decline_invitation(
    current_user: DbUser, db_session: DbSession, requested_group: RequestedGroup
):
    invitation = crud.get_invitation(db_session, current_user.id, requested_group.id)
    if invitation is None:
        raise HTTPException(status_code=404, detail="Invitation not found")
    crud.delete_invitation(db_session, current_user.id, requested_group.id)


@app.delete("/groups/{group_id}/invites/{user_id}", status_code=204)
def delete_invitation(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    requested_group: RequestedGroup,
):
    if requested_group.is_private == 0:
        raise HTTPException(
            status_code=400, detail="Can't delete invite from public group!"
        )

    invitation = crud.get_invitation(db_session, requested_user.id, requested_group.id)
    if invitation is None:
        raise HTTPException(status_code=404, detail="Invitation not found")

    validations.validate_current_is_inviter(current_user, invitation)
    crud.delete_invitation(db_session, requested_user.id, requested_group.id)


# ACTIVITIES
@app.post("/groups/{group_id}/activities", response_model=schemas.Activity)
def create_activity(
    current_user: DbUser,
    db_session: DbSession,
    activity: schemas.ActivityCreate,
    requested_group: RequestedGroup,
):
    validations.validate_user_in_group(current_user, current_user, requested_group)

    activity_payload = schemas.ActivityPayload(
        activity_name=activity.activity_name,
        scheduled_date=activity.scheduled_date,
        difficulty_code=activity.difficulty_code,
        group_id=requested_group.id,
        owner_id=current_user.id,
        challenges=activity.challenges,
        latitude=activity.latitude,
        longitude=activity.longitude,
        address=activity.address,
    )
    return crud.create_activity(db_session, activity_payload)


@app.get("/groups/{group_id}/activities", response_model=schemas.ActivityList)
def read_activities(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    skip: int = 0,
    limit: int = 100,
):
    validations.validate_user_in_group(current_user, current_user, requested_group)

    return schemas.ActivityList(
        data=crud.get_activities(db_session, requested_group.id, skip, limit)
    )


@app.get("/groups/{group_id}/activities/{activity_id}", response_model=schemas.Activity)
def read_activity(current_user: DbUser, requested_activity: RequestedActivity):
    validations.validate_user_in_group(
        current_user, current_user, requested_activity.group
    )

    return requested_activity


@app.patch(
    "/groups/{group_id}/activities/{activity_id}", response_model=schemas.Activity
)
def update_activity(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    requested_activity: RequestedActivity,
    activity_update: schemas.ActivityUpdate,
):
    validations.validate_owns_activity(current_user, requested_activity)
    validations.validate_activity_is_not_completed(current_user, requested_activity)
    db_activity = crud.update_activity(db_session, requested_activity, activity_update)

    if (
        db_activity.is_completed != 0
    ):  # special case, activity has been marked as complete
        crud.complete_activity(db_session, db_activity, requested_group)
    return db_activity


@app.delete("/groups/{group_id}/activities/{activity_id}", status_code=204)
def delete_activity(
    current_user: DbUser, db_session: DbSession, requested_activity: RequestedActivity
):
    validations.validate_owns_activity(current_user, requested_activity)
    crud.delete_activity(db_session, requested_activity)


# ACTIVITY PARTICIPATION
@app.put(
    "/group/{group_id}/activities/{activity_id}/participants/{user_id}", status_code=204
)
def join_activity(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    requested_activity: RequestedActivity,
    requested_user: RequestedUser,
):
    validations.validate_user_in_group(current_user, requested_user, requested_group)
    validations.validate_id(current_user, requested_user.id)

    if requested_user in requested_activity.participants:
        raise HTTPException(status_code=400, detail="User already in activity")

    crud.join_activity(db_session, requested_user, requested_activity)


@app.get(
    "/group/{group_id}/activities/{activity_id}/participants",
    response_model=schemas.UserList,
)
def read_participants(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    requested_activity: RequestedActivity,
    skip: int = 0,
    limit: int = 100,
):
    validations.validate_user_in_group(current_user, current_user, requested_group)

    return schemas.UserList(
        data=crud.get_participants(db_session, requested_activity, skip, limit)
    )


@app.get("/users/{user_id}/activities", response_model=schemas.ActivityList)
def read_user_activities(
    current_user: DbUser,
    db_session: DbSession,
    requested_user: RequestedUser,
    skip: int = 0,
    limit: int = 100,
):
    validations.validate_id(current_user, requested_user.id)
    return schemas.ActivityList(
        data=crud.get_user_activities(db_session, requested_user, skip, limit)
    )


@app.delete(
    "/groups/{group_id}/activities/{activity_id}/participants/{user_id}",
    status_code=204,
)
def leave_activity(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    requested_activity: RequestedActivity,
    requested_user: RequestedUser,
):
    validations.validate_id(current_user, requested_user.id)
    validations.validate_user_in_group(current_user, requested_user, requested_group)
    validations.validate_user_in_activity(
        current_user, requested_user, requested_activity
    )

    crud.leave_activity(db_session, requested_user, requested_activity)


@app.put(
    "/group/{group_id}/activities/{activity_id}/challenges/{challenge_id}",
    status_code=204,
)
def add_challenge_to_activity(
    current_user: DbUser,
    db_session: DbSession,
    requested_group: RequestedGroup,
    requested_activity: RequestedActivity,
    requesteded_challenge: RequestedChallenge,
):
    validations.validate_user_in_group(current_user, current_user, requested_group)
    validations.validate_owns_activity(current_user, requested_activity)
    crud.add_challenge_to_activity(
        db_session, requesteded_challenge, requested_activity
    )


# CHALLENGES
@app.post("/challenges", response_model=schemas.Challenge)
def create_challenge(
    current_user: DbUser,
    db_session: DbSession,
    challenge_payload: schemas.ChallengeCreate,
):
    validations.validate_is_admin(current_user)
    return crud.create_challenge(db_session, challenge_payload)


@app.get("/challenges", response_model=schemas.ChallengeList)
def read_challenges(
    current_user: DbUser, db_session: DbSession, skip: int = 0, limit: int = 100
):
    return schemas.ChallengeList(data=crud.get_challenges(db_session, skip, limit))


@app.get("/challenges/{challenge_id}", response_model=schemas.Challenge)
def read_challenge(
    current_user: DbUser, db_session: DbSession, requested_challenge: RequestedChallenge
):
    return requested_challenge


@app.patch("/challenges/{challenge_id}", response_model=schemas.Challenge)
def update_challenge(
    current_user: DbUser,
    db_session: DbSession,
    requested_challenge: RequestedChallenge,
    challenge_update: schemas.ChallengeUpdate,
):
    validations.validate_is_admin(current_user)
    return crud.update_challenge(db_session, requested_challenge, challenge_update)


@app.delete("/challenges/{challenge_id}", status_code=204)
def delete_challenge(
    current_user: DbUser, requested_challenge: RequestedChallenge, db_session: DbSession
):
    validations.validate_is_admin(current_user)
    crud.delete_challenge(db_session, requested_challenge)


# ACHIEVEMENTS
@app.get("/achievements", response_model=schemas.AchievementList)
def read_achievements(
    current_user: DbUser, db_session: DbSession, skip: int = 0, limit: int = 100
):
    achivements = schemas.AchievementList(
        data=crud.get_achievements(db_session, skip=skip, limit=limit)
    )
    return achivements


# achievement creation
@app.post("/achievements", response_model=schemas.Achievement)
def create_achievement(
    current_user: DbUser, db_session: DbSession, achievement: schemas.AchievementCreate
):
    validations.validate_is_admin(current_user)
    return crud.create_achievement(db_session=db_session, achievement=achievement)


@app.get("/achievements/{achievement_id}", response_model=schemas.Achievement)
def read_achievement(
    current_user: DbUser,
    db_session: DbSession,
    requested_achievement: RequestedAchievement,
):
    return requested_achievement


@app.patch("/achievements/{achievement_id}", response_model=schemas.Achievement)
def update_achievement(
    current_user: DbUser,
    db_session: DbSession,
    requested_achievement: RequestedAchievement,
    achievement_update: schemas.AchievementUpdate,
):
    validations.validate_is_admin(current_user)
    return crud.update_achievement(
        db_session, requested_achievement, achievement_update
    )


@app.delete("/achievements/{achievement_id}", status_code=204)
def delete_achievement(
    current_user: DbUser,
    requested_achievement: RequestedAchievement,
    db_session: DbSession,
):
    validations.validate_is_admin(current_user)
    crud.delete_achievement(db_session, requested_achievement)


# get completed achievements from user id
@app.get("/users/{user_id}/achievements", response_model=schemas.AchievementList)
def read_achivements_user_has(current_user: DbUser, requested_user: RequestedUser):
    achievements = schemas.AchievementList(data=requested_user.completed_achievements)
    return achievements
