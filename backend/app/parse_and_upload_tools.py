import pandas as pd
from sqlalchemy.orm import Session
from app.database import SessionLocal, engine
from app.models import Base, Tool
import os

def parse_and_upload_tools():
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)
    
    # Read the Excel file
    excel_file = "Tools.xlsx"  # Make sure this file is in the same directory
    if not os.path.exists(excel_file):
        print(f"Error: {excel_file} not found!")
        return
    
    df = pd.read_excel(excel_file)
    
    # Create a database session
    db = SessionLocal()
    
    try:
        # Process each row in the Excel file
        for _, row in df.iterrows():
            # Create a new Tool instance
            tool = Tool(
                title=row['Title'],
                description=row['Description'],
                language=row['Language'],
                related_title=row['Related Title'],
                category="General",  # Default category since it's not in the Excel
                hazard=None,  # Not in the Excel
                industry=None  # Not in the Excel
            )
            
            # Add to database
            db.add(tool)
        
        # Commit all changes
        db.commit()
        print("Successfully uploaded all tools to the database!")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    parse_and_upload_tools() 