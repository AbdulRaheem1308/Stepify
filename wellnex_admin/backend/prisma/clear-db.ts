import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Clearing database...');
  
  // Note: we need to delete in correct order due to foreign key constraints,
  // or use raw queries to TRUNCATE/DELETE CASCADE. SQLite does not support TRUNCATE.
  // Instead, we will just delete everything in reverse dependency order or use a generic approach.

  // We can just query sqlite_master for all tables and delete from them
  const tables = await prisma.$queryRaw<
    Array<{ name: string }>
  >`SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name != '_prisma_migrations';`;

  for (const { name } of tables) {
    try {
      await prisma.$executeRawUnsafe(`DELETE FROM "${name}";`);
      console.log(`Cleared table ${name}`);
    } catch (e) {
      console.error(`Error clearing ${name}:`, e);
    }
  }
  
  console.log('Database cleared.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
