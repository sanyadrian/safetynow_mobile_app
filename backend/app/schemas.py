# app/schemas.py

from pydantic import BaseModel

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
    message: str
