from pydantic import BaseModel

class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    full_name: str

class User(UserBase):
    id: int
    date_created: str

    class Config:
        orm_mode = True

class GroupBase(BaseModel):
    group_name: str
    description: str

class GroupCreate(GroupBase):
    pass

class Group(GroupBase):
    id: int

    class Config:
        orm_mode = True

class GroupMembershipBase(BaseModel):
    user_id: int
    group_id: int

class GroupMembershipCreate(GroupMembershipBase):
    pass

class GroupMembership(GroupMembershipBase):
    class Config:
        orm_mode = True
