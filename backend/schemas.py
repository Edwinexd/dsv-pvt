# Schemas will be used for presentation and data query with user
from typing import List, Optional
from pydantic import BaseModel, Field, field_serializer
from datetime import datetime
from user_roles import Roles

EMAIL_REGEX = r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)"


# USER
class UserBase(BaseModel):
    email: str
    username: str
    full_name: str


class UserCreate(UserBase):
    email: str = Field(pattern=EMAIL_REGEX)
    password: str


class UserModel(UserBase):
    id: str
    role: Roles = Roles.NORMAL


class User(UserModel):
    date_created: datetime

    class Config:
        from_attributes = True

    # Incase we want the api to present the Role as the name instead of the value
    # @field_serializer("role")
    # def serialize_role(self, role: Roles, _info):
    #    return role.name


class UserList(BaseModel):
    data: List[User]


class UserUpdate(BaseModel):
    username: Optional[str] = None
    full_name: Optional[str] = None


class UserCreds(BaseModel):
    # Email is intentionally not validated due to compatability with old accounts
    email: str
    password: str


# PROFILE
class ProfileBase(BaseModel):
    description: Optional[str] = None
    age: Optional[int] = None
    interests: Optional[str] = None
    skill_level: int
    is_private: bool


class ProfileCreate(ProfileBase):
    pass


class Profile(ProfileBase):
    image_id: Optional[str]

    class Config:
        from_attributes = True


class ProfileUpdate(BaseModel):
    description: Optional[str] = None
    age: Optional[int] = None
    interests: Optional[str] = None
    skill_level: Optional[int] = None
    is_private: Optional[bool] = None


class ProfileImageUpdate(ProfileUpdate):
    image_id: Optional[str] = None


# GROUP
class GroupBase(BaseModel):
    group_name: str
    description: str
    is_private: bool
    owner_id: str


class GroupCreate(GroupBase):
    # In case we wan't to have variables on for creation in the future
    pass


class Group(GroupBase):
    id: int
    points: int = 0
    image_id: str | None

    class Config:
        from_attributes = True


class GroupList(BaseModel):
    data: List[Group]


class GroupUpdate(BaseModel):
    group_name: Optional[str] = None
    description: Optional[str] = None
    is_private: Optional[bool] = None


class GroupImageUpdate(GroupUpdate):
    image_id: Optional[str] = None


# INVITES
class InviteBase(BaseModel):
    user_id: str
    group_id: int
    invited_by: str


class Invite(InviteBase):
    class Config:
        from_attributes = True


# CHALLENGE
class ChallengeBase(BaseModel):
    challenge_name: str
    description: str
    difficulty_code: int
    expiration_date: Optional[datetime] = None
    point_reward: int
    achievement_id: Optional[int] = None


class ChallengeCreate(ChallengeBase):
    pass


class Challenge(ChallengeBase):
    id: int
    image_id: str | None

    class Config:
        from_attributes = True


class ChallengeUpdate(BaseModel):
    challenge_name: Optional[str] = None
    description: Optional[str] = None
    difficulty_code: Optional[int] = None
    expiration_date: Optional[datetime] = None
    point_reward: Optional[int] = None
    achievement_id: Optional[int] = None


class ChallengeImageUpdate(ChallengeUpdate):
    image_id: Optional[str] = None


class ChallengeList(BaseModel):
    data: List[Challenge]


# ACTIVITY
class ActivityBase(BaseModel):
    activity_name: str
    scheduled_date: datetime
    difficulty_code: int
    challenges: Optional[List[Challenge]] = None


class ActivityCreate(ActivityBase):
    pass


class ActivityPayload(ActivityBase):
    group_id: int
    owner_id: str
    challenges: Optional[List[Challenge]] = None


class Activity(ActivityBase):
    id: int
    is_completed: bool
    group_id: int
    owner_id: str
    image_id: str | None

    class Config:
        from_attributes = True


class ActivityList(BaseModel):
    data: List[Activity]


class ActivityUpdate(BaseModel):
    activity_name: Optional[str] = None
    scheduled_date: Optional[str] = None
    difficulty_code: Optional[int] = None
    is_completed: Optional[bool] = None
    challenges: Optional[List[Challenge]] = None


class ActivityImageUpdate(ActivityUpdate):
    image_id: Optional[str] = None


# Sessions
class SessionUser(BaseModel):
    id: str


# ACHIEVEMENT
class AchievementBase(BaseModel):
    achievement_name: str


class AchievementCreate(AchievementBase):
    description: str
    requirement: int


class Achievement(AchievementBase):
    id: int
    image_id: str | None

    class Config:
        from_attributes = True


class AchievementUpdate(BaseModel):
    achievement_name: Optional[str] = None
    description: Optional[str] = None
    requirement: Optional[int] = None


class AchievementImageUpdate(AchievementUpdate):
    image_id: Optional[str] = None


class AchievementList(BaseModel):
    data: List[Achievement]
