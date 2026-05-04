# WealthWise Backend (MongoDB + Admin)

## 1) Install

```bash
cd backend
npm install
```

## 2) Configure

Copy `.env.example` to `.env` and fill:

- `MONGODB_URI`
- `JWT_SECRET`
- Optional seeded admin credentials:
  - `ADMIN_EMAIL`
  - `ADMIN_PASSWORD`
  - `ADMIN_NAME`

## 3) Run

```bash
npm run dev
```

API defaults to `http://localhost:4000`.

## Core endpoints

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/admin/users` (admin token required)
- `GET /api/admin/profiles` (admin token required)
