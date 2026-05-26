"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function main() {
    try {
        const res = await prisma.$queryRaw `
      SELECT * FROM "transactions" WHERE "type" = 'STEPS' LIMIT 5;
    `;
        console.log(res);
    }
    catch (e) {
        console.error(e.message);
    }
    finally {
        await prisma.$disconnect();
    }
}
main();
//# sourceMappingURL=test.js.map