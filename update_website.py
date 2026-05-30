import os

def update_website():
    # Update index.html
    html_file = "wellnex_website/index.html"
    if os.path.exists(html_file):
        with open(html_file, "r", encoding="utf-8") as f:
            html = f.read()
        html = html.replace("Wellnex", "Well Nex")
        with open(html_file, "w", encoding="utf-8") as f:
            f.write(html)
            
    # Update App.tsx
    app_tsx = "wellnex_website/src/App.tsx"
    if os.path.exists(app_tsx):
        with open(app_tsx, "r", encoding="utf-8") as f:
            lines = f.readlines()
        
        for i, line in enumerate(lines):
            # Skip line 36 (0-indexed) because it is the Header Logo
            # Skip line 268 (0-indexed) because it is the Footer Logo
            if i in [36, 268]:
                continue
            lines[i] = line.replace("Wellnex", "Well Nex")
            
        with open(app_tsx, "w", encoding="utf-8") as f:
            f.writelines(lines)
            
    print("Website updated.")

if __name__ == '__main__':
    update_website()
