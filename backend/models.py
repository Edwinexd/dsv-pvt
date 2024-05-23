from sqlalchemy import (
    Column,
    Double,
    ForeignKey,
    Integer,
    String,
    Table,
    DateTime,
    Enum,
    select,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.sql.functions import coalesce
from sqlalchemy.ext.hybrid import hybrid_property

from schemas import AchievementRequirement
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
activity_challenges = Table(
    "activity_challenges",
    base.metadata,
    Column("challenge_id", ForeignKey("challenges.id"), primary_key=True),
    Column("activity_id", ForeignKey("activities.id"), primary_key=True),
)


# association object pattern is used to get the extra field 'invited_by'
class GroupInvitations(base):
    __tablename__ = "group_invitations"

    group_id = Column(Integer, ForeignKey("groups.id"), primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), primary_key=True)
    invited_by = Column(String, ForeignKey("users.id"))

    group = relationship("Group", viewonly=True, foreign_keys=[group_id])
    user = relationship("User", viewonly=True, foreign_keys=[user_id])
    inviter = relationship("User", viewonly=True, foreign_keys=[invited_by])


# association object pattern is used to get the extra field 'completed_date'
class AchievementCompletion(base):
    __tablename__ = "achievement_completions"

    user_id = Column(String, ForeignKey("users.id"), primary_key=True)
    achievement_id = Column(Integer, ForeignKey("achievements.id"), primary_key=True)
    # func.now() is improperly typed
    # pylint: disable=not-callable
    completed_date = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="completed_achievements")
    achievement = relationship("Achievement", back_populates="completed_by")


# NORMAL TABLES
class User(base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)
    email = Column(String, unique=True)
    username = Column(String, unique=True)
    full_name = Column(String)
    # func.now() is improperly typed
    # pylint: disable=not-callable
    date_created = Column(DateTime(timezone=True), server_default=func.now())
    role = Column(Enum(Roles), default=Roles.NORMAL)

    groups = relationship("Group", secondary=group_memberships, back_populates="users")

    groups_invited_to = relationship(
        "Group",
        secondary="group_invitations",
        back_populates="invited_users",
        primaryjoin="User.id == GroupInvitations.user_id",
        secondaryjoin="GroupInvitations.group_id == Group.id",
    )

    activities = relationship(
        "Activity",
        secondary=activity_participations,
        back_populates="participants",
        lazy="dynamic",
    )
    owned_activities = relationship("Activity", back_populates="owner")
    completed_challenges = relationship(
        "Challenge", secondary=challenge_completions, back_populates="completed_by"
    )
    completed_achievements = relationship(
        "AchievementCompletion", back_populates="user"
    )

    profile = relationship("Profile", uselist=False, back_populates="owner")
    owned_groups = relationship("Group", back_populates="owner")


class Profile(base):
    __tablename__ = "profiles"

    description = Column(String, nullable=True)
    age = Column(Integer, nullable=True)
    interests = Column(String, nullable=True)
    skill_level = Column(Integer)  # will be mapped to a running pace in client
    is_private = Column(Integer)  # 1-true, 0-false
    image_id = Column(String, nullable=True)
    runner_id = Column(String, nullable=True)
    location = Column(String, nullable=True, default="Stockholm")

    owner_id = Column(String, ForeignKey("users.id"), primary_key=True)
    owner = relationship("User", back_populates="profile")


class Group(base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True)
    group_name = Column(String)
    description = Column(String, nullable=True)
    is_private = Column(Integer)  # 1-true, 0-false
    image_id = Column(String, nullable=True)
    latitude = Column(Double, nullable=True)
    longitude = Column(Double, nullable=True)
    address = Column(String, nullable=True)
    skill_level = Column(Integer)

    owner_id = Column(String, ForeignKey("users.id"))
    owner = relationship("User", back_populates="owned_groups")

    users = relationship("User", secondary=group_memberships, back_populates="groups")

    activities = relationship("Activity", back_populates="group")

    invited_users = relationship(
        "User",
        secondary="group_invitations",
        back_populates="groups_invited_to",
        primaryjoin="Group.id == GroupInvitations.group_id",
        secondaryjoin="GroupInvitations.user_id == User.id",
    )

    @hybrid_property
    def points(self):
        return sum(
            c.point_reward
            for a in self.activities
            if a.is_completed
            for c in a.challenges
        )

    @points.inplace.expression
    @classmethod
    def _points_expression(cls):
        return (
            select(coalesce(func.sum(Challenge.point_reward), 0))
            .select_from(Activity)
            .join(activity_challenges, Activity.id == activity_challenges.c.activity_id)
            .join(Challenge, Challenge.id == activity_challenges.c.challenge_id)
            .where(Activity.group_id == cls.id)
            .where(Activity.is_completed == 1)
            .label("points")
        )


class Activity(base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True)
    activity_name = Column(String)
    scheduled_date = Column(DateTime(timezone=True))
    difficulty_code = Column(Integer)
    is_completed = Column(Integer, default=0)
    image_id = Column(String, nullable=True)
    latitude = Column(Double)
    longitude = Column(Double)
    address = Column(String)

    # user who created activity
    owner_id = Column(String, ForeignKey("users.id"))
    owner = relationship("User", uselist=False, back_populates="owned_activities")
    # the group where activity resides
    group_id = Column(Integer, ForeignKey("groups.id"))
    group = relationship("Group", uselist=False, back_populates="activities")

    participants = relationship(
        "User",
        secondary=activity_participations,
        back_populates="activities",
        lazy="dynamic",
    )
    challenges = relationship(
        "Challenge",
        secondary=activity_challenges,
        back_populates="activities",
        lazy="dynamic",
    )


class Challenge(base):
    __tablename__ = "challenges"

    id = Column(Integer, primary_key=True)
    challenge_name = Column(String)
    description = Column(String)
    difficulty_code = Column(Integer)
    expiration_date = Column(DateTime(timezone=True), nullable=True)
    point_reward = Column(Integer)
    image_id = Column(String, nullable=True)

    completed_by = relationship(
        "User", secondary=challenge_completions, back_populates="completed_challenges"
    )

    achievement_id = Column(Integer, ForeignKey("achievements.id"))
    achievement_match = relationship(
        "Achievement", uselist=False, back_populates="challenges"
    )

    activities = relationship(
        "Activity",
        secondary=activity_challenges,
        back_populates="challenges",
        lazy="dynamic",
    )


class Achievement(base):
    __tablename__ = "achievements"

    id = Column(Integer, primary_key=True)
    achievement_name = Column(String)
    description = Column(String)
    requirement = Column(
        Enum(AchievementRequirement), default=AchievementRequirement.CHALLENGE
    )
    image_id = Column(String, nullable=True)

    # Go to a challenge
    challenges = relationship("Challenge", back_populates="achievement_match")

    # Go to users - association table
    completed_by = relationship(
        "AchievementCompletion",
        back_populates="achievement",
    )
