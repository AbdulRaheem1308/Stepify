import re

file_path = r'c:\Users\rahee\.gemini\antigravity\scratch\wellnex\wellnex_backend\prisma\migrations\20260526081731_add_quests\migration.sql'
with open(file_path, 'r', encoding='utf-8') as f:
    sql = f.read()

sql = re.sub(r'CREATE TABLE "([^"]+)"', r'CREATE TABLE IF NOT EXISTS "\1"', sql)
sql = re.sub(r'CREATE INDEX "([^"]+)"', r'CREATE INDEX IF NOT EXISTS "\1"', sql)
sql = re.sub(r'CREATE UNIQUE INDEX "([^"]+)"', r'CREATE UNIQUE INDEX IF NOT EXISTS "\1"', sql)
sql = re.sub(r'ADD COLUMN\s+"([^"]+)"', r'ADD COLUMN IF NOT EXISTS "\1"', sql)

def replace_constraint(match):
    return f'DO $$ BEGIN\n    {match.group(0)}\nEXCEPTION\n    WHEN duplicate_object THEN null;\nEND $$;'

sql = re.sub(r'ALTER TABLE "[^"]+" ADD CONSTRAINT "[^"]+" FOREIGN KEY[^\;]+;', replace_constraint, sql)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(sql)
print('Migration updated')
