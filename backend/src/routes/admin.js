import express from 'express';
import { User } from '../models/User.js';
import { FinanceProfile } from '../models/FinanceProfile.js';
import { adminOnly, authRequired } from '../middleware/auth.js';

const router = express.Router();

router.use(authRequired, adminOnly);

router.get('/users', async (_req, res) => {
  const users = await User.find().select('_id name email role createdAt').sort({ createdAt: -1 });
  res.json({ users });
});

router.get('/profiles', async (_req, res) => {
  const profiles = await FinanceProfile.find().populate('userId', 'name email role');
  res.json({ profiles });
});

export default router;
