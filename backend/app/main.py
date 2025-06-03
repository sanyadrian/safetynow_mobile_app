# app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.routes import auth, talks, history, tickets, profile, leads, tools
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

app = FastAPI()
app.mount("/static", StaticFiles(directory="app/static"), name="static")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register the auth router
app.include_router(auth.router)
app.include_router(talks.router)
app.include_router(history.router)
app.include_router(tickets.router)
app.include_router(profile.router)
app.include_router(leads.router, prefix="/api", tags=["leads"])
app.include_router(tools.router)


@app.get("/")
def home():
    return {"message": "SafetyNow App Backend running!"}
