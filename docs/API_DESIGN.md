# StudyShield API Design Documentation

## Base URL
```
Production: https://api.studyshield.app/v1
Development: http://localhost:3000/v1
```

## Authentication

### Bearer Token
All authenticated requests must include:
```
Authorization: Bearer <JWT_TOKEN>
```

---

## Authentication API

### 1. Register User

```http
POST /auth/register
Content-Type: application/json

{
  "email": "student@example.com",
  "password": "SecurePassword123!",
  "name": "John Doe",
  "userType": "STUDENT" // or "PARENT"
}

Response 201 Created:
{
  "success": true,
  "data": {
    "userId": "student_id_123",
    "email": "student@example.com",
    "token": "jwt_token",
    "tokenExpiry": 3600
  }
}
```

### 2. Login

```http
POST /auth/login
Content-Type: application/json

{
  "email": "student@example.com",
  "password": "SecurePassword123!"
}

Response 200 OK:
{
  "success": true,
  "data": {
    "userId": "student_id_123",
    "email": "student@example.com",
    "token": "jwt_token",
    "refreshToken": "refresh_token",
    "tokenExpiry": 3600,
    "userType": "STUDENT"
  }
}
```

### 3. Refresh Token

```http
POST /auth/refresh-token
Content-Type: application/json

{
  "refreshToken": "refresh_token"
}

Response 200 OK:
{
  "success": true,
  "data": {
    "token": "new_jwt_token",
    "tokenExpiry": 3600
  }
}
```

### 4. Logout

```http
POST /auth/logout
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "message": "Logged out successfully"
}
```

### 5. Verify Email

```http
GET /auth/verify-email?token=verification_token

Response 200 OK:
{
  "success": true,
  "message": "Email verified successfully"
}
```

### 6. Password Reset

```http
POST /auth/password-reset
Content-Type: application/json

{
  "email": "student@example.com"
}

Response 200 OK:
{
  "success": true,
  "message": "Password reset link sent to email"
}

PUT /auth/password-reset?token=reset_token
Content-Type: application/json

{
  "newPassword": "NewSecurePassword123!"
}

Response 200 OK:
{
  "success": true,
  "message": "Password reset successfully"
}
```

---

## Student Profile API

### 1. Get Profile

```http
GET /students/profile
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "id": "student_id_123",
    "email": "student@example.com",
    "name": "John Doe",
    "profileImageUrl": "https://...",
    "joinDate": 1704067200000,
    "totalStudyHours": 150,
    "currentStreak": 7,
    "bestStreak": 21,
    "xpPoints": 5430,
    "level": 8,
    "parentEmail": null,
    "parentModeEnabled": false
  }
}
```

### 2. Update Profile

```http
PUT /students/profile
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "name": "John Doe Updated",
  "profileImageUrl": "https://..."
}

Response 200 OK:
{
  "success": true,
  "data": { /* updated profile */ }
}
```

### 3. Get Student Statistics

```http
GET /students/{id}/stats?period=DAILY|WEEKLY|MONTHLY
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "periodType": "DAILY",
    "startDate": "2024-01-01",
    "endDate": "2024-01-31",
    "totalStudyHours": 45.5,
    "averageFocusScore": 87,
    "sessionsCompleted": 32,
    "blockedAttempts": 156,
    "breaksTaken": 12
  }
}
```

### 4. Get Achievements

```http
GET /students/{id}/achievements
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [
    {
      "id": "achievement_1",
      "badgeId": "7_day_streak",
      "badgeName": "Week Warrior",
      "description": "Complete a 7-day study streak",
      "iconUrl": "https://...",
      "unlockedDate": 1704067200000,
      "isUnlocked": true,
      "progressCurrent": 7,
      "progressRequired": 7
    },
    {
      "id": "achievement_2",
      "badgeId": "30_day_streak",
      "badgeName": "Month Master",
      "isUnlocked": false,
      "progressCurrent": 7,
      "progressRequired": 30
    }
  ]
}
```

---

## Study Session API

### 1. Start Session

```http
POST /sessions/start
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "durationMinutes": 60,
  "allowedApps": ["com.google.android.gms", "com.example.notes"],
  "allowedChannelIds": ["UC1234", "UC5678"],
  "settings": {
    "silentNotifications": true,
    "disableAppSwitcher": true,
    "hideHomeButton": true
  }
}

Response 201 Created:
{
  "success": true,
  "data": {
    "sessionId": "session_123",
    "studentId": "student_id_123",
    "startTime": 1704067200000,
    "endTime": 1704070800000,
    "durationMinutes": 60,
    "status": "ACTIVE"
  }
}
```

### 2. Get Current Session

```http
GET /sessions/current
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "sessionId": "session_123",
    "startTime": 1704067200000,
    "remainingTimeSeconds": 1800,
    "elapsedTimeSeconds": 1800,
    "allowedApps": [ /* list */ ],
    "blockedAttempts": 12,
    "status": "ACTIVE"
  }
}
```

### 3. End Session

```http
POST /sessions/{sessionId}/end
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "notes": "Great focus session"
}

Response 200 OK:
{
  "success": true,
  "data": {
    "sessionId": "session_123",
    "actualDurationSeconds": 3600,
    "focusScore": 92,
    "blockedAttempts": 12,
    "notes": "Great focus session",
    "status": "COMPLETED"
  }
}
```

### 4. Pause/Resume Session

```http
POST /sessions/{sessionId}/pause
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": { /* session data */ }
}

POST /sessions/{sessionId}/resume
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": { /* session data */ }
}
```

### 5. Emergency Unlock

```http
POST /sessions/{sessionId}/emergency-unlock
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "reason": "Parent emergency call",
  "unlockDurationSeconds": 300
}

Response 200 OK:
{
  "success": true,
  "data": {
    "unlockId": "unlock_123",
    "unlockEndTime": 1704070500000,
    "remainingUnlocksToday": 1
  }
}
```

### 6. Get Sessions History

```http
GET /sessions?from=2024-01-01&to=2024-01-31&page=1&limit=20
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "sessions": [
      {
        "sessionId": "session_123",
        "startTime": 1704067200000,
        "endTime": 1704070800000,
        "durationMinutes": 60,
        "focusScore": 92,
        "status": "COMPLETED"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45
    }
  }
}
```

---

## App Management API

### 1. Get Installed Apps

```http
GET /apps/installed
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [
    {
      "packageName": "com.example.app",
      "appName": "Example App",
      "category": "PRODUCTIVITY",
      "iconUrl": "https://..."
    }
  ]
}
```

### 2. Add Allowed App

```http
POST /apps/allowed
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "packageName": "com.google.android.gms",
  "appName": "Google Play Services",
  "category": "SYSTEM"
}

Response 201 Created:
{
  "success": true,
  "data": { /* allowed app */ }
}
```

### 3. Get Allowed Apps

```http
GET /apps/allowed
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [
    {
      "id": "allowed_app_1",
      "packageName": "com.google.android.gms",
      "appName": "Google Play Services",
      "category": "SYSTEM"
    }
  ]
}
```

### 4. Remove Allowed App

```http
DELETE /apps/allowed/{id}
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "message": "App removed from allowed list"
}
```

### 5. Add Blocked App

```http
POST /apps/blocked
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "packageName": "com.instagram.android",
  "appName": "Instagram",
  "category": "SOCIAL_MEDIA",
  "blockReason": "Distraction"
}

Response 201 Created:
{
  "success": true,
  "data": { /* blocked app */ }
}
```

### 6. Get Blocked Apps

```http
GET /apps/blocked
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [
    {
      "id": "blocked_app_1",
      "packageName": "com.instagram.android",
      "appName": "Instagram",
      "category": "SOCIAL_MEDIA"
    }
  ]
}
```

---

## Educational Channels API

### 1. Get All Channels

```http
GET /channels?page=1&limit=20
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "channels": [
      {
        "id": "channel_1",
        "channelId": "UCxxx",
        "channelName": "Khan Academy",
        "category": "EDUCATION",
        "subscriberCount": 5000000,
        "isVerified": true,
        "thumbnailUrl": "https://..."
      }
    ],
    "pagination": { /* ... */ }
  }
}
```

### 2. Get Channel by ID

```http
GET /channels/{id}
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": { /* channel data */ }
}
```

### 3. Get Channels by Category

```http
GET /channels?category=PROGRAMMING&page=1&limit=20
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": { /* channels */ }
}
```

### 4. Search Channels

```http
GET /channels/search?q=python&page=1&limit=20
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": { /* search results */ }
}
```

### 5. Subscribe to Channel

```http
POST /channels/subscribe
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "channelId": "UCxxx"
}

Response 201 Created:
{
  "success": true,
  "data": {
    "id": "subscription_1",
    "channelId": "UCxxx",
    "subscribedDate": 1704067200000
  }
}
```

### 6. Get Subscribed Channels

```http
GET /channels/subscribed
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [ /* subscribed channels */ ]
}
```

### 7. Unsubscribe from Channel

```http
DELETE /channels/subscribe/{subscriptionId}
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "message": "Unsubscribed successfully"
}
```

---

## Analytics API

### 1. Get Daily Statistics

```http
GET /analytics/daily?date=2024-01-15
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "date": "2024-01-15",
    "studyHoursTotal": 4.5,
    "focusScoreAverage": 88,
    "appsBlockedCount": 23,
    "sessionsCount": 3,
    "breaksTaken": 2,
    "mostUsedApp": "com.google.android.gms",
    "mostFocusedTime": "14:00-15:30"
  }
}
```

### 2. Get Weekly Statistics

```http
GET /analytics/weekly?week=2024-01
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "weekStartDate": "2024-01-01",
    "weekEndDate": "2024-01-07",
    "studyHoursTotal": 28.5,
    "focusScoreAverage": 86,
    "sessionsCount": 21,
    "longestSessionMinutes": 120,
    "dailyStats": [ /* array of daily data */ ]
  }
}
```

### 3. Get Monthly Statistics

```http
GET /analytics/monthly?month=2024-01
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "month": "2024-01",
    "studyHoursTotal": 120.5,
    "focusScoreAverage": 85,
    "sessionsCount": 87,
    "weeklyStats": [ /* array of weekly data */ ]
  }
}
```

### 4. Get Overall Summary

```http
GET /analytics/summary
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "allTimeStudyHours": 450.5,
    "currentStreak": 7,
    "bestStreak": 21,
    "totalSessionsCompleted": 287,
    "averageFocusScore": 87,
    "totalBlockedAttempts": 1243
  }
}
```

---

## Achievement & Gamification API

### 1. Get All Achievements

```http
GET /achievements
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [
    {
      "id": "achievement_1",
      "badgeId": "7_day_streak",
      "badgeName": "Week Warrior",
      "description": "Complete a 7-day study streak",
      "iconUrl": "https://...",
      "isUnlocked": true,
      "unlockedDate": 1704067200000,
      "progress": { "current": 7, "required": 7 }
    }
  ]
}
```

### 2. Get Unlocked Achievements

```http
GET /achievements/unlocked
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [ /* unlocked achievements only */ ]
}
```

### 3. Get Achievement Progress

```http
GET /achievements/{id}/progress
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "id": "achievement_1",
    "badgeName": "Week Warrior",
    "progressCurrent": 7,
    "progressRequired": 7,
    "isUnlocked": true,
    "unlockedDate": 1704067200000
  }
}
```

---

## Parent Mode API

### 1. Link Student to Parent Account

```http
POST /parent/link-student
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "studentEmail": "student@example.com"
}

Response 201 Created:
{
  "success": true,
  "data": {
    "linkId": "link_123",
    "studentId": "student_id_123",
    "linkedDate": 1704067200000
  }
}
```

### 2. Get Linked Students

```http
GET /parent/students
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [
    {
      "studentId": "student_id_123",
      "studentName": "John Doe",
      "email": "student@example.com",
      "currentStreak": 7,
      "totalStudyHours": 150
    }
  ]
}
```

### 3. Get Student Sessions

```http
GET /parent/student/{studentId}/sessions?from=2024-01-01&to=2024-01-31
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": [
    {
      "sessionId": "session_123",
      "startTime": 1704067200000,
      "endTime": 1704070800000,
      "durationMinutes": 60,
      "focusScore": 92
    }
  ]
}
```

### 4. Get Student Statistics

```http
GET /parent/student/{studentId}/stats?period=MONTHLY
Authorization: Bearer <JWT_TOKEN>

Response 200 OK:
{
  "success": true,
  "data": {
    "month": "2024-01",
    "totalStudyHours": 120,
    "averageFocusScore": 85,
    "sessionsCompleted": 45
  }
}
```

### 5. Update Parent Settings

```http
PUT /parent/settings
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "studentId": "student_id_123",
  "canViewSessions": true,
  "canViewStats": true,
  "canModifyAllowedApps": true,
  "notificationFrequency": "DAILY"
}

Response 200 OK:
{
  "success": true,
  "data": { /* updated settings */ }
}
```

---

## Error Responses

### Standard Error Format

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "timestamp": 1704067200000
  }
}
```

### HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | OK | Successful GET, PUT |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate entry |
| 429 | Too Many Requests | Rate limited |
| 500 | Server Error | Internal error |

### Common Error Codes

```
INVALID_EMAIL
WEAK_PASSWORD
USER_ALREADY_EXISTS
INVALID_CREDENTIALS
TOKEN_EXPIRED
INSUFFICIENT_PERMISSIONS
RESOURCE_NOT_FOUND
DUPLICATE_ENTRY
RATE_LIMIT_EXCEEDED
INTERNAL_SERVER_ERROR
```

---

## Rate Limiting

All endpoints are rate-limited to:
- **Authenticated Users**: 1000 requests per hour
- **Unauthenticated**: 100 requests per hour

Rate limit headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1704070800
```

---

## Pagination

All list endpoints support pagination:

```
GET /endpoint?page=1&limit=20&sort=created_at&order=DESC

Response includes:
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

---

## Webhook Events

The API sends webhooks for key events:

### Session Completed
```json
{
  "event": "session.completed",
  "timestamp": 1704067200000,
  "data": {
    "sessionId": "session_123",
    "focusScore": 92,
    "durationMinutes": 60
  }
}
```

### Achievement Unlocked
```json
{
  "event": "achievement.unlocked",
  "timestamp": 1704067200000,
  "data": {
    "achievementId": "achievement_1",
    "badgeName": "Week Warrior"
  }
}
```

---

## API Versioning

- Current version: v1
- Base URL includes version: `/v1/`
- Future versions will support: `/v2/`, `/v3/`, etc.

