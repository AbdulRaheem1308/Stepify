import os

target_files = [
    "wellnex_backend/prisma/seed-notifications.ts",
    "wellnex_backend/src/auth/otp.service.spec.ts",
    "wellnex_backend/src/auth/otp.service.ts",
    "wellnex_backend/src/notifications/notifications.service.ts",
    "wellnex_backend/src/rewards/rewards.service.ts"
]

for file_path in target_files:
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace "Wellnex" with "Well Nex"
        new_content = content.replace("Wellnex", "Well Nex")
        
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Updated {file_path}")
