import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User } from '../models/User.js';

const router = express.Router();

const tokenFor = (user) =>
  jwt.sign({ sub: user._id.toString(), role: user.role }, process.env.JWT_SECRET, {
    expiresIn: '7d'
  });

const toUserDto = (user) => ({
  _id: user._id,
  name: user.name,
  email: user.email,
  role: user.role
});

router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'name, email and password are required' });
    }
    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) return res.status(409).json({ message: 'Email already registered' });

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      email: email.toLowerCase(),
      passwordHash,
      role: role === 'admin' ? 'admin' : 'user'
    });
    return res.status(201).json({ token: tokenFor(user), user: toUserDto(user) });
  } catch (e) {
    return res.status(500).json({ message: 'Registration failed', detail: e.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email: String(email || '').toLowerCase() });
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });

    const ok = await bcrypt.compare(String(password || ''), user.passwordHash);
    if (!ok) return res.status(401).json({ message: 'Invalid credentials' });

    return res.json({ token: tokenFor(user), user: toUserDto(user) });
  } catch (e) {
    return res.status(500).json({ message: 'Login failed', detail: e.message });
  }
});

export default router;
