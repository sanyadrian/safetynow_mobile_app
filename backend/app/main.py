# app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth, talks, history, tickets

app = FastAPI()

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


@app.get("/")
def home():
    return {"message": "SafetyNow App Backend running!"}
