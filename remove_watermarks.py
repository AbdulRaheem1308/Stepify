import os
from PIL import Image

def remove_watermark_and_resize(img_path):
    if not os.path.exists(img_path):
        return
        
    try:
        img = Image.open(img_path).convert("RGBA")
        orig_width, orig_height = img.size
        
        # Crop 80 pixels from the right and bottom to remove the watermark
        crop_amount = 80
        cropped = img.crop((0, 0, orig_width - crop_amount, orig_height - crop_amount))
        
        # Resize back to original dimensions
        resized = cropped.resize((orig_width, orig_height), Image.Resampling.LANCZOS)
        
        # Save back to the same path
        resized.save(img_path)
        print(f"Fixed watermark on: {os.path.basename(img_path)}")
    except Exception as e:
        print(f"Error processing {img_path}: {e}")

# List of generated raster files to fix
files_to_fix = [
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Product_Assets\2.5_Feature_Graphic.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Website_Assets\3.3_Hero_Illustration.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Website_Assets\3.4_OG_Banner.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Product_Assets\2.2_Splash_Screen.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Marketing_Assets\5.1_LinkedIn_Banner.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Marketing_Assets\5.2_Twitter_Banner.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Marketing_Assets\5.3_YouTube_Banner.png",
    
    # Also fix the copies in the actual codebase
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\wellnex_website\src\assets\hero.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\wellnex_website\public\og_banner.png",
    r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\wellnex_app\assets\images\splash_logo.png"
]

for f in files_to_fix:
    remove_watermark_and_resize(f)
