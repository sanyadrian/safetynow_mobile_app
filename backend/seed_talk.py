from app.database import SessionLocal
from app import models

def seed():
    db = SessionLocal()
    talk = models.Talk(title="Fall Protection", category="Hazards", description="Talk about Fall Protection")
    db.add(talk)
    db.commit()
    db.refresh(talk)
    print(f"✅ Seeded talk: {talk.title} (id={talk.id})")
    db.close()

if __name__ == "__main__":
    seed()
