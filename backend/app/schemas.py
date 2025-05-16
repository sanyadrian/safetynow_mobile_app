# app/schemas.py

from pydantic import BaseModel
from typing import Optional

class UserCreate(BaseModel):
    username: str
    email: str
    phone: str
    password: str

class UserOut(BaseModel):
    id: int
    username: str
    email: str
    phone: str
    profile_image: Optional[str] = None

    class Config:
        orm_mode = True

class TalkHistoryCreate(BaseModel):
    talk_title: str

class TalkHistoryOut(BaseModel):
    talk_title: str
    accessed_at: str

    class Config:
        from_attributes = True


class TicketCreate(BaseModel):
    name: str
    email: str
    phone: str
    topic: str
    message: str
