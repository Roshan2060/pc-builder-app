# 🖥️ PC Builder App

A full-stack web application to browse components, create builds, and see real-time compatibility. Backend: Django + DRF + PostgreSQL (SQL-first components). Frontend: React + TypeScript + Tailwind.

---

## 🚀 Features

- 🔐 JWT Authentication (Login/Signup)
- 🔧 Browse and manage PC components (CPU, GPU, etc.)
- 🛠️ Create and save custom PC builds (supports multiple RAM/Storage)
- 📦 RESTful API (Django REST Framework)
- 🎨 Modern UI with TailwindCSS
- ✅ Real-time compatibility tags (green ✅ compatible / red ❌ incompatible)

---

## 📁 Project Structure

DBMS/
│
├── backend/  # Django backend
│   ├── config/              # Django project settings
│   ├── pcbuilder/           # SQL-based API + auth
│   ├── manage.py
│   └── ...
│
├── frontend/ # React + Vite + TypeScript
│   ├── src/
│   ├── public/
│   └── ...
│
├── database_schema.sql             # Component tables, indexes, triggers (lean)
├── compatibility_functions.sql     # Compatibility rules (Postgres functions)
├── sample_data.sql                 # Optional seed data (lean)
└── README.md (this file)

---

## ⚙️ Backend Setup (Django + PostgreSQL)

### ✅ Prerequisites
- Python 3.10+
- PostgreSQL 13+
- pip, virtualenv

### 🔨 Steps
```bash
# Go to backend directory
cd backend

# Set up virtual environment
python -m venv venv
# Windows
venv\Scripts\activate
# macOS/Linux
# source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

Update `backend/config/settings.py` database as needed (defaults already set for Postgres):
```
DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.postgresql',
    'NAME': 'dbms_project',
    'USER': 'postgres',
    'PASSWORD': 'your_password',
    'HOST': 'localhost',
    'PORT': '5432',
  }
}
```

Run migrations (auth/sessions, etc.):
```bash
python manage.py makemigrations
python manage.py migrate
```

Create superuser (optional):
```bash
python manage.py createsuperuser
```

Run server:
```bash
python manage.py runserver
# http://localhost:8000
```

---

## 🧱 Database Setup (SQL-first components)

Apply schema and functions in psql:
```sql
\i database_schema.sql
\i compatibility_functions.sql
-- optional seed data
\i sample_data.sql
```

What this gives you
- Separate tables per component: `cpus`, `motherboards`, `ram_modules`, `gpus`,
  `storage_devices`, `power_supplies`, `cases`, `cpu_coolers`, plus `vendors`.
- Flexible builds via:
  - `builds(id, user_id, name, total_price, ...)`
  - `build_parts(build_id, part_type, part_id, quantity)`
- Triggers to auto-calc `builds.total_price`.
- Postgres functions for compatibility that return JSON.

---

## 🧪 Core API Endpoints

Catalog
- `GET /api/v1/cpus/`
- `GET /api/v1/motherboards/`
- `GET /api/v1/ram/`
- `GET /api/v1/gpus/`
- `GET /api/v1/storage/`
- `GET /api/v1/power-supplies/`
- `GET /api/v1/cases/`
- `GET /api/v1/cpu-coolers/`

Compatibility (ad‑hoc)
- `GET /api/v1/compatibility/?cpu_id=1&motherboard_id=5&gpu_id=3&case_id=2`

Options with Compatibility (for live UI)
- `GET /api/v1/options-with-compatibility/?type=<cpu|motherboard|ram|gpu|storage|psu|case|cooler>&selected_*_id=...`
- Returns items: `{ id, name, model, price, compatible }`

Builds
- `POST /api/v1/builds/`
  ```json
  {
    "user_id": 1,
    "name": "Gaming PC",
    "parts": [
      { "part_type": "cpu", "part_id": 1, "quantity": 1 },
      { "part_type": "ram", "part_id": 10, "quantity": 1 }
    ]
  }
  ```
- `GET /api/v1/users/:user_id/builds/`
- `GET /api/v1/builds/:build_id/` (includes `compatibility` summary)

Auth
- `POST /api/v1/register/`, `POST /api/v1/login/`, `POST /api/v1/logout/`, `GET /api/v1/me/`

---

## 📐 Compatibility Rules (Summary)

- CPU ↔ Motherboard: socket match
- Motherboard ↔ RAM: type match, modules ≤ slots, speed ≤ max
- GPU ↔ Case: length ≤ case max
- Case ↔ Motherboard: form factor supported
- PSU: ≥ CPU TDP + GPU TDP + 100W (or GPU recommended PSU if higher)
- Storage ↔ Motherboard: SATA/M.2 PCIe slots available
- Cooler ↔ Case: height ≤ case max
- Cooler ↔ CPU: socket supported

Each function returns `{ compatible: boolean, message: string, severity: 'success'|'warning'|'error' }`.

---

## 🖥️ Frontend Setup (React + Vite + TypeScript)

### ✅ Prerequisites
- Node.js 18+
- npm

### 🔨 Steps
```bash
cd frontend
npm install
npm run dev
# http://localhost:5173
```

### Using real-time compatibility in the UI
- When a user opens a category in the builder, call:
  `GET /api/v1/options-with-compatibility/?type=<category>&selected_*_id=...`
- Render list items with:
  - Green ✅ when `compatible: true`
  - Red ❌ when `compatible: false`
- Re-fetch the open category when any selection changes.

---

## 🔧 Extend / Customize

- Add a new rule in `compatibility_functions.sql`
- Include it in `check_build_compatibility(build_id)` and/or surface it in `options-with-compatibility`
- Seed or update parts by inserting into per-type tables

---

## ❓ Troubleshooting

- Empty lists? Ensure data in `ram_modules`, `cpu_coolers`, etc.
- Wrong tags? Verify key attributes (`socket_type`, `form_factor`, `length_mm`, `wattage`).
- API/CORS? Check browser console and backend logs (`django-cors-headers` is enabled).

---

![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/atultiwari000/pc-builder-app?utm_source=oss&utm_medium=github&utm_campaign=atultiwari000%2Fpc-builder-app&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)


