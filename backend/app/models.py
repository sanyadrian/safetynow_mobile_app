# app/models.py

from sqlalchemy import Column, Integer, String
from app.database import Base
from sqlalchemy import DateTime
from datetime import datetime

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
