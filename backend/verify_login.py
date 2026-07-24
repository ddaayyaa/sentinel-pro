import sqlite3
import hashlib
import os

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

db_path = r'C:\Users\ydaya\Downloads\sentinel_pro_shared.db'
if not os.path.exists(db_path):
    print(f"Error: {db_path} not found")
    exit(1)

db = sqlite3.connect(db_path)
db.row_factory = sqlite3.Row

# Test 1: Verify admin user exists and password matches
identifier = 'admin'
password_hash = hash_password('admin123')
user = db.execute("SELECT * FROM users WHERE (username=? OR email=?) AND password_hash=?",
                  (identifier, identifier, password_hash)).fetchone()

if user:
    print(f"✅ Login Success for {identifier}")
    print(f"   User: {user['username']}, Role: {user['role']}, Status: {user['status']}")
else:
    print(f"❌ Login Failed for {identifier}")

# Test 2: Verify email login (if admin has email)
email = 'admin@sentinel.pro'
user_email = db.execute("SELECT * FROM users WHERE (username=? OR email=?) AND password_hash=?",
                        (email, email, password_hash)).fetchone()

if user_email:
    print(f"✅ Login Success for {email}")
else:
    print(f"❌ Login Failed for {email}")

db.close()
