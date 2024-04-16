from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Table
from sqlalchemy.orm import relationship
from sqlalchemy.schema import PrimaryKeyConstraint

from database import Base

# ASSOCIATION TABLES
group_memberships = Table(
    "group_memberships",
    Base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True),
    Column("group_id", ForeignKey("groups.id"), primary_key=True),
)
activity_participation = Table(
    "activity_participation",
    Base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True),
    Column("activity_id", ForeignKey("activities.id"), primary_key=True),
)
challenge_completion = Table(
    "challenge_completion",
    Base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True),
    Column("challenge_id", ForeignKey("challenges.id"), primary_key=True),
)

# NORMAL TABLES
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    full_name = Column(String)
    date_created = Column(String)

    groups = relationship("Group", secondary=group_memberships)
    activities = relationship("Activity", secondary=activity_participation)
    completed_challenges = relationship("Challenge", secondary=challenge_completion)

class Group(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True)
    group_name = Column(String)
    description = Column(String)

    users = relationship("User", secondary=group_memberships)

    activities = relationship("Activity", back_populates="creator_group")

class Activity(Base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True)
    activity_name = Column(String)
    scheduled_date = Column(String)
    scheduled_time = Column(String)
    completed = Column(Boolean)
    
    # user who created activity
    creator_id = Column(Integer, ForeignKey("users.id"))
    # the group where activity resides
    creator_group_id = Column(Integer, ForeignKey("groups.id"))

    creator_group = relationship("Group", back_populates="activities")

    participants = relationship("User", secondary=activity_participation)

class Challenge(Base):
    __tablename__ = "challenges"

    id = Column(Integer, primary_key=True)
    challenge_name = Column(String)
    description = Column(String)
    difficulty_code = Column(Integer)
    expiration_date = Column(String, nullable=True)
    point_reward = Column(Integer)

    completed_by = relationship("User", secondary=challenge_completion)
