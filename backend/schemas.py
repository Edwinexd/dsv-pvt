# Schemas will be used for presentation and data query with user
from typing import List, Optional
from pydantic import BaseModel, field_serializer
from datetime import datetime
from user_roles import Roles

# USER
class UserBase(BaseModel):
    username: str
    full_name: str

class UserCreate(UserBase):
    password: str

class UserModel(UserBase):
    id: str
    role: Roles = Roles.NORMAL

class User(UserModel):
    date_created: datetime

    class Config:
        from_attributes = True

    # Incase we want the api to present the Role as the name instead of the value
    @field_serializer("role")
    def serialize_role(self, role: Roles, _info):
        return role.name

class UserList(BaseModel):
    data: List[User]

class UserUpdate(BaseModel):
    username: Optional[str] = None
    full_name: Optional[str] = None
      
class UserCreds(BaseModel):
    username: str
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
    class Config:
        from_attributes = True

class ProfileUpdate(BaseModel):
    description: Optional[str] = None
    age: Optional[int] = None
    interests: Optional[str] = None
    skill_level: Optional[int] = None
    is_private: Optional[bool] = None

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

    class Config:
        from_attributes = True

class GroupList(BaseModel):
    data: List[Group]

class GroupUpdate(BaseModel):
    group_name: Optional[str] = None
    description: Optional[str] = None
    is_private: Optional[bool] = None

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

    class Config:
        from_attributes = True

class ChallengeUpdate(BaseModel):
    challenge_name: Optional[str] = None
    description: Optional[str] = None
    difficulty_code: Optional[int] = None
    expiration_date: Optional[datetime] = None
    point_reward: Optional[int] = None
    achievement_id: Optional[int] = None

class ChallengeList(BaseModel):
    data: List[Challenge]

# ACTIVITY
class ActivityBase(BaseModel):
    activity_name: str
    scheduled_date: datetime
    difficulty_code: int
#TODO: how should challenge list be displayed?
class ActivityCreate(ActivityBase):
    challenge_list: Optional[List[int]] = None

class ActivityPayload(ActivityBase):
    group_id: int
    owner_id: str
    challenge_list: Optional[List[int]] = None

class Activity(ActivityBase):
    id: int
    is_completed: bool
    group_id: int
    owner_id: str

    class Config:
        from_attributes = True

class ActivityList(BaseModel):
    data: List[Activity]

class ActivityUpdate(BaseModel):
    activity_name: Optional[str] = None
    scheduled_date: Optional[str] = None
    difficulty_code: Optional[int] = None
    is_completed: Optional[bool] = None
    challenge_list: Optional[List[int]] = None

# Sessions
class SessionUser(BaseModel):
    id: str

#ACHIEVEMENT
class AchievementBase(BaseModel):
    achievement_name:str

class AchievementCreate(AchievementBase):
    description: str
    requirement: int

class Achievement(AchievementBase):
    id: int

    class Config:
        from_attributes = True

class AchievementUpdate(BaseModel):
    achievement_name: Optional[str] = None
    description: Optional[str] = None
    requirement: Optional[int] = None

class AchievementList(BaseModel):
    data: List[Achievement]