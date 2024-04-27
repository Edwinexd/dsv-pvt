from sqlalchemy.orm import Session
import models, schemas
from typing import List

#USERS
def get_user(db_session: Session, user_id: str):
    return db_session.query(models.User).filter(models.User.id == user_id).first()

def get_users(db_session: Session, skip: int = 0, limit: int = 100):
    return db_session.query(models.User).offset(skip).limit(limit).all()

def create_user(db_session: Session, user: schemas.User):
    db_user = models.User(id=user.id, username = user.username, full_name = user.full_name, date_created = user.date_created)
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
    if db_user.profile is not None:
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
def create_group(db_session: Session, group: schemas.GroupCreate, owner_id: str):
    db_group = models.Group(group_name = group.group_name, description = group.description, private = group.private)
    db_owner = get_user(db_session, owner_id)
    db_owner.owned_groups.append(db_group)
    db_owner.groups.append(db_group)
    db_session.add(db_owner)
    db_session.commit()
    db_session.refresh(db_owner)
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
def get_user_groups(db_session: Session, db_user: models.User):
    return db_user.groups

# get all users in a group
def get_group_users(db_session: Session, db_group: models.Group):
    return db_group.users

#INVITATIONS
def invite_user(db_session: Session, db_user: models.User, db_group: models.Group, invited_by: str):
    db_invitation = models.GroupInvitations(user_id=db_user.id, group_id=db_group.id, invited_by=invited_by)
    db_session.add(db_invitation)
    db_session.commit()
    db_session.refresh(db_invitation)
    return db_invitation

#super hacky but works, open to improvement suggestions
def get_invited_users(db_session: Session, group_id: int):
    inv_rows = db_session.query(models.GroupInvitations).filter(models.GroupInvitations.group_id == group_id).all()
    invited_users = []
    for g in inv_rows:
        invited_users.append(get_user(db_session, g.user_id))
    return invited_users

def get_groups_invited_to(db_session: Session, user_id: str):
    inv_rows = db_session.query(models.GroupInvitations).filter(models.GroupInvitations.user_id == user_id).all()
    groups_invited_to = []
    for g in inv_rows:
        groups_invited_to.append(get_group(db_session, g.group_id))
    return groups_invited_to

def delete_invitation(db_session: Session, user_id: str, group_id: int):
    db_session.query(models.GroupInvitations).filter(models.GroupInvitations.user_id == user_id, models.GroupInvitations.group_id == group_id).delete()
    db_session.commit()

def get_invitation(db_session: Session, user_id: str, group_id: int):
    invitation = db_session.query(models.GroupInvitations).filter(models.GroupInvitations.user_id == user_id, models.GroupInvitations.group_id == group_id).first()
    return invitation