import os
import sys

def rename_content(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        return # Skip binary files
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return

    new_content = content.replace("Stepify", "Wellnex").replace("stepify", "wellnex").replace("STEPIFY", "WELLNEX")
    
    if new_content != content:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated content in {file_path}")
        except Exception as e:
            print(f"Error writing {file_path}: {e}")

def main():
    root_dir = os.path.dirname(os.path.abspath(__file__))
    
    ignore_dirs = {'.git', '.github', '.vscode', 'node_modules', 'build', 'dist', 
                   '.dart_tool', '.idea', 'coverage', 'windows', 'linux', 'macos', 
                   'android/.gradle', 'ios/Pods', '__pycache__'}

    # 1. Content Replacement
    for root, dirs, files in os.walk(root_dir):
        # Exclude ignored directories
        dirs[:] = [d for d in dirs if not any(ignore in os.path.join(root, d).replace(root_dir, '').replace('\\', '/') for ignore in ignore_dirs) and d not in ignore_dirs]
        
        for file in files:
            if file == 'rename_script.py':
                continue
            
            file_path = os.path.join(root, file)
            rename_content(file_path)

    # 2. File Renaming (Bottom-Up to avoid path invalidation)
    for root, dirs, files in os.walk(root_dir, topdown=False):
        dirs[:] = [d for d in dirs if not any(ignore in os.path.join(root, d).replace(root_dir, '').replace('\\', '/') for ignore in ignore_dirs) and d not in ignore_dirs]
        
        for file in files:
            if 'stepify' in file.lower() and file != 'rename_script.py':
                old_path = os.path.join(root, file)
                # Keep case matching logic if needed, but usually files are lowercase e.g. stepify_app.iml -> wellnex_app.iml
                new_file = file.replace('stepify', 'wellnex').replace('Stepify', 'Wellnex')
                new_path = os.path.join(root, new_file)
                try:
                    os.rename(old_path, new_path)
                    print(f"Renamed file {file} -> {new_file}")
                except Exception as e:
                    print(f"Error renaming {old_path}: {e}")

if __name__ == "__main__":
    main()
