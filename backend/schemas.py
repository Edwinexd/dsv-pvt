# Schemas will be used for presentation and data query with user
from enum import Enum
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
    runner_id: Optional[str] = None
    location: str


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
    runner_id: Optional[str] = None
    location: Optional[str] = None


class ProfileImageUpdate(ProfileUpdate):
    image_id: Optional[str] = None


# GROUP
class GroupBase(BaseModel):
    group_name: str
    description: str
    is_private: bool
    owner_id: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    address: Optional[str] = None


class GroupCreate(GroupBase):
    # In case we wan't to have variables on for creation in the future
    pass


class Group(GroupBase):
    id: int
    points: int = 0
    image_id: Optional[str]

    class Config:
        from_attributes = True


class GroupList(BaseModel):
    data: List[Group]


class GroupUpdate(BaseModel):
    group_name: Optional[str] = None
    description: Optional[str] = None
    is_private: Optional[bool] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    address: Optional[str] = None


class GroupImageUpdate(GroupUpdate):
    image_id: Optional[str] = None


class GroupOrderType(str, Enum):
    NAME = "name"
    POINTS = "points"


# INVITES
class InviteBase(BaseModel):
    user_id: str
    group_id: int
    invited_by: str


class Invite(InviteBase):
    class Config:
        from_attributes = True


# CHALLENGE
class ChallengePartial(BaseModel):
    id: int


class ChallengeBase(ChallengePartial):
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
    image_id: Optional[str]

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
    challenges: List[Challenge]
    latitude: float
    longitude: float
    address: str


class ActivityCreate(ActivityBase):
    challenges: List[ChallengePartial]


class ActivityPayload(ActivityBase):
    group_id: int
    owner_id: str
    challenges: List[ChallengePartial]


class Activity(ActivityBase):
    id: int
    is_completed: bool
    group_id: int
    owner_id: str
    image_id: Optional[str]

    class Config:
        from_attributes = True


class ActivityList(BaseModel):
    data: List[Activity]


class ActivityUpdate(BaseModel):
    activity_name: Optional[str] = None
    scheduled_date: Optional[str] = None
    difficulty_code: Optional[int] = None
    is_completed: Optional[bool] = None
    challenges: Optional[List[ChallengePartial]] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    address: Optional[str] = None


class ActivityImageUpdate(ActivityUpdate):
    image_id: Optional[str] = None


# Sessions
class SessionUser(BaseModel):
    id: str


# ACHIEVEMENT
class AchievementBase(BaseModel):
    achievement_name: str
    requirement: "AchievementRequirement"
    description: str


class AchievementCreate(AchievementBase):
    pass


class Achievement(AchievementBase):
    id: int
    image_id: Optional[str]

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


# HEALTH
class HealthPayload(BaseModel):
    date: datetime
    steps: int
    max_heartrate: int
    water_liters: int
    headache_total: int
    sleep: int


class HealthData(BaseModel):
    data: List[HealthPayload]


class AchievementRequirement(Enum):
    CHALLENGE = 0
    STEPS_25K = 1
    STEPS_10K_7DAYS = 2
    HEARTRATE_200 = 3
    WATER_4L = 4
    WATER_3L_7DAYS = 5
    HEADACHE_16H = 6
    HEADACHE_0_7DAYS = 7
    SLEEP_10H = 8
    SLEEP_8H_7DAYS = 9


# oauth
class OauthLoginPayload(BaseModel):
    access_token: Optional[str]
    id_token: Optional[str]
