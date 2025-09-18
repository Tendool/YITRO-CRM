/**
 * Development server that runs the API independently
 */
import { createServerSimple } from "./server/index-simple.ts";
import { config } from 'dotenv';
config();

const app = createServerSimple();
const PORT = process.env.API_PORT || 3001;

app.listen(PORT, () => {
  console.log(`🚀 API Server running on http://localhost:${PORT}`);
  console.log(`📊 Database: SQLite (${process.env.DATABASE_URL || 'dev.db'})`);
  console.log(`🔐 Test accounts:`);
  console.log(`   Admin: admin@yitro.com / admin123`);
  console.log(`   User: user@yitro.com / admin123`);
});