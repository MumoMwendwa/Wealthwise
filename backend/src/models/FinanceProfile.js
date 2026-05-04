import mongoose from 'mongoose';

const categorySchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    budget: { type: Number, default: 0 },
    spent: { type: Number, default: 0 }
  },
  { _id: false }
);

const financeProfileSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    totalIncome: { type: Number, default: 0 },
    currentBalance: { type: Number, default: 0 },
    categories: { type: [categorySchema], default: [] }
  },
  { timestamps: true }
);

export const FinanceProfile = mongoose.model('FinanceProfile', financeProfileSchema);
