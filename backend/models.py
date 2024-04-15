from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    full_name = Column(String)
    date_created = Column(String)

class Group(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True)
    group_name = Column(String)
    description = Column(String)

#class GroupMembership(Base)
#    __tablename__ = "group_membership"
#
#    user_id = Column(Integer, primary_key=True, ForeignKey("users.id"))
#    group_id = Column(Integer, primary_key=True, ForeignKey("groups.id"))
