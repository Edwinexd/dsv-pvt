from sqlalchemy import BigInteger, Boolean, Column, ForeignKey, Integer, String, Table
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
#association object pattern is used to get the extra field 'invited_by'
class GroupInvitations(base):
    __tablename__ = "group_invitations"

    user_id = Column(String, ForeignKey("users.id"), primary_key=True)
    group_id = Column(Integer, ForeignKey("groups.id"), primary_key=True)
    invited_by = Column(String)

    invited_user = relationship("User", back_populates="invited_to")
    group = relationship("Group", back_populates="invited_users")

# NORMAL TABLES
class User(base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)
    username = Column(String, unique=True)
    full_name = Column(String)
    date_created = Column(String)

    groups = relationship("Group", secondary=group_memberships, back_populates="users")
    invited_to = relationship("GroupInvitations", back_populates="invited_user")
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
    profile = relationship("Profile", uselist=False, back_populates="owner")
    owned_groups = relationship("Group", back_populates="owner")

class Profile(base):
    __tablename__ = "profiles"

    description = Column(String, nullable=True)
    age = Column(Integer, nullable=True)
    interests = Column(String, nullable=True)
    skill_level = Column(Integer) # will be mapped to a running pace in client
    is_private = Column(Boolean)

    owner_id = Column(String, ForeignKey("users.id"), primary_key=True)
    owner = relationship("User", back_populates="profile")

class Group(base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True)
    group_name = Column(String)
    description = Column(String, nullable=True)
    private = Column(Boolean)

    owner_id = Column(String, ForeignKey("users.id"))
    owner = relationship("User", back_populates="owned_groups")

    users = relationship("User", secondary=group_memberships, back_populates="groups")

    activities = relationship("Activity", back_populates="creator_group")

    invited_users = relationship("GroupInvitations", back_populates="group")

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
