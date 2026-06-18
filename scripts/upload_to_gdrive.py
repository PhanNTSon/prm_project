import os
import json
import base64
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

def main():
    # Retrieve environment variables
    creds_raw = os.environ.get("GDRIVE_CREDENTIALS")
    file_id = os.environ.get("GDRIVE_FILE_ID")
    file_path = "reports/SAP341_Project_Report_Generated.docx"
    
    if not creds_raw:
        print("Error: GDRIVE_CREDENTIALS environment variable is not set.")
        return

    if not file_id:
        print("Error: GDRIVE_FILE_ID environment variable is not set. Vui lòng cung cấp File ID của file docx trống trên Drive của bạn để ghi đè.")
        return

    # Attempt to parse credentials
    try:
        try:
            decoded = base64.b64decode(creds_raw).decode('utf-8')
            creds_data = json.loads(decoded)
            print("Successfully decoded credentials from base64.")
        except Exception:
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

    media = MediaFileUpload(
        file_path,
        mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        resumable=True
    )

    try:
        print(f"Updating existing file with ID: {file_id}")
        file = drive_service.files().update(
            fileId=file_id,
            media_body=media,
            supportsAllDrives=True, # Dự phòng nếu file nằm trong Shared Drive
            fields="id, name, webViewLink"
        ).execute()
        
        print("Update Success!")
        print(f"File Name: {file.get('name')}")
        print(f"File ID: {file.get('id')}")
        print(f"Web View Link: {file.get('webViewLink')}")
    except Exception as e:
        print(f"Error uploading file: {e}")

if __name__ == "__main__":
    main()
