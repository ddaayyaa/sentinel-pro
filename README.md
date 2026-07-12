# SENTINEL PRO v2.0.0
## Advanced AI Security System — Flutter App + Python Backend

---

## PROJECT STRUCTURE

```
sentinel_pro_app/
├── backend/                    ← Python Flask API Server
│   ├── app.py                  ← Main server (all API endpoints)
│   ├── requirements.txt        ← Python dependencies
│   ├── sentinel.db             ← SQLite database (auto-created)
│   ├── uploads/                ← Uploaded images (auto-created)
│   ├── faces/                  ← Face encodings (auto-created)
│   └── logs/                   ← Log files (auto-created)
│
├── flutter_app/                ← Android App (Flutter)
│   ├── lib/
│   │   ├── main.dart           ← App entry point
│   │   ├── theme/              ← Dark cyberpunk theme
│   │   ├── models/             ← Data models
│   │   ├── services/           ← API service layer
│   │   ├── providers/          ← State management (Provider)
│   │   ├── widgets/            ← Reusable widgets
│   │   └── screens/
│   │       ├── auth/           ← Login, Register
│   │       ├── admin/          ← 15+ admin screens
│   │       └── user/           ← 5+ user screens
│   ├── android/                ← Android config
│   └── pubspec.yaml            ← Flutter dependencies
│
├── start.bat                   ← Windows: Start backend
├── start.sh                    ← Mac/Linux: Start backend
└── README.md                   ← This file
```

---

## APP SCREENS (30+)

### Admin Screens
1. Splash Screen
2. Login Screen (Admin tab)
3. Register Screen (3-step)
4. Admin Dashboard (stats, charts, quick actions)
5. Live Monitor (camera feed + real-time recognition)
6. Face Database (list, search, swipe-delete)
7. Face Detail Screen
8. Register Face Screen (camera + bulk photos)
9. Entry Logs Screen (tabbed, filter, export)
10. Log Detail + Override Dialog
11. Alerts Screen (severity-color coded)
12. User Approvals Screen (pending/active tabs)
13. Train Model Screen (progress, history)
14. Analytics Screen (charts, stats)
15. Camera Management Screen
16. Add Camera Dialog
17. Admin Settings Screen (all toggles)
18. Change Password Sheet
19. Profile Bottom Sheet

### User Screens
20. User Home Screen
21. User Live Scan Screen (camera + brackets overlay)
22. User Recognize Screen (single + bulk upload)
23. User Profile Screen
24. Notification Screen
25. Change Password Sheet

---

## DEFAULT LOGIN CREDENTIALS

| Role  | Username | Password  |
|-------|----------|-----------|
| Admin | admin    | admin123  |

---

## STEP-BY-STEP SETUP (See README_SETUP.md for full guide)

### Quick Start:
1. Start backend: double-click `start.bat` (Windows) or `bash start.sh` (Mac)
2. Note your PC's local IP address
3. Edit `flutter_app/lib/services/api_service.dart` — change `_baseUrl`
4. Run `flutter pub get` inside `flutter_app/`
5. Connect Android phone (USB debugging ON)
6. Run `flutter run`
