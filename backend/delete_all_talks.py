import os
from sqlalchemy import create_engine
from app.models import Talk, TalkLike, Base
from app.database import SQLALCHEMY_DATABASE_URL
from sqlalchemy.orm import sessionmaker

def delete_all_talks():
    """Delete all talks and related data from the database"""
    try:
        print("Setting up database connection...")
        engine = create_engine(SQLALCHEMY_DATABASE_URL)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        session = SessionLocal()
        
        # Count existing data
        total_talks = session.query(Talk).count()
        total_likes = session.query(TalkLike).count()
        print(f"Found {total_talks} talks and {total_likes} likes in the database")
        
        if total_talks == 0:
            print("No talks to delete.")
            return
        
        # Confirm deletion
        confirm = input(f"Are you sure you want to delete ALL {total_talks} talks and {total_likes} likes? (yes/no): ")
        if confirm.lower() != 'yes':
            print("Deletion cancelled.")
            return
        
        # Delete in correct order: likes first, then talks
        print("Deleting all talk likes...")
        session.query(TalkLike).delete()
        
        print("Deleting all talks...")
        session.query(Talk).delete()
        
        session.commit()
        
        # Verify deletion
        remaining_talks = session.query(Talk).count()
        remaining_likes = session.query(TalkLike).count()
        print(f"Successfully deleted all data. Remaining talks: {remaining_talks}, likes: {remaining_likes}")
        
        session.close()
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        if 'session' in locals():
            session.rollback()
            session.close()

if __name__ == "__main__":
    delete_all_talks()
