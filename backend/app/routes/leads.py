from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import User
import os
import requests
import json
from typing import Dict, Any
import logging

router = APIRouter()

def get_nutshell_auth():
    email = os.getenv("NUTSHELL_EMAIL")
    api_key = os.getenv("NUTSHELL_API_KEY")
    if not email or not api_key:
        raise HTTPException(status_code=500, detail="Nutshell email or API key not configured")
    return (email, api_key)

def create_nutshell_lead(first_name: str, last_name: str, company: str, email: str, phone: str, plan: str):
    auth = get_nutshell_auth()
    import logging

    try:
        # 1. Create account
        account_data = {
            "accounts": [
                {
                    "name": company,
                    "emails": [{"value": email}],
                    "phones": [{"value": phone}]
                }
            ]
        }
        logging.warning(f"Account data being sent: {json.dumps(account_data)}")
        account_response = requests.post(
            "https://app.nutshell.com/rest/accounts",
            json=account_data,
            auth=auth
        )
        logging.warning(f"Nutshell response status: {account_response.status_code}")
        logging.warning(f"Nutshell response text: {account_response.text}")
        account_response.raise_for_status()
        account_result = account_response.json()
        account_id = account_result["accounts"][0]["id"]

        # 2. Create contact
        contact_data = {
            "contacts": [
                {
                    "name": f"{first_name} {last_name}",
                    "emails": [{"value": email}],
                    "phones": [{"value": phone}],
                    "links": {"accounts": [account_id]}
                }
            ]
        }
        contact_response = requests.post(
            "https://app.nutshell.com/rest/contacts",
            json=contact_data,
            auth=auth
        )
        contact_response.raise_for_status()
        contact_result = contact_response.json()
        contact_id = contact_result["contacts"][0]["id"]

        # 3. Create lead
        lead_data = {
            "leads": [
                {
                    "description": f"N-SafetyNowApp-{company}",
                    "links": {
                        "accounts": [account_id],
                        "contacts": [contact_id],
                        "tags": ["299-tags"],
                        "sources": ["25979-sources"]
                    }
                }
            ]
        }
        lead_response = requests.post(
            "https://app.nutshell.com/rest/leads",
            json=lead_data,
            auth=auth
        )
        lead_response.raise_for_status()
        lead_result = lead_response.json()
        lead_id = lead_result["leads"][0]["id"]

        # 4. Create note
        note_content = f"""
Source: SafetyNow App Upgrade
First Name: {first_name}
Last Name: {last_name}
Email: {email}
Phone: {phone}
Company: {company}
Selected Plan: {plan}
"""
        note_data = {
            "data": {
                "body": note_content,
                "links": {
                    "parent": lead_id
                }
            }
        }
        note_response = requests.post(
            "https://app.nutshell.com/rest/notes",
            json=note_data,
            auth=auth,
            headers={
                "Content-Type": "application/json",
                "Accept": "*/*"
            }
        )
        note_response.raise_for_status()
        return lead_id

    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Failed to communicate with Nutshell API: {str(e)}")
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"Invalid response from Nutshell API: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")

@router.post("/create-lead")
def create_lead(
    lead_data: Dict[str, Any] = Body(...),
    db: Session = Depends(get_db)
):
    try:
        # Extract and validate required fields
        first_name = lead_data.get("firstName")
        last_name = lead_data.get("lastName")
        company = lead_data.get("company")
        email = lead_data.get("email")
        phone = lead_data.get("phone")
        plan = lead_data.get("plan")
        
        # Validate required fields
        if not all([first_name, last_name, company, email, phone, plan]):
            missing_fields = []
            if not first_name: missing_fields.append("firstName")
            if not last_name: missing_fields.append("lastName")
            if not company: missing_fields.append("company")
            if not email: missing_fields.append("email")
            if not phone: missing_fields.append("phone")
            if not plan: missing_fields.append("plan")
            raise HTTPException(
                status_code=400,
                detail=f"Missing required fields: {', '.join(missing_fields)}"
            )
        
        # Create lead in Nutshell
        lead_id = create_nutshell_lead(
            first_name=first_name,
            last_name=last_name,
            company=company,
            email=email,
            phone=phone,
            plan=plan
        )
        
        return {"status": "success", "lead_id": lead_id}
        
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 