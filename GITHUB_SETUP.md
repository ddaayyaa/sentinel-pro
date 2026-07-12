# Step-by-Step Guide: Pushing Sentinel Pro to GitHub

Follow these steps to securely upload your entire project to GitHub.

### 1. Create a New Repository on GitHub
1.  Go to [github.com](https://github.com) and log in.
2.  Click the **+** icon in the top right and select **New repository**.
3.  Name your repository (e.g., `sentinel-pro-v2`).
4.  Set it to **Private** (recommended since it contains security logic).
5.  **Do NOT** initialize with a README, license, or gitignore (we will do this locally).
6.  Click **Create repository**.

### 2. Initialize Git Locally
Open your terminal (Command Prompt or PowerShell) in the project root (`C:/Users/ydaya/Downloads/sentinel_pro_v2/home/claude/sentinel_pro_app`) and run:

```bash
# Initialize git
git init

# Add a root .gitignore to protect sensitive data
# Copy the content from the "Security Note" below into a file named .gitignore
```

### 3. Configure .gitignore (Crucial for Security)
Create a file named `.gitignore` in the project root and add these lines to prevent leaking private data:
```text
# Databases & Logs
backend/sentinel.db
backend/uploads/
backend/logs/
backend/faces/
*.log

# Environment & Secrets
.env
backend/venv/
.idea/
.vscode/

# Flutter/Android local files
flutter_app/build/
flutter_app/.dart_tool/
flutter_app/.flutter-plugins
flutter_app/.flutter-plugins-dependencies
flutter_app/android/local.properties

# Reports
selenium_model/screenshots/
selenium_model/logs/
```

### 4. Commit and Push
Replace `YOUR_GITHUB_URL` with the link shown on your GitHub repository page (it looks like `https://github.com/username/sentinel-pro-v2.git`).

```bash
# Stage all files
git add .

# Create initial commit
git commit -m "Initial commit: Sentinel Pro v2 with Advanced Forensic Features and Selenium Audit Engine"

# Link to GitHub (Change the URL below)
git remote add origin YOUR_GITHUB_URL

# Push to the main branch
git branch -M main
git push -u origin main
```

### 5. Verification
Refresh your GitHub repository page. You should now see your `backend/`, `flutter_app/`, and `selenium_model/` folders.

---
**Senior QA Note**: Always verify that `sentinel.db` is NOT on GitHub after pushing, as it contains your private user data and face encodings.
