import os
import json
import base64
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

def main():
    # Retrieve environment variables
    creds_raw = os.environ.get("GDRIVE_CREDENTIALS")
    folder_id = os.environ.get("GDRIVE_FOLDER_ID")
    file_path = "reports/SAP341_Project_Report_Generated.docx"
    
    if not creds_raw:
        print("Error: GDRIVE_CREDENTIALS environment variable is not set.")
        return

    # Attempt to parse credentials (handling raw JSON or base64 encoded JSON)
    try:
        # Try decoding as base64 first
        try:
            decoded = base64.b64decode(creds_raw).decode('utf-8')
            creds_data = json.loads(decoded)
            print("Successfully decoded credentials from base64.")
        except Exception:
            # If fail, treat as raw JSON string
            creds_data = json.loads(creds_raw)
            print("Successfully parsed raw JSON credentials.")
    except Exception as e:
        print(f"Error parsing credentials JSON: {e}")
        return

    # Authenticate with Google Drive API
    try:
        creds = service_account.Credentials.from_service_account_info(
            creds_data,
            scopes=["https://www.googleapis.com/auth/drive"]
        )
        drive_service = build("drive", "v3", credentials=creds)
        print("Google Drive API client authenticated successfully.")
    except Exception as e:
        print(f"Error authenticating with Google Drive API: {e}")
        return

    # Define metadata for the upload
    file_metadata = {
        "name": "SAP341_Project_Report_Generated.docx",
        "mimeType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    }
    
    if folder_id:
        file_metadata["parents"] = [folder_id]
        print(f"Uploading file to Google Drive folder: {folder_id}")
    else:
        print("GDRIVE_FOLDER_ID is not set. Uploading to service account root drive.")

    # Upload file
    try:
        media = MediaFileUpload(
            file_path,
            mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            resumable=True
        )
        
        file = drive_service.files().create(
            body=file_metadata,
            media_body=media,
            fields="id, name, webViewLink"
        ).execute()
        
        print(f"Upload Success!")
        print(f"File Name: {file.get('name')}")
        print(f"File ID: {file.get('id')}")
        print(f"Web View Link: {file.get('webViewLink')}")
    except Exception as e:
        print(f"Error uploading file: {e}")

if __name__ == "__main__":
    main()
