import sqlite3
import os

DB_MOBILE = r'C:\Users\ydaya\Downloads\sentinel_pro_v2\home\claude\sentinel_pro_app\backend\sentinel.db'
DB_WEB = r'C:\Users\ydaya\Downloads\sentinel_pro_advanced (2)\sentinel_pro\database\sentinel.db'
DB_SHARED = r'C:\Users\ydaya\Downloads\sentinel_pro_shared.db'

def merge():
    print(f"Ensuring shared database at: {DB_SHARED}")

    # Connect to shared DB
    shared_conn = sqlite3.connect(DB_SHARED)
    shared_conn.row_factory = sqlite3.Row
    shared_cur = shared_conn.cursor()

    # Define Unified Schema
    shared_cur.executescript('''
    CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT DEFAULT 'user',
        status TEXT DEFAULT 'pending',
        approved INTEGER DEFAULT 0,
        full_name TEXT,
        phone TEXT,
        department TEXT,
        avatar_url TEXT,
        avatar_color TEXT,
        created_at TEXT DEFAULT (datetime('now', 'localtime')),
        last_login TEXT,
        is_online INTEGER DEFAULT 0,
        approved_at TEXT,
        approved_by TEXT,
        face_registered INTEGER DEFAULT 0,
        face_count INTEGER DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS face_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        department TEXT,
        phone TEXT,
        status TEXT DEFAULT 'active',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        last_seen TEXT,
        encodings_count INTEGER DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS entry_logs (
        id TEXT PRIMARY KEY,
        person_id TEXT,
        person_name TEXT,
        status TEXT,
        confidence REAL,
        gate TEXT,
        timestamp TEXT,
        image_path TEXT,
        admin_override INTEGER DEFAULT 0,
        override_by TEXT,
        notes TEXT,
        detection_method TEXT,
        camera_id TEXT,
        entry_point TEXT,
        admin_note TEXT,
        alert_triggered INTEGER DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS registered_faces (
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        person_name TEXT NOT NULL,
        image_path TEXT,
        encoding_path TEXT,
        registered_by TEXT,
        registered_at TEXT,
        is_authorized INTEGER DEFAULT 1,
        category TEXT DEFAULT 'staff',
        notes TEXT
    );
    CREATE TABLE IF NOT EXISTS alerts (
        id TEXT PRIMARY KEY,
        type TEXT,
        message TEXT,
        person_name TEXT,
        gate TEXT,
        timestamp TEXT,
        resolved INTEGER DEFAULT 0,
        resolved_by TEXT,
        severity TEXT DEFAULT 'medium',
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        title TEXT
    );
    CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        title TEXT,
        body TEXT,
        type TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        data TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS camera_devices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        url TEXT,
        status TEXT DEFAULT 'online',
        last_ping TEXT,
        location TEXT,
        stream_url TEXT,
        detection_count INTEGER DEFAULT 0,
        last_activity TEXT
    );
    CREATE TABLE IF NOT EXISTS ai_training (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );
    CREATE TABLE IF NOT EXISTS training_sessions (
        id TEXT PRIMARY KEY,
        started_at TEXT,
        completed_at TEXT,
        total_images INTEGER,
        total_persons INTEGER,
        status TEXT,
        model_type TEXT,
        accuracy REAL,
        notes TEXT
    );
    ''')
    shared_conn.commit()

    # 1. Import Mobile Data
    if os.path.exists(DB_MOBILE):
        print("Importing Mobile data...")
        m_conn = sqlite3.connect(DB_MOBILE)
        m_conn.row_factory = sqlite3.Row

        # Users
        m_users = m_conn.execute("SELECT * FROM users").fetchall()
        for u in m_users:
            u_dict = dict(u)
            try:
                shared_cur.execute("""INSERT OR IGNORE INTO users
                    (id, username, email, password_hash, role, status, approved, full_name, phone, department, avatar_url, created_at, last_login, is_online)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                    (str(u_dict['id']), u_dict['username'], u_dict['email'], u_dict['password_hash'], u_dict['role'], u_dict['status'], 1 if u_dict['status']=='active' else 0, u_dict.get('full_name'), u_dict.get('phone'), u_dict.get('department'), u_dict.get('avatar_url'), u_dict.get('created_at'), u_dict.get('last_login'), u_dict.get('is_online', 0)))
            except Exception as e:
                print(f"Error importing mobile user {u_dict['username']}: {e}")

        # Face Records
        print("Importing Mobile face records...")
        m_faces = m_conn.execute("SELECT * FROM face_records").fetchall()
        for f in m_faces:
            f_dict = dict(f)
            try:
                shared_cur.execute("""INSERT OR IGNORE INTO face_records
                    (person_id, name, department, phone, status, created_at, last_seen, encodings_count)
                    VALUES (?,?,?,?,?,?,?,?)""",
                    (f_dict['person_id'], f_dict['person_name'], f_dict.get('department'), f_dict.get('phone'), f_dict['status'], f_dict['registered_at'], f_dict.get('last_seen'), f_dict.get('encoding_count', 0)))
            except Exception as e:
                print(f"Error importing mobile face {f_dict['person_name']}: {e}")

        # Entry Logs
        # (mapping security_alerts to alerts if needed, but here entry_logs)
        m_logs = m_conn.execute("SELECT * FROM entry_logs").fetchall()
        for l in m_logs:
            l_dict = dict(l)
            shared_cur.execute("""INSERT OR IGNORE INTO entry_logs
                (id, person_id, person_name, status, confidence, gate, timestamp, image_path, admin_override, overridden_by, admin_note, alert_triggered, camera_id, entry_point)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                (str(l_dict['id']), l_dict.get('person_id'), l_dict.get('person_name'), l_dict.get('status'), l_dict.get('confidence'), l_dict.get('gate'), l_dict.get('timestamp'), l_dict.get('image_path'), l_dict.get('admin_override', 0), l_dict.get('overridden_by'), l_dict.get('admin_note'), l_dict.get('alert_triggered', 0), l_dict.get('camera_id'), l_dict.get('entry_point')))

        m_conn.close()

    # 2. Import Web Data
    if os.path.exists(DB_WEB):
        print("Importing Web data...")
        w_conn = sqlite3.connect(DB_WEB)
        w_conn.row_factory = sqlite3.Row

        # Users
        w_users = w_conn.execute("SELECT * FROM users").fetchall()
        for u in w_users:
            u_dict = dict(u)
            try:
                status = 'active' if u_dict['approved'] == 1 else 'pending'
                shared_cur.execute("""INSERT OR IGNORE INTO users
                    (id, username, email, password_hash, role, status, approved, full_name, phone, department, avatar_color, created_at, last_login, approved_at, approved_by, face_registered, face_count)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                    (u_dict['id'], u_dict['username'], u_dict['email'], u_dict['password_hash'], u_dict['role'], status, u_dict['approved'], u_dict.get('full_name'), u_dict.get('phone'), u_dict.get('department'), u_dict.get('avatar_color'), u_dict.get('created_at'), u_dict.get('last_login'), u_dict.get('approved_at'), u_dict.get('approved_by'), u_dict.get('face_registered', 0), u_dict.get('face_count', 0)))
            except Exception as e:
                print(f"Error importing web user {u_dict['username']}: {e}")

        # Registered Faces
        w_faces = w_conn.execute("SELECT * FROM registered_faces").fetchall()
        for f in w_faces:
            f_dict = dict(f)
            shared_cur.execute("""INSERT OR IGNORE INTO registered_faces
                (id, person_id, person_name, image_path, encoding_path, registered_by, registered_at, is_authorized, category, notes)
                VALUES (?,?,?,?,?,?,?,?,?,?)""",
                (f_dict['id'], f_dict['person_id'], f_dict['person_name'], f_dict.get('image_path'), f_dict.get('encoding_path'), f_dict.get('registered_by'), f_dict.get('registered_at'), f_dict.get('is_authorized', 1), f_dict.get('category', 'staff'), f_dict.get('notes')))

        # Entry Logs
        w_logs = w_conn.execute("SELECT * FROM entry_logs").fetchall()
        for l in w_logs:
            l_dict = dict(l)
            shared_cur.execute("""INSERT OR IGNORE INTO entry_logs
                (id, person_id, person_name, status, confidence, gate, timestamp, image_path, admin_override, override_by, notes, detection_method)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
                (str(l_dict['id']), l_dict.get('person_id'), l_dict.get('person_name'), l_dict.get('status'), l_dict.get('confidence'), l_dict.get('gate'), l_dict.get('timestamp'), l_dict.get('image_path'), l_dict.get('admin_override', 0), l_dict.get('override_by'), l_dict.get('notes'), l_dict.get('detection_method')))

        # Alerts
        try:
            w_alerts = w_conn.execute("SELECT * FROM alerts").fetchall()
            for a in w_alerts:
                a_dict = dict(a)
                shared_cur.execute("""INSERT OR IGNORE INTO alerts
                    (id, type, message, person_name, gate, timestamp, resolved, resolved_by)
                    VALUES (?,?,?,?,?,?,?,?)""",
                    (str(a_dict['id']), a_dict.get('type'), a_dict.get('message'), a_dict.get('person_name'), a_dict.get('gate'), a_dict.get('timestamp'), a_dict.get('resolved', 0), a_dict.get('resolved_by')))
        except: pass

        w_conn.close()

    shared_conn.commit()
    shared_conn.close()
    print("Merge Complete!")

if __name__ == "__main__":
    merge()
