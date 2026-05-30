from PIL import Image, ImageOps

def create_tight_app_icon():
    # Load the original transparent logo
    logo = Image.open('wellnex_app/assets/images/splash_logo.png').convert("RGBA")
    
    # Get the bounding box of the non-transparent pixels
    bbox = logo.getbbox()
    if bbox:
        # Crop to exactly the pixels of the 'W'
        logo = logo.crop(bbox)
    
    # We want to create a 1024x1024 app icon.
    icon_size = 1024
    
    # We want the logo to take up a significant portion of the icon, say 80% of the space
    target_logo_size = int(icon_size * 0.75)
    
    # Calculate aspect ratio
    aspect = logo.width / logo.height
    
    if aspect > 1:
        new_w = target_logo_size
        new_h = int(target_logo_size / aspect)
    else:
        new_h = target_logo_size
        new_w = int(target_logo_size * aspect)
        
    logo = logo.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Create the background
    # The user asked for a "bright" icon. Let's make it a bright solid white to make the colored W pop,
    # or a nice light gradient. We'll stick to bright white (#FFFFFF) but since the logo is large,
    # it won't feel "empty".
    bg = Image.new("RGBA", (icon_size, icon_size), (255, 255, 255, 255))
    
    # Center the logo on the background
    paste_x = (icon_size - new_w) // 2
    paste_y = (icon_size - new_h) // 2
    
    # Paste using the logo itself as the alpha mask
    bg.paste(logo, (paste_x, paste_y), logo)
    
    # Save the new app icon
    output_path = 'wellnex_app/assets/images/app_icon.png'
    bg.save(output_path, "PNG")
    print(f"Successfully generated new bright app icon at {output_path} with tight padding.")

if __name__ == '__main__':
    create_tight_app_icon()
