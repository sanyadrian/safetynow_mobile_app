import os
from sqlalchemy import create_engine
from app.models import Talk, TalkHistory, TalkLike
from app.database import SQLALCHEMY_DATABASE_URL
from sqlalchemy.orm import sessionmaker

def clean_history():
    """Clean up orphaned history entries and other data"""
    try:
        print("Setting up database connection...")
        engine = create_engine(SQLALCHEMY_DATABASE_URL)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        session = SessionLocal()
        
        # Count existing data
        total_history = session.query(TalkHistory).count()
        total_talks = session.query(Talk).count()
        total_likes = session.query(TalkLike).count()
        
        print(f"Current state:")
        print(f"- Talks: {total_talks}")
        print(f"- History entries: {total_history}")
        print(f"- Likes: {total_likes}")
        
        if total_history == 0:
            print("No history entries to clean.")
            return
        
        # Confirm cleanup
        confirm = input(f"Clean up {total_history} history entries? (yes/no): ")
        if confirm.lower() != 'yes':
            print("Cleanup cancelled.")
            return
        
        # Delete all history entries
        print("Cleaning up history...")
        session.query(TalkHistory).delete()
        
        # Also clean up any remaining likes (just in case)
        if total_likes > 0:
            print("Cleaning up remaining likes...")
            session.query(TalkLike).delete()
        
        session.commit()
        
        # Verify cleanup
        remaining_history = session.query(TalkHistory).count()
        remaining_talks = session.query(Talk).count()
        remaining_likes = session.query(TalkLike).count()
        
        print(f"Cleanup complete:")
        print(f"- Talks: {remaining_talks}")
        print(f"- History entries: {remaining_history}")
        print(f"- Likes: {remaining_likes}")
        
        session.close()
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        if 'session' in locals():
            session.rollback()
            session.close()

if __name__ == "__main__":
    clean_history()
