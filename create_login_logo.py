import base64
import os

img_path = r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Brand_Assets\W_Icon_Transparent.png"
if not os.path.exists(img_path):
    print("Error: Transparent logo not found.")
    exit(1)
    
with open(img_path, "rb") as f:
    b64 = base64.b64encode(f.read()).decode("utf-8")
image_uri = f"data:image/png;base64,{b64}"

out_dir = r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Product_Assets"

# 2.3 Login Logo - Compact (Icon + Text, no tagline)
svg_login = f"""<svg width="400" height="120" viewBox="0 0 400 120" xmlns="http://www.w3.org/2000/svg">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;800&amp;display=swap');
    .logo-text {{ font-family: 'Inter', sans-serif; font-weight: 800; font-size: 52px; fill: #0B1D3A; letter-spacing: 2px; }}
  </style>
  <image href="{image_uri}" x="10" y="20" width="80" height="80" />
  <text x="110" y="80" class="logo-text">WELLNEX</text>
</svg>"""

with open(os.path.join(out_dir, "2.3_Login_Logo.svg"), "w") as f:
    f.write(svg_login)

print("Created 2.3_Login_Logo.svg")
