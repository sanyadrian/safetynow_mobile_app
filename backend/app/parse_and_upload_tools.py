import pandas as pd
from sqlalchemy.orm import Session
from app.database import SessionLocal, engine
from app.models import Base, Tool
import os

def parse_and_upload_tools():
    Base.metadata.create_all(bind=engine)
    
    excel_file = "Tools.xlsx" 
    if not os.path.exists(excel_file):
        print(f"Error: {excel_file} not found!")
        return
    
    df = pd.read_excel(excel_file)
    

    db = SessionLocal()
    
    try:
        for _, row in df.iterrows():
            tool = Tool(
                title=row['Title'],
                description=row['Description'],
                language=row['Language'],
                related_title=row['Related Title'],
                category="General", 
                hazard=None,
                industry=None 
            )
            
            db.add(tool)
        
        db.commit()
        print("Successfully uploaded all tools to the database!")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    parse_and_upload_tools() 