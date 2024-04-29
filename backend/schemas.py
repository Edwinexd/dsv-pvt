# Schemas will be used for presentation and data query with user
from typing import List, Optional
from pydantic import BaseModel

# USER
class UserBase(BaseModel):
    username: str
    full_name: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: str
    date_created: str

    class Config:
        from_attributes = True

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
    is_private: int

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
    is_private: Optional[int] = None

# GROUP
class GroupBase(BaseModel):
    group_name: str
    description: str
    is_private: int
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
    is_private: Optional[int] = None

# INVITES
class InviteBase(BaseModel):
    user_id: str
    group_id: int
    invited_by: str

class Invite(InviteBase):
    class Config:
        from_attributes = True

# ACTIVITY
class ActivityBase(BaseModel):
    activity_name: str
    scheduled_date: str #ISO-check!
    difficulty_code: int

class ActivityCreate(ActivityBase):
    pass

class ActivityPayload(ActivityBase):
    group_id: int
    owner_id: str

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

# CHALLENGE
class ChallengeBase(BaseModel):
    challenge_name: str

class ChallengeCreate(ChallengeBase):
    description: str
    difficulty_code: int
    expiration_date: Optional[str] = None
    point_reward: int

class Challenge(ChallengeBase):
    id: int

    class Config:
        from_attributes = True

class ChallengeList(BaseModel):
    data: List[Challenge]

# Sessions
class SessionUser(BaseModel):
    id: str
