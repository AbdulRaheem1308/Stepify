import sys
from PIL import Image, ImageDraw

def perfect_extract(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    
    # Create a circular mask or a smaller rectangular mask to completely avoid corner shadows
    # The logo should be well within the center 600x600 of the 1024x1024 image.
    
    data = img.getdata()
    new_data = []
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = data[y * width + x]
            
            # If the pixel is close to the edge (e.g., within 200 pixels of any edge), 
            # make it strictly transparent to avoid any corner shadows or watermarks.
            if x < 250 or x > width - 250 or y < 250 or y > height - 250:
                new_data.append((255, 255, 255, 0))
                continue
                
            # For the central area, remove white/gray background
            # The W logo is blue and green, so it has color. Shadows are gray.
            # White is > 200. Let's be aggressive.
            if r > 220 and g > 220 and b > 220:
                new_data.append((255, 255, 255, 0))
            else:
                new_data.append((r, g, b, a))
                
    img.putdata(new_data)
    
    # Crop to the actual bounding box
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        
    img.save(output_path, "PNG")
    print(f"Extracted perfect logo to {output_path}")

perfect_extract(r"C:\Users\rahee\.gemini\antigravity\brain\d85234aa-c2cd-4b7b-971a-8e1228a64c2a\media__1780132086178.png", 
                r"C:\Users\rahee\.gemini\antigravity\scratch\stepify\brand_kit\Brand_Assets\W_Icon_Transparent.png")
