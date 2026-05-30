import os

def revert_well_nex(root_dir):
    extensions = {'.dart', '.tsx', '.ts', '.html', '.arb'}
    count = 0
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        # skip git and node_modules
        if '.git' in dirpath or 'node_modules' in dirpath or 'build' in dirpath or '.dart_tool' in dirpath:
            continue
            
        for filename in filenames:
            ext = os.path.splitext(filename)[1]
            if ext in extensions:
                file_path = os.path.join(dirpath, filename)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    if "Well Nex" in content:
                        new_content = content.replace("Well Nex", "Wellnex")
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        count += 1
                        print(f"Reverted in {file_path}")
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
                    
    print(f"Total files reverted: {count}")

if __name__ == '__main__':
    revert_well_nex('.')
