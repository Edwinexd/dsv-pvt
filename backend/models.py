from sqlalchemy import Column, ForeignKey, Integer, String, Table, DateTime, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from user_roles import Roles

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

    group_id = Column(Integer, ForeignKey("groups.id"), primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), primary_key=True)
    invited_by = Column(String, ForeignKey("users.id"))

    group = relationship("Group", 
                         #back_populates="user_invitation_associations", 
                         #back_populates="invited_users",
                         viewonly=True,
                         foreign_keys=[group_id])
    user = relationship("User", 
                        #back_populates="group_invitation_associations", 
                        #back_populates="groups_invited_to",
                        viewonly=True,
                        foreign_keys=[user_id])
    inviter = relationship("User", 
                           viewonly=True,
                           foreign_keys=[invited_by])

# NORMAL TABLES
class User(base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)
    username = Column(String, unique=True)
    full_name = Column(String)
    date_created = Column(DateTime(timezone=True), server_default=func.now())
    role = Column(Enum(Roles), default=Roles.NORMAL)

    groups = relationship("Group", secondary=group_memberships, back_populates="users")

    #group_invitation_associations = relationship("GroupInvitations", back_populates="user", foreign_keys='GroupInvitations.user_id')
    groups_invited_to = relationship("Group", secondary="group_invitations", back_populates="invited_users", primaryjoin="User.id == GroupInvitations.user_id", secondaryjoin="GroupInvitations.group_id == Group.id")

    activities = relationship(
        "Activity",
        secondary=activity_participations,
        back_populates="participants",
        lazy="dynamic"
    )
    owned_activities = relationship("Activity", back_populates = "owner")
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
    is_private = Column(Integer) # 1-true, 0-false

    owner_id = Column(String, ForeignKey("users.id"), primary_key=True)
    owner = relationship("User", back_populates="profile")

class Group(base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True)
    group_name = Column(String)
    description = Column(String, nullable=True)
    is_private = Column(Integer) # 1-true, 0-false

    owner_id = Column(String, ForeignKey("users.id"))
    owner = relationship("User", back_populates="owned_groups")

    users = relationship("User", secondary=group_memberships, back_populates="groups")

    activities = relationship("Activity", back_populates="group")

    #user_invitation_associations = relationship("GroupInvitations", back_populates="group", foreign_keys='GroupInvitations.group_id')
    invited_users = relationship("User", secondary="group_invitations", back_populates="groups_invited_to", primaryjoin="Group.id == GroupInvitations.group_id", secondaryjoin="GroupInvitations.user_id == User.id")

class Activity(base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True)
    activity_name = Column(String)
    scheduled_date = Column(DateTime(timezone=True))
    difficulty_code = Column(Integer)
    is_completed = Column(Integer, default=0)

    # user who created activity
    owner_id = Column(String, ForeignKey("users.id"))
    owner = relationship("User", uselist=False, back_populates="owned_activities")
    # the group where activity resides
    group_id = Column(Integer, ForeignKey("groups.id"))
    group = relationship("Group", uselist = False, back_populates="activities")

    participants = relationship(
        "User",
        secondary=activity_participations,
        back_populates="activities",
        lazy="dynamic"
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
