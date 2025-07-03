import pandas as pd
from sqlalchemy import create_engine
from app.models import Talk, Base
from app.database import SQLALCHEMY_DATABASE_URL
from sqlalchemy.orm import sessionmaker
import os

def upload_talks():
    try:
        # Get the absolute path to the Excel file
        current_dir = os.path.dirname(os.path.abspath(__file__))
        file_path = os.path.join(current_dir, 'SafetyTalkAPP.xlsx')
        
        if not os.path.exists(file_path):
            print(f"Error: Excel file not found at {file_path}")
            return

        # Load the Excel file
        print("Loading Excel file...")
        df = pd.read_excel(file_path)
        print(f"Loaded {len(df)} rows from Excel file")

        # Set up the database connection
        print("Setting up database connection...")
        engine = create_engine(SQLALCHEMY_DATABASE_URL)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        session = SessionLocal()

        # Ensure the table exists
        Base.metadata.create_all(bind=engine)

        # Counter for new talks
        new_talks = 0
        skipped_talks = 0

        # Iterate through the rows and add talks
        print("Processing talks...")
        for _, row in df.iterrows():
            title = str(row.get('Title', '')).strip()
            category = str(row.get('Category', '')).strip()
            description = str(row.get('Description', '')).strip() if 'Description' in row else None
            hazard = category
            industry = str(row.get('Industry', '')).strip() if 'Industry' in row else None
            language_raw = str(row.get('Language', '')).strip() if 'Language' in row else None
            language = language_raw.lower() if language_raw else None
            related_title = str(row.get('Related Title', '')).strip() if 'Related Title' in row else None

            # Skip if title, language, or related_title is empty
            if not title or not language or not related_title:
                skipped_talks += 1
                continue

            # Check for duplicate by title and language
            existing = session.query(Talk).filter_by(title=title, language=language).first()
            if existing:
                skipped_talks += 1
                continue

            talk = Talk(
                title=title,
                category=category,
                description=description,
                hazard=hazard,
                industry=industry,
                language=language,
                related_title=related_title
            )
            session.add(talk)
            new_talks += 1

        # Commit the changes
        print("Committing changes to database...")
        session.commit()
        session.close()

        print(f'Successfully uploaded {new_talks} new talks!')
        print(f'Skipped {skipped_talks} existing or invalid talks')

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        if 'session' in locals():
            session.rollback()
            session.close()

if __name__ == "__main__":
    upload_talks() 