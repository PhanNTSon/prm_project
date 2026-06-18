import base64
import requests
import json

mermaid_code = """graph TD
    lib["lib/"] --> core["core/ (Shared Core)"]
    lib --> features["features/ (Feature-First Modules)"]
    lib --> main["main.dart"]

    core --> network["network/ (Dio, Interceptors)"]
    core --> router["router/ (GoRouter, Guards)"]
    core --> widgets["widgets/ (Common UI Kit)"]
    core --> constants["constants/ (AppColors, API)"]

    features --> auth["auth/ (Dev A)"]
    features --> profile["profile/ (Dev A)"]
    features --> storefront["storefront/ (Dev B)"]
    features --> cart["cart/ (Dev C)"]
    features --> library["library/ (Dev D)"]

    style lib fill:#1b2838,stroke:#66c0f4,stroke-width:2px,color:#fff
    style core fill:#2a475e,stroke:#66c0f4,stroke-width:1px,color:#fff
    style features fill:#2a475e,stroke:#66c0f4,stroke-width:1px,color:#fff
    style main fill:#171a21,stroke:#c7d5e0,stroke-width:1px,color:#fff"""

# base64 encode the mermaid code
encoded = base64.b64encode(mermaid_code.encode('utf-8')).decode('utf-8')

# The mermaid.ink URL
url = f"https://mermaid.ink/img/{encoded}"

print(f"Fetching image from: {url}")
response = requests.get(url)

if response.status_code == 200:
    with open("reports/package_diagram.png", "wb") as f:
        f.write(response.content)
    print("Success! Image saved to reports/package_diagram.png")
else:
    print(f"Failed to fetch image. Status code: {response.status_code}")
