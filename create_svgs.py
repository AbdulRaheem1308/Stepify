import base64
import os

img_path = r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Brand_Assets\W_Icon_Transparent.png"
if not os.path.exists(img_path):
    print("Error: Transparent logo not found.")
    exit(1)
    
with open(img_path, "rb") as f:
    b64 = base64.b64encode(f.read()).decode("utf-8")
image_uri = f"data:image/png;base64,{b64}"

out_dir = r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Brand_Assets"

# 1.1 Primary Horizontal Logo
svg_1 = f"""<svg width="600" height="160" viewBox="0 0 600 160" xmlns="http://www.w3.org/2000/svg">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;800&amp;display=swap');
    .logo-text {{ font-family: 'Inter', sans-serif; font-weight: 800; font-size: 58px; fill: #0B1D3A; letter-spacing: 2px; }}
    .tagline {{ font-family: 'Inter', sans-serif; font-weight: 500; font-size: 18px; fill: #10B981; letter-spacing: 0.5px; }}
  </style>
  <image href="{image_uri}" x="30" y="30" width="100" height="100" />
  <text x="160" y="90" class="logo-text">WELLNEX</text>
  <text x="165" y="125" class="tagline">Move Better. Live Better.</text>
</svg>"""

# 1.2 Vertical Logo
svg_2 = f"""<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;800&amp;display=swap');
    .logo-text {{ font-family: 'Inter', sans-serif; font-weight: 800; font-size: 58px; fill: #0B1D3A; letter-spacing: 2px; }}
    .tagline {{ font-family: 'Inter', sans-serif; font-weight: 500; font-size: 18px; fill: #10B981; letter-spacing: 0.5px; }}
  </style>
  <image href="{image_uri}" x="120" y="50" width="160" height="160" />
  <text x="200" y="270" class="logo-text" text-anchor="middle">WELLNEX</text>
  <text x="200" y="310" class="tagline" text-anchor="middle">Move Better. Live Better.</text>
</svg>"""

# 1.3 Icon Only Logo
svg_3 = f"""<svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <image href="{image_uri}" x="25" y="25" width="150" height="150" />
</svg>"""

# 1.4 Dark Logo
svg_4 = f"""<svg width="600" height="160" viewBox="0 0 600 160" xmlns="http://www.w3.org/2000/svg">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;800&amp;display=swap');
    .logo-text {{ font-family: 'Inter', sans-serif; font-weight: 800; font-size: 58px; fill: #FFFFFF; letter-spacing: 2px; }}
    .tagline {{ font-family: 'Inter', sans-serif; font-weight: 500; font-size: 18px; fill: #10B981; letter-spacing: 0.5px; }}
  </style>
  <rect width="100%" height="100%" fill="#0B1D3A" rx="12" />
  <image href="{image_uri}" x="30" y="30" width="100" height="100" />
  <text x="160" y="90" class="logo-text">WELLNEX</text>
  <text x="165" y="125" class="tagline">Move Better. Live Better.</text>
</svg>"""

# 1.5 Light Logo
svg_5 = f"""<svg width="600" height="160" viewBox="0 0 600 160" xmlns="http://www.w3.org/2000/svg">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;800&amp;display=swap');
    .logo-text {{ font-family: 'Inter', sans-serif; font-weight: 800; font-size: 58px; fill: #0B1D3A; letter-spacing: 2px; }}
    .tagline {{ font-family: 'Inter', sans-serif; font-weight: 500; font-size: 18px; fill: #10B981; letter-spacing: 0.5px; }}
  </style>
  <rect width="100%" height="100%" fill="#FFFFFF" rx="12" />
  <image href="{image_uri}" x="30" y="30" width="100" height="100" />
  <text x="160" y="90" class="logo-text">WELLNEX</text>
  <text x="165" y="125" class="tagline">Move Better. Live Better.</text>
</svg>"""

# 1.6 Monochrome Versions (Note: since the icon is raster and colored, true SVG monochrome isn't possible easily with CSS filters unless SVG supports it)
# We will use CSS filters to make the image grayscale/black/white for the monochrome versions!
svg_6_black = f"""<svg width="600" height="160" viewBox="0 0 600 160" xmlns="http://www.w3.org/2000/svg">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;800&amp;display=swap');
    .logo-text {{ font-family: 'Inter', sans-serif; font-weight: 800; font-size: 58px; fill: #000000; letter-spacing: 2px; }}
    .tagline {{ font-family: 'Inter', sans-serif; font-weight: 500; font-size: 18px; fill: #000000; letter-spacing: 0.5px; }}
  </style>
  <image href="{image_uri}" x="30" y="30" width="100" height="100" style="filter: grayscale(100%) brightness(0%);" />
  <text x="160" y="90" class="logo-text">WELLNEX</text>
  <text x="165" y="125" class="tagline">Move Better. Live Better.</text>
</svg>"""

svg_6_white = f"""<svg width="600" height="160" viewBox="0 0 600 160" xmlns="http://www.w3.org/2000/svg">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;800&amp;display=swap');
    .logo-text {{ font-family: 'Inter', sans-serif; font-weight: 800; font-size: 58px; fill: #FFFFFF; letter-spacing: 2px; }}
    .tagline {{ font-family: 'Inter', sans-serif; font-weight: 500; font-size: 18px; fill: #FFFFFF; letter-spacing: 0.5px; }}
  </style>
  <image href="{image_uri}" x="30" y="30" width="100" height="100" style="filter: grayscale(100%) brightness(200%);" />
  <text x="160" y="90" class="logo-text">WELLNEX</text>
  <text x="165" y="125" class="tagline">Move Better. Live Better.</text>
</svg>"""

# 1.7 Social Avatar
svg_7 = f"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#FFFFFF" />
  <image href="{image_uri}" x="162" y="162" width="700" height="700" />
</svg>"""

import os
with open(os.path.join(out_dir, "1.1_Primary_Horizontal_Logo.svg"), "w") as f: f.write(svg_1)
with open(os.path.join(out_dir, "1.2_Vertical_Logo.svg"), "w") as f: f.write(svg_2)
with open(os.path.join(out_dir, "1.3_Icon_Only_Logo.svg"), "w") as f: f.write(svg_3)
with open(os.path.join(out_dir, "1.4_Dark_Logo.svg"), "w") as f: f.write(svg_4)
with open(os.path.join(out_dir, "1.5_Light_Logo.svg"), "w") as f: f.write(svg_5)
with open(os.path.join(out_dir, "1.6_Monochrome_Black.svg"), "w") as f: f.write(svg_6_black)
with open(os.path.join(out_dir, "1.6_Monochrome_White.svg"), "w") as f: f.write(svg_6_white)
with open(os.path.join(out_dir, "1.7_Social_Avatar.svg"), "w") as f: f.write(svg_7)

print("Updated all SVGs to embed the official logo image.")
