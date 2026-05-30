import os

target_files = [
    "wellnex_app/lib/features/challenges/presentation/screens/challenges_screen.dart",
    "wellnex_app/lib/features/challenges/presentation/widgets/challenge_card.dart",
    "wellnex_app/lib/features/gamification/presentation/providers/badges_provider.dart",
    "wellnex_app/lib/features/profile/presentation/screens/profile_screen.dart",
    "wellnex_app/lib/features/referral/presentation/screens/referral_leaderboard_screen.dart",
    "wellnex_app/lib/features/referral/presentation/screens/referral_screen.dart",
    "wellnex_app/lib/features/referral/presentation/widgets/visual_share_card.dart",
    "wellnex_app/lib/features/rewards/presentation/screens/rewards_screen.dart",
    "wellnex_app/lib/features/rewards/presentation/widgets/reward_card.dart",
    "wellnex_app/lib/features/settings/presentation/screens/settings_screen.dart",
    "wellnex_app/lib/features/teams/presentation/screens/team_detail_screen.dart",
    "wellnex_app/lib/core/services/push_notification_service.dart",
    "wellnex_app/lib/core/theme/app_theme.dart"
]

for file_path in target_files:
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # We don't want to replace "Wellnex Coins" if it already changed to "WN Coins", 
        # but there shouldn't be any in these files. Just "Wellnex" -> "Well Nex"
        new_content = content.replace("Wellnex", "Well Nex")
        
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Updated {file_path}")
