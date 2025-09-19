import os
from sqlalchemy import create_engine
from app.models import Talk, Base
from app.database import SQLALCHEMY_DATABASE_URL
from sqlalchemy.orm import sessionmaker

def delete_all_talks():
    """Delete all talks from the database"""
    try:
        print("Setting up database connection...")
        engine = create_engine(SQLALCHEMY_DATABASE_URL)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        session = SessionLocal()
        
        # Count existing talks
        total_talks = session.query(Talk).count()
        print(f"Found {total_talks} talks in the database")
        
        if total_talks == 0:
            print("No talks to delete.")
            return
        
        # Confirm deletion
        confirm = input(f"Are you sure you want to delete ALL {total_talks} talks? (yes/no): ")
        if confirm.lower() != 'yes':
            print("Deletion cancelled.")
            return
        
        # Delete all talks
        print("Deleting all talks...")
        session.query(Talk).delete()
        session.commit()
        
        # Verify deletion
        remaining_talks = session.query(Talk).count()
        print(f"Successfully deleted all talks. Remaining talks: {remaining_talks}")
        
        session.close()
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        if 'session' in locals():
            session.rollback()
            session.close()

if __name__ == "__main__":
    delete_all_talks()
