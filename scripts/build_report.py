import os
import re
import json
import base64
import requests
from io import open

# Google Drive imports
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload

def setup_gdrive_auth():
    creds_raw = os.environ.get("GDRIVE_CREDENTIALS")
    if not creds_raw:
        print("Warning: GDRIVE_CREDENTIALS not set. Skipping Drive sync.")
        return None
    try:
        try:
            decoded = base64.b64decode(creds_raw).decode('utf-8')
            creds_data = json.loads(decoded)
        except Exception:
            creds_data = json.loads(creds_raw)
        creds = service_account.Credentials.from_service_account_info(
            creds_data, scopes=["https://www.googleapis.com/auth/drive.readonly"]
        )
        return build("drive", "v3", credentials=creds)
    except Exception as e:
        print(f"Failed to auth Google Drive: {e}")
        return None

def download_gdrive_assets():
    folder_id = os.environ.get("GDRIVE_ASSETS_FOLDER_ID")
    if not folder_id:
        print("GDRIVE_ASSETS_FOLDER_ID not set. Skipping Google Drive assets download.")
        return
    
    drive_service = setup_gdrive_auth()
    if not drive_service:
        return

    os.makedirs("reports/assets", exist_ok=True)
    print(f"Scanning Google Drive Folder: {folder_id}")
    
    # Query for image files in the folder
    query = f"'{folder_id}' in parents and (mimeType contains 'image/')"
    try:
        results = drive_service.files().list(q=query, fields="files(id, name)").execute()
        files = results.get('files', [])
        
        if not files:
            print("No images found in the Drive folder.")
        else:
            for f in files:
                file_id = f['id']
                file_name = f['name']
                print(f"Downloading {file_name} from Drive...")
                request = drive_service.files().get_media(fileId=file_id)
                with open(f"reports/assets/{file_name}", "wb") as fh:
                    fh.write(request.execute())
    except Exception as e:
        print(f"Error fetching files from Google Drive: {e}")

def compile_mermaid_diagrams():
    if not os.path.exists("reports/diagrams.md"):
        print("reports/diagrams.md not found. Skipping mermaid compilation.")
        return

    os.makedirs("reports/assets", exist_ok=True)
    
    with open("reports/diagrams.md", "r", encoding="utf-8") as f:
        content = f.read()
        
    # Regex to find: ## diagram_id \n ```mermaid \n ... \n ```
    pattern = re.compile(r"##\s+(\w+)\s+```mermaid(.*?)```", re.DOTALL)
    matches = pattern.findall(content)
    
    for name, code in matches:
        code = code.strip()
        print(f"Compiling Mermaid diagram: {name}")
        encoded = base64.urlsafe_b64encode(code.encode('utf-8')).decode('utf-8')
        url = f"https://mermaid.ink/img/{encoded}"
        response = requests.get(url)
        if response.status_code == 200:
            with open(f"reports/assets/{name}.png", "wb") as f:
                f.write(response.content)
            print(f"Saved {name}.png")
        else:
            print(f"Failed to fetch diagram {name}: HTTP {response.status_code}")

def build_unified_report():
    print("Assembling Markdown files...")
    
    # 1. Base files
    files_to_merge = [
        "reports/flutter_app/01_Introduction.md",
        "reports/flutter_app/srs/srs_intro.md"
    ]
    
    # 2. Dynamic numbered SRS files
    srs_dir = "reports/flutter_app/srs/"
    if os.path.exists(srs_dir):
        dynamic_files = []
        for file in os.listdir(srs_dir):
            if re.match(r"^\d+.*\.md$", file):
                dynamic_files.append(file)
        # Sort them numerically/alphabetically
        dynamic_files.sort()
        for f in dynamic_files:
            files_to_merge.append(os.path.join(srs_dir, f))
    
    # 3. Suffix files
    files_to_merge.extend([
        "reports/flutter_app/srs/srs_non_functional.md",
        "reports/flutter_app/srs/srs_appendix.md",
        "reports/flutter_app/03_Software_Design_Description.md",
        "reports/flutter_app/04_Software_Testing_Documentation.md"
    ])
    
    unified_content = ""
    for fp in files_to_merge:
        if os.path.exists(fp):
            with open(fp, "r", encoding="utf-8") as f:
                unified_content += f.read() + "\n\n"
        else:
            print(f"Warning: File {fp} not found!")

    # 4. Inject Placeholders
    # {{DIAGRAM:id}} -> ![id](reports/assets/id.png)
    def replace_diagram(match):
        d_id = match.group(1)
        return f"![{d_id}](reports/assets/{d_id}.png)"
    
    unified_content = re.sub(r"\{\{DIAGRAM:([\w.-]+)\}\}", replace_diagram, unified_content)
    
    # {{IMAGE:name}} -> ![name](reports/assets/name.png) (Assuming user might omit .png in placeholder)
    def replace_image(match):
        img_id = match.group(1)
        # If user didn't specify extension, default to .png
        if not ("." in img_id):
            img_id += ".png"
        return f"![{img_id}](reports/assets/{img_id})"
        
    unified_content = re.sub(r"\{\{IMAGE:([\w.-]+)\}\}", replace_image, unified_content)
    
    # Save the final file
    with open("reports/unified_report.md", "w", encoding="utf-8") as f:
        f.write(unified_content)
    print("Built reports/unified_report.md successfully!")

def main():
    download_gdrive_assets()
    compile_mermaid_diagrams()
    build_unified_report()

if __name__ == "__main__":
    main()
