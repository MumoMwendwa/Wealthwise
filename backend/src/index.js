import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import { connectDb } from './config/db.js';
import authRoutes from './routes/auth.js';
import adminRoutes from './routes/admin.js';
import { seedAdmin } from './seedAdmin.js';

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get("/", (_req, res) => {
  res.json({
    message: 'API is healthy',
   });
});
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);

const port = Number(process.env.PORT || 4000);

const start = async () => {
  await connectDb();
  await seedAdmin();
  app.listen(port, () => {
    console.log(`API running on http://localhost:${port}`);
  });
};

start().catch((e) => {
  console.error(e);
  process.exit(1);
});
