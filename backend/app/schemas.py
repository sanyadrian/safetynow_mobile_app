# app/schemas.py

from pydantic import BaseModel, EmailStr, constr
from typing import Optional

class UserCreate(BaseModel):
    username: constr(min_length=1)
    email: EmailStr
    phone: constr(min_length=1)
    password: constr(min_length=8)

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
    language: str

class TalkHistoryOut(BaseModel):
    id: int
    talk_title: str
    accessed_at: str
    language: str

    class Config:
        from_attributes = True


class TicketCreate(BaseModel):
    name: str
    email: str
    phone: str
    topic: str
    message: str

class TalkBase(BaseModel):
    title: str
    category: str
    description: Optional[str] = None
    hazard: Optional[str] = None
    industry: Optional[str] = None
    language: str
    related_title: str

class TalkCreate(TalkBase):
    pass

class TalkOut(TalkBase):
    id: int
    class Config:
        orm_mode = True

class PasswordResetRequest(BaseModel):
    email: EmailStr

class PasswordResetVerify(BaseModel):
    email: EmailStr
    code: str

class PasswordReset(BaseModel):
    email: EmailStr
    code: str
    new_password: constr(min_length=8)
