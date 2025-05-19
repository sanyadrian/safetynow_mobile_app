import pandas as pd
from sqlalchemy import create_engine
from app.models import Talk, Base
from app.database import SQLALCHEMY_DATABASE_URL
from sqlalchemy.orm import sessionmaker

# Load the Excel file
file_path = 'Safety Talk App Selections.xlsx'
df = pd.read_excel(file_path)

# Set up the database connection
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
session = SessionLocal()

# Ensure the table exists
Base.metadata.create_all(bind=engine)

# Iterate through the rows and add talks
for _, row in df.iterrows():
    title = str(row.get('Title', '')).strip()
    category = str(row.get('Category', '')).strip()
    description = str(row.get('Description', '')).strip() if 'Description' in row else None
    hazard = category
    industry = str(row.get('Industry', '')).strip() if 'Industry' in row else None

    # Skip if title is empty
    if not title:
        continue

    # Check for duplicate by title
    existing = session.query(Talk).filter_by(title=title).first()
    if existing:
        continue

    talk = Talk(
        title=title,
        category=category,
        description=description,
        hazard=hazard,
        industry=industry
    )
    session.add(talk)

session.commit()
session.close()

print('Talks uploaded successfully!') 