import json
import os

l10n_dir = 'c:/Users/rahee/.gemini/antigravity/scratch/stepify/stepify_app/lib/l10n'
base_file = os.path.join(l10n_dir, 'app_en.arb')

with open(base_file, 'r', encoding='utf-8') as f:
    base_data = json.load(f)

# Extract only the actual message keys (ignore metadata starting with @)
keys = [k for k in base_data.keys() if not k.startswith('@')]

target_files = ['app_en_GB.arb', 'app_en_IN.arb', 'app_hi.arb']

for target in target_files:
    target_path = os.path.join(l10n_dir, target)
    if os.path.exists(target_path):
        with open(target_path, 'r', encoding='utf-8') as f:
            target_data = json.load(f)
        
        added = 0
        for k in keys:
            if k not in target_data:
                # If it's English, just copy the English text
                if target.startswith('app_en'):
                    target_data[k] = base_data[k]
                else:
                    # For Hindi, we can add a fallback with a prefix, or just use English text
                    target_data[k] = base_data[k]
                added += 1
                
        if added > 0:
            with open(target_path, 'w', encoding='utf-8') as f:
                json.dump(target_data, f, ensure_ascii=False, indent=2)
            print(f"Added {added} missing keys to {target}")
    else:
        print(f"File {target} not found!")

print("Sync complete.")
