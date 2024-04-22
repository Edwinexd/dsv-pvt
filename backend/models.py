from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Table
from sqlalchemy.orm import relationship

from database import base

# ASSOCIATION TABLES
group_memberships = Table(
    "group_memberships",
    base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True),
    Column("group_id", ForeignKey("groups.id"), primary_key=True),
)
activity_participations = Table(
    "activity_participations",
    base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True),
    Column("activity_id", ForeignKey("activities.id"), primary_key=True),
)
challenge_completions = Table(
    "challenge_completions",
    base.metadata,
    Column("user_id", ForeignKey("users.id"), primary_key=True),
    Column("challenge_id", ForeignKey("challenges.id"), primary_key=True),
)

# NORMAL TABLES
class User(base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    full_name = Column(String)
    date_created = Column(String)

    groups = relationship("Group", secondary=group_memberships, back_populates="users")
    activities = relationship(
        "Activity",
        secondary=activity_participations,
        back_populates="participants"
    )
    completed_challenges = relationship(
        "Challenge",
        secondary=challenge_completions,
        back_populates="completed_by"
    )

class Group(base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True)
    group_name = Column(String)
    description = Column(String)
    private = Column(Boolean)

    users = relationship("User", secondary=group_memberships, back_populates="groups")

    activities = relationship("Activity", back_populates="creator_group")

class Activity(base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True)
    activity_name = Column(String)
    scheduled_date = Column(String)
    scheduled_time = Column(String)
    completed = Column(Boolean)
    difficulty_code = Column(Integer)

    # user who created activity
    creator_id = Column(Integer, ForeignKey("users.id"))
    # the group where activity resides
    creator_group_id = Column(Integer, ForeignKey("groups.id"))

    creator_group = relationship("Group", back_populates="activities")

    participants = relationship(
        "User",
        secondary=activity_participations,
        back_populates="activities"
    )

class Challenge(base):
    __tablename__ = "challenges"

    id = Column(Integer, primary_key=True)
    challenge_name = Column(String)
    description = Column(String)
    difficulty_code = Column(Integer)
    expiration_date = Column(String, nullable=True)
    point_reward = Column(Integer)

    completed_by = relationship(
        "User",
        secondary=challenge_completions,
        back_populates="completed_challenges"
    )