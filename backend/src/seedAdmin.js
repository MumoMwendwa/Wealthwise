import bcrypt from 'bcryptjs';
import { User } from './models/User.js';

export const seedAdmin = async () => {
  const email = String(process.env.ADMIN_EMAIL || '').toLowerCase().trim();
  const password = String(process.env.ADMIN_PASSWORD || '');
  const name = process.env.ADMIN_NAME || 'Admin';
  if (!email || !password) return;

  const existing = await User.findOne({ email });
  if (existing) return;

  const passwordHash = await bcrypt.hash(password, 10);
  await User.create({ name, email, passwordHash, role: 'admin' });
  console.log(`Admin seeded: ${email}`);
};
