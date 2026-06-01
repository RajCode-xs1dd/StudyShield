-- StudyShield Database Schema
-- Room Database Schema for Android Application

-- ============================================
-- CORE ENTITIES
-- ============================================

-- Students Table
CREATE TABLE students (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    profile_image_url TEXT,
    join_date INTEGER NOT NULL,
    total_study_hours INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    best_streak INTEGER DEFAULT 0,
    last_session_date INTEGER,
    xp_points INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    parent_email TEXT,
    is_parent_mode_enabled INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- ============================================
-- STUDY SESSION MANAGEMENT
-- ============================================

-- Study Sessions Table
CREATE TABLE study_sessions (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL,
    session_type TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    start_time INTEGER NOT NULL,
    end_time INTEGER,
    actual_duration_minutes INTEGER,
    focus_score INTEGER,
    apps_blocked_count INTEGER DEFAULT 0,
    completed INTEGER DEFAULT 0,
    notes TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- ============================================
-- APP MANAGEMENT
-- ============================================

CREATE TABLE allowed_apps (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL,
    package_name TEXT NOT NULL,
    app_name TEXT NOT NULL,
    category TEXT,
    is_system_app INTEGER DEFAULT 0,
    added_date INTEGER NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE (student_id, package_name)
);

CREATE TABLE blocked_apps (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL,
    package_name TEXT NOT NULL,
    app_name TEXT NOT NULL,
    category TEXT,
    added_date INTEGER NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE (student_id, package_name)
);

-- ============================================
-- EDUCATIONAL CONTENT
-- ============================================

CREATE TABLE educational_channels (
    id TEXT PRIMARY KEY,
    channel_id TEXT NOT NULL UNIQUE,
    channel_name TEXT NOT NULL,
    category TEXT,
    is_verified INTEGER DEFAULT 0,
    ai_verified INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
);

CREATE TABLE student_channels (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL,
    channel_id TEXT NOT NULL,
    subscribed_date INTEGER NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (channel_id) REFERENCES educational_channels(id) ON DELETE CASCADE,
    UNIQUE (student_id, channel_id)
);

-- ============================================
-- ANALYTICS
-- ============================================

CREATE TABLE daily_stats (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL,
    date TEXT NOT NULL,
    study_hours_total REAL DEFAULT 0,
    focus_score_average INTEGER DEFAULT 0,
    apps_blocked_count INTEGER DEFAULT 0,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE (student_id, date)
);

-- ============================================
-- GAMIFICATION
-- ============================================

CREATE TABLE achievements (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL,
    badge_id TEXT NOT NULL,
    badge_name TEXT NOT NULL,
    is_unlocked INTEGER DEFAULT 0,
    unlocked_date INTEGER,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE (student_id, badge_id)
);
