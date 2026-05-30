import sys
from PIL import Image

def process_logo(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    
    # Crop out the bottom-right watermark (DALL-E watermark is typically bottom right)
    # We can just crop the bottom 100 pixels and right 100 pixels off before processing, 
    # or crop it if the image is large enough.
    width, height = img.size
    
    # Crop out the bottom 100 pixels and right 100 pixels to be safe
    # Actually, let's just crop out the watermark area
    img = img.crop((0, 0, width - 80, height - 80))

    data = img.getdata()

    new_data = []
    # Tolerance for "white"
    threshold = 240
    for item in data:
        # if r, g, b are all high, it's a white/gray background
        if item[0] > threshold and item[1] > threshold and item[2] > threshold:
            new_data.append((255, 255, 255, 0)) # transparent
        else:
            new_data.append(item)

    img.putdata(new_data)
    
    # Crop to bounding box of the non-transparent logo
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        
    img.save(output_path, "PNG")
    print(f"Saved transparent logo to {output_path} (Watermark removed)")

process_logo(r"C:\Users\rahee\.gemini\antigravity\brain\d85234aa-c2cd-4b7b-971a-8e1228a64c2a\media__1780132086178.png", 
             r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Brand_Assets\W_Icon_Transparent.png")
