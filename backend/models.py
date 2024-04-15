from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Table
from sqlalchemy.orm import relationship
from sqlalchemy.schema import PrimaryKeyConstraint

from database import Base

group_memberships = Table(
    "group_memberships",
    Base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True),
    Column("group_id", ForeignKey("groups.id"), primary_key=True),
)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    full_name = Column(String)
    date_created = Column(String)

    groups = relationship("Group", secondary=group_memberships)

class Group(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True)
    group_name = Column(String)
    description = Column(String)

    users = relationship("User", secondary=group_memberships)
