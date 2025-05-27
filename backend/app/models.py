# app/models.py

from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, func, Boolean
from sqlalchemy.orm import relationship
from app.database import Base
from sqlalchemy import DateTime
from datetime import datetime
from sqlalchemy import UniqueConstraint

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    phone = Column(String, nullable=True)
    hashed_password = Column(String)
    profile_image = Column(String, nullable=True)


class TalkHistory(Base):
    __tablename__ = "talk_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    talk_title = Column(String)
    accessed_at = Column(DateTime, default=datetime.utcnow)


class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    email = Column(String)
    phone = Column(String)
    topic = Column(String)
    message = Column(String)
    user_id = Column(Integer)


class Talk(Base):
    __tablename__ = "talks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    category = Column(String, nullable=False)
    description = Column(String, nullable=True)
    hazard = Column(String, nullable=True)
    industry = Column(String, nullable=True)
    language = Column(String, nullable=False, default="en")
    related_title = Column(String, nullable=False)
    
    # Relationship with likes
    likes = relationship("TalkLike", back_populates="talk")
    
    @property
    def like_count(self):
        return len(self.likes)


class TalkLike(Base):
    __tablename__ = "talk_likes"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    talk_id = Column(Integer, ForeignKey("talks.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    talk = relationship("Talk", back_populates="likes")
    user = relationship("User")
    
    __table_args__ = (
        UniqueConstraint('user_id', 'talk_id', name='unique_user_talk_like'),
    )


class PasswordReset(Base):
    __tablename__ = "password_resets"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, index=True)
    code = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime)
    is_used = Column(Boolean, default=False)
