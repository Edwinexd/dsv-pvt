from typing import Optional
from sqlalchemy.orm import Session
import models, schemas


# USERS
def get_user(db_session: Session, user_id: str):
    return db_session.query(models.User).filter(models.User.id == user_id).first()


def get_users(db_session: Session, skip: int = 0, limit: int = 100):
    return db_session.query(models.User).offset(skip).limit(limit).all()


def create_user(db_session: Session, user: schemas.UserModel):
    db_user = models.User(
        id=user.id,
        email=user.email,
        username=user.username,
        full_name=user.full_name,
        role=user.role,
    )
    db_session.add(db_user)
    db_session.commit()
    db_session.refresh(db_user)
    return db_user


def update_user(
    db_session: Session, db_user: models.User, user_update: schemas.UserUpdate
):
    update_data = user_update.model_dump(exclude_unset=True)
    for k, v in update_data.items():
        setattr(db_user, k, v)
    db_session.commit()
    db_session.refresh(db_user)
    return db_user


def delete_user(db_session: Session, db_user: models.User):
    db_session.delete(db_user)
    db_session.commit()


# PROFILES
def get_profile(db_session: Session, user_id: str):
    user = get_user(db_session, user_id)
    if user is None:
        return None
    return user.profile


def create_profile(db_session: Session, profile: schemas.ProfileCreate, user_id: str):
    db_profile = models.Profile(
        description=profile.description,
        age=profile.age,
        interests=profile.interests,
        skill_level=profile.skill_level,
        is_private=int(profile.is_private),
        runner_id=profile.runner_id,
    )
    db_user = get_user(db_session, user_id)
    if db_user is None:
        return None
    if db_user.profile is not None:
        db_session.delete(db_user.profile)
    db_user.profile = db_profile
    db_session.add(db_user)
    db_session.commit()
    db_session.refresh(db_user)
    return db_profile


def update_profile(
    db_session: Session,
    db_profile: models.Profile,
    profile_update: schemas.ProfileUpdate,
):
    update_data = profile_update.model_dump(exclude_unset=True)

    if "is_private" in update_data:
        update_data["is_private"] = int(update_data["is_private"])

    for k, v in update_data.items():
        setattr(db_profile, k, v)
    db_session.commit()
    db_session.refresh(db_profile)
    return db_profile


def delete_profile(db_session: Session, db_profile: models.Profile):
    db_session.delete(db_profile)
    db_session.commit()


# GROUPS
def create_group(db_session: Session, group: schemas.GroupCreate):
    db_group = models.Group(
        group_name=group.group_name,
        description=group.description,
        is_private=int(group.is_private),
        latitude=group.latitude,
        longitude=group.longitude,
        address=group.address,
    )
    db_owner = get_user(db_session, group.owner_id)
    if db_owner is None:
        return None
    db_owner.owned_groups.append(db_group)
    db_owner.groups.append(db_group)
    db_session.add(db_owner)
    db_session.commit()
    db_session.refresh(db_owner)
    return db_group


# get a group from group_id
def get_group(db_session: Session, group_id: int):
    return db_session.query(models.Group).filter(models.Group.id == group_id).first()


def get_group_points(db_group: models.Group):
    points = 0
    for a in db_group.activities:
        if a.is_completed:
            for c in a.challenges:
                points += c.point_reward
    return points


# get a list of groups
def get_groups(db_session: Session, skip: int = 0, limit: int = 100):
    return db_session.query(models.Group).offset(skip).limit(limit).all()


def update_group(
    db_session: Session, db_group: models.Group, group_update: schemas.GroupUpdate
):
    update_data = group_update.model_dump(exclude_unset=True)

    if "is_private" in update_data:
        update_data["is_private"] = int(update_data["is_private"])

    for k, v in update_data.items():
        setattr(db_group, k, v)
    db_session.commit()
    db_session.refresh(db_group)
    return db_group


def delete_group(db_session: Session, db_group: models.Group):
    db_session.delete(db_group)
    db_session.commit()


# MEMBERSHIPS
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


# ACHIEVEMENTS
# create
def create_achievement(db_session: Session, achievement: schemas.AchievementCreate):
    db_achievement = models.Achievement(
        achievement_name=achievement.achievement_name,
        description=achievement.description,
        requirement=achievement.requirement,
    )
    db_session.add(db_achievement)
    db_session.commit()
    db_session.refresh(db_achievement)
    return db_achievement


# get achievement from id
def get_achievement(
    db_session: Session,
    *,
    achievement_id: Optional[int] = None,
    achievement_requirement: Optional[schemas.AchievementRequirement] = None
):
    if achievement_id is None and achievement_requirement is None:
        raise ValueError(
            "Either achievement_id or achievement_requirement must be provided"
        )
    return (
        db_session.query(models.Achievement)
        .filter(
            (models.Achievement.id == achievement_id)
            | (models.Achievement.requirement == achievement_requirement)
        )
        .first()
    )


# get list of achievements
def get_achievements(db_session: Session, skip: int = 0, limit: int = 100):
    return db_session.query(models.Achievement).offset(skip).limit(limit).all()


# update
def update_achievement(
    db_session: Session,
    db_achievement: models.Achievement,
    achievement_update: schemas.AchievementUpdate,
):
    update_data = achievement_update.model_dump(exclude_unset=True)
    for k, v in update_data.items():
        setattr(db_achievement, k, v)
    db_session.commit()
    db_session.refresh(db_achievement)
    return db_achievement


# delete
def delete_achievement(db_session: Session, db_achievement: models.Achievement):
    db_session.delete(db_achievement)
    db_session.commit()


# get all achievements a users completed
def get_all_achievements(db_session: Session, user_id: str):
    user = get_user(db_session, user_id)
    if user is None:
        return None
    return user.completed_achievements


def grant_achievement(
    db_session: Session, db_user: models.User, db_achievement: models.Achievement
):
    achievement_grant = models.AchievementCompletion(
        user_id=db_user.id, achievement_id=db_achievement.id
    )
    db_session.add(achievement_grant)
    db_session.commit()
    db_session.refresh(achievement_grant)
    return achievement_grant


# INVITATIONS
def invite_user(
    db_session: Session, db_user: models.User, db_group: models.Group, invited_by: str
):
    db_invitation = models.GroupInvitations(
        user_id=db_user.id, group_id=db_group.id, invited_by=invited_by
    )
    db_session.add(db_invitation)
    db_session.commit()
    db_session.refresh(db_invitation)
    return db_invitation


def get_invited_users(db_session: Session, db_group: models.Group):
    return db_group.invited_users


def get_groups_invited_to(db_session: Session, db_user: models.User):
    return db_user.groups_invited_to


def delete_invitation(db_session: Session, user_id: str, group_id: int):
    db_session.query(models.GroupInvitations).filter(
        models.GroupInvitations.user_id == user_id,
        models.GroupInvitations.group_id == group_id,
    ).delete()
    db_session.commit()


def get_invitation(db_session: Session, user_id: str, group_id: int):
    invitation = (
        db_session.query(models.GroupInvitations)
        .filter(
            models.GroupInvitations.user_id == user_id,
            models.GroupInvitations.group_id == group_id,
        )
        .first()
    )
    return invitation


# ACTIVITIES
def create_activity(db_session: Session, activity_payload: schemas.ActivityPayload):
    db_activity = models.Activity(
        activity_name=activity_payload.activity_name,
        scheduled_date=activity_payload.scheduled_date,
        difficulty_code=activity_payload.difficulty_code,
        owner_id=activity_payload.owner_id,
        group_id=activity_payload.group_id,
        latitude=activity_payload.latitude,
        longitude=activity_payload.longitude,
        address=activity_payload.address,
    )
    owner = get_user(db_session, activity_payload.owner_id)

    if owner is not None:
        owner.activities.append(db_activity)
    db_session.add(db_activity)

    if activity_payload.challenges is not None:
        for c in activity_payload.challenges:
            db_challenge = get_challenge(db_session, c.id)
            if db_challenge is None:
                continue
            db_activity.challenges.append(db_challenge)

    db_session.commit()
    db_session.refresh(db_activity)
    return db_activity


def get_activities(db_session: Session, group_id: int, skip: int, limit: int):
    return (
        db_session.query(models.Activity)
        .filter(models.Activity.group_id == group_id)
        .order_by(models.Activity.id.asc())
        .offset(skip)
        .limit(limit)
        .all()
    )


def get_activity(db_session: Session, group_id: int, activity_id: int):
    return (
        db_session.query(models.Activity)
        .filter(models.Activity.group_id == group_id, models.Activity.id == activity_id)
        .first()
    )


def update_activity(
    db_session: Session,
    db_activity: models.Activity,
    activity_update: schemas.ActivityUpdate,
):
    update_data = activity_update.model_dump(exclude_unset=True)

    if "is_completed" in update_data:
        update_data["is_completed"] = int(update_data["is_completed"])

    # special case, update includes challenge list
    if activity_update.challenges is not None:
        for c in activity_update.challenges:
            db_challenge = get_challenge(db_session, c.id)
            if db_challenge is None:
                continue
            db_activity.challenges.append(db_challenge)
        update_data.pop("challenges")

    for k, v in update_data.items():
        setattr(db_activity, k, v)
    db_session.commit()
    db_session.refresh(db_activity)
    return db_activity


def delete_activity(db_session: Session, db_activity: models.Activity):
    db_session.delete(db_activity)
    db_session.commit()


def complete_activity(
    db_session: Session, db_activity: models.Activity, db_group: models.Group
):
    achievements = []
    for c in db_activity.challenges:
        if c.achievement_match is not None:
            achievements.append(c.achievement_match)
    for u in db_activity.participants:  # each participant gets their achievement(s)
        for a in achievements:
            grant_achievement(db_session, u, a)
    db_session.commit()


# ACTIVITY PARTICIPATION
def join_activity(
    db_session: Session, db_user: models.User, db_activity: models.Activity
):
    db_activity.participants.append(db_user)
    db_session.add(db_activity)
    db_session.commit()
    db_session.refresh(db_activity)


def get_participants(
    db_session: Session, db_activity: models.Activity, skip: int, limit: int
):
    return db_activity.participants.offset(skip).limit(limit)


def get_user_activities(
    db_session: Session, db_user: models.User, skip: int, limit: int
):
    return db_user.activities.offset(skip).limit(limit)


def leave_activity(
    db_session: Session, db_user: models.User, db_activity: models.Activity
):
    db_activity.participants.remove(db_user)
    db_session.add(db_activity)
    db_session.commit()
    db_session.refresh(db_activity)


# CHALLENGES IN ACTIVITES
def add_challenge_to_activity(
    db_session: Session, db_challenge: models.Challenge, db_activity: models.Activity
):
    db_activity.challenges.append(db_challenge)
    db_session.add(db_activity)
    db_session.commit()
    db_session.refresh(db_activity)


# CHALLENGE
def create_challenge(db_session: Session, challenge_payload: schemas.ChallengeCreate):
    db_challenge = models.Challenge(
        challenge_name=challenge_payload.challenge_name,
        description=challenge_payload.description,
        difficulty_code=challenge_payload.difficulty_code,
        expiration_date=challenge_payload.expiration_date,
        point_reward=challenge_payload.point_reward,
        achievement_id=challenge_payload.achievement_id,
    )
    db_session.add(db_challenge)
    db_session.commit()
    db_session.refresh(db_challenge)
    return db_challenge


def get_challenges(db_session: Session, skip: int, limit: int):
    return db_session.query(models.Challenge).offset(skip).limit(limit).all()


def get_challenge(db_session: Session, challenge_id: int):
    return (
        db_session.query(models.Challenge)
        .filter(models.Challenge.id == challenge_id)
        .first()
    )


def update_challenge(
    db_session: Session,
    db_challenge: models.Challenge,
    challenge_update: schemas.ChallengeUpdate,
):
    update_data = challenge_update.model_dump(exclude_unset=True)

    for k, v in update_data.items():
        setattr(db_challenge, k, v)

    db_session.commit()
    db_session.refresh(db_challenge)
    return db_challenge


def delete_challenge(db_session: Session, db_challenge: models.Challenge):
    db_session.delete(db_challenge)
    db_session.commit()
