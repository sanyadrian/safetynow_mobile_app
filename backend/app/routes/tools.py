from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models import Tool, ToolLike
from app.schemas import ToolCreate, ToolOut
from app.dependencies import get_current_user
from app.models import User

router = APIRouter(
    prefix="/tools",
    tags=["tools"]
)

@router.get("/", response_model=List[ToolOut])
def get_tools(
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None,
    language: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Tool)
    
    if category:
        query = query.filter(Tool.category == category)
    if language:
        query = query.filter(Tool.language == language)
        
    return query.offset(skip).limit(limit).all()

@router.get("/{tool_id}", response_model=ToolOut)
def get_tool(tool_id: int, db: Session = Depends(get_db)):
    tool = db.query(Tool).filter(Tool.id == tool_id).first()
    if tool is None:
        raise HTTPException(status_code=404, detail="Tool not found")
    return tool

@router.post("/{tool_id}/like")
def like_tool(
    tool_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    tool = db.query(Tool).filter(Tool.id == tool_id).first()
    if not tool:
        raise HTTPException(status_code=404, detail="Tool not found")
    
    existing_like = db.query(ToolLike).filter(
        ToolLike.user_id == current_user.id,
        ToolLike.tool_id == tool_id
    ).first()
    
    if existing_like:
        db.delete(existing_like)
        db.commit()
        return {"message": "Tool unliked"}
    
    new_like = ToolLike(user_id=current_user.id, tool_id=tool_id)
    db.add(new_like)
    db.commit()
    return {"message": "Tool liked"}

@router.get("/popular", response_model=List[ToolOut])
def get_popular_tools(
    limit: int = Query(5, ge=1, le=100),
    db: Session = Depends(get_db)
):
    tools = db.query(Tool).all()
    return sorted(tools, key=lambda x: x.like_count, reverse=True)[:limit]

@router.get("/{tool_id}/like-count")
def get_tool_like_count(tool_id: int, db: Session = Depends(get_db)):
    tool = db.query(Tool).filter(Tool.id == tool_id).first()
    if not tool:
        raise HTTPException(status_code=404, detail="Tool not found")
    return {"like_count": tool.like_count} 