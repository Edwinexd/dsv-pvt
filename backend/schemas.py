# Schemas will be used for presentation and data query with user
from typing import List, Union
from pydantic import BaseModel

# USER
class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    full_name: str

class User(UserBase):
    id: int
    date_created: str

    class Config:
        from_attributes = True

class UserList(BaseModel):
    data: List[User]

# GROUP
class GroupBase(BaseModel):
    group_name: str
    description: str

class GroupCreate(GroupBase):
    private: bool

class Group(GroupBase):
    id: int

    class Config:
        from_attributes = True

class GroupList(BaseModel):
    data: List[Group]

class GroupUpdate(BaseModel):
    group_name: Union[str, None] = None
    description: Union[str, None] = None
    private: Union[bool, None] = None

# ACTIVITY
class ActivityBase(BaseModel):
    activity_name: str

class ActivityCreate(ActivityBase):
    scheduled_date: str
    scheduled_time: str
    difficulty_code: int

class Activity(ActivityBase):
    id: int
    completed: bool

    class Config:
        from_attributes = True

class ActivityList(BaseModel):
    data: List[Activity]

# CHALLENGE
class ChallengeBase(BaseModel):
    challenge_name: str

class ChallengeCreate(ChallengeBase):
    description: str
    difficulty_code: int
    expiration_date: str | None = None
    point_reward: int

class Challenge(ChallengeBase):
    id: int

    class Config:
        from_attributes = True

class ChallengeList(BaseModel):
    data: List[Challenge]
