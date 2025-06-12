# app/schemas.py

from pydantic import BaseModel, EmailStr, constr
from typing import Optional

class UserCreate(BaseModel):
    username: constr(min_length=1)
    email: EmailStr
    phone: Optional[str] = None
    password: constr(min_length=8)

class UserOut(BaseModel):
    id: int
    username: str
    email: str
    phone: Optional[str] = None
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

class ToolBase(BaseModel):
    title: str
    category: str
    description: Optional[str] = None
    hazard: Optional[str] = None
    industry: Optional[str] = None
    language: str
    related_title: str

class ToolCreate(ToolBase):
    pass

class ToolOut(ToolBase):
    id: int
    class Config:
        from_attributes = True

class PasswordResetRequest(BaseModel):
    email: EmailStr

class PasswordResetVerify(BaseModel):
    email: EmailStr
    code: str

class PasswordReset(BaseModel):
    email: EmailStr
    code: str
    new_password: constr(min_length=8)
