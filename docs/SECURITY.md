# StudyShield - Security & Compliance Architecture

## Table of Contents
1. [Security Overview](#security-overview)
2. [Authentication & Authorization](#authentication--authorization)
3. [Data Protection](#data-protection)
4. [Accessibility Service Security](#accessibility-service-security)
5. [Device Admin Security](#device-admin-security)
6. [Privacy Architecture](#privacy-architecture)
7. [Compliance](#compliance)
8. [Security Best Practices](#security-best-practices)

---

## Security Overview

### Security Layers

```
┌─────────────────────────────────────────┐
│  Presentation Layer Security            │
│  - Input Validation                     │
│  - HTTPS/TLS                            │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  Authentication & Authorization Layer   │
│  - JWT Tokens                           │
│  - Role-Based Access Control (RBAC)     │
│  - OAuth 2.0 / Firebase Auth            │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  Application Layer Security             │
│  - Business Logic Validation            │
│  - Rate Limiting                        │
│  - Fraud Detection                      │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  Data Layer Security                    │
│  - Database Encryption (SQLCipher)      │
│  - Field-level Encryption (AES-256)     │
│  - Secure Key Management                │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  Infrastructure Security                │
│  - Firewall                             │
│  - DDoS Protection                      │
│  - Intrusion Detection                  │
└─────────────────────────────────────────┘
```

---

## Authentication & Authorization

### Firebase Authentication

#### Supported Methods

```kotlin
// Google OAuth 2.0
signInWithGoogle(account: GoogleSignInAccount)

// Email/Password
createUserWithEmailAndPassword(email: String, password: String)
signInWithEmailAndPassword(email: String, password: String)

// Email Link Authentication (Passwordless)
sendSignInLinkToEmail(email: String)
signInWithEmailLink(email: String, link: String)
```

#### JWT Token Management

```kotlin
class TokenManager @Inject constructor(
    private val encryptedSharedPreferences: EncryptedSharedPreferences
) {
    
    fun saveToken(token: String) {
        encryptedSharedPreferences.edit().putString("jwt_token", token).apply()
    }
    
    fun getToken(): String? = encryptedSharedPreferences.getString("jwt_token", null)
    
    fun isTokenExpired(): Boolean {
        val token = getToken() ?: return true
        val payload = decodePayload(token)
        return payload.exp * 1000 < System.currentTimeMillis()
    }
    
    suspend fun refreshToken(): String {
        val refreshToken = encryptedSharedPreferences.getString("refresh_token", null)
        val response = authService.refreshToken(refreshToken)
        saveToken(response.token)
        return response.token
    }
    
    fun clearTokens() {
        encryptedSharedPreferences.edit().clear().apply()
    }
}
```

### Role-Based Access Control (RBAC)

```kotlin
sealed class UserRole {
    object STUDENT : UserRole()
    object PARENT : UserRole()
    object ADMIN : UserRole()
}

sealed class Permission {
    object READ_OWN_PROFILE : Permission()
    object WRITE_OWN_PROFILE : Permission()
    object READ_OWN_SESSIONS : Permission()
    object CREATE_SESSION : Permission()
    object READ_CHILD_SESSIONS : Permission()
}
```

---

## Data Protection

### Database Encryption

```kotlin
@Database(
    entities = [StudentEntity::class, StudySessionEntity::class],
    version = 1
)
abstract class StudyShieldDatabase : RoomDatabase() {
    abstract fun studentDao(): StudentDao
}
```

### Sensitive Data Handling

```kotlin
class PasswordValidator {
    
    fun isValid(password: String): Boolean {
        val pattern = Regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}$")
        return pattern.containsMatchIn(password)
    }
    
    fun hashPassword(password: String): String {
        return BCrypt.hashpw(password, BCrypt.gensalt(12))
    }
}
```

---

## Accessibility Service Security

### Implementation

```kotlin
class StudyShieldAccessibilityService : AccessibilityService() {
    
    private val allowedApps = mutableListOf<String>()
    private val blockedApps = mutableListOf<String>()
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                handleWindowStateChange(event)
            }
        }
    }
    
    private fun handleWindowStateChange(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        
        if (isStudySessionActive()) {
            when {
                allowedApps.contains(packageName) -> {
                    logAudit("App Allowed: $packageName")
                }
                blockedApps.contains(packageName) -> {
                    blockAppLaunch(packageName)
                    recordBlockAttempt(packageName)
                }
            }
        }
    }
}
```

---

## Device Admin Security

### Implementation

```kotlin
class StudyShieldDeviceAdminReceiver : DeviceAdminReceiver() {
    
    override fun onEnabled(context: Context, intent: Intent) {
        logAudit("Device Admin Enabled", "SECURITY_EVENT")
    }
    
    override fun onDisabled(context: Context, intent: Intent) {
        logAudit("Device Admin Disabled", "SECURITY_EVENT")
    }
}
```

---

## Privacy Architecture

### Privacy Settings

```kotlin
class PrivacySettings {
    var analyticsEnabled: Boolean = true
    var crashReportingEnabled: Boolean = true
    
    fun deleteAllPersonalData() {
        sessionRepository.deleteAllUserSessions()
        profileRepository.anonymizeProfile()
        logAudit("User Data Deleted", "PRIVACY_EVENT")
    }
}
```

---

## Compliance

- [x] GDPR Compliance
- [x] CCPA Compliance
- [x] COPPA Compliance (Child Safety)
- [x] Data Encryption
- [x] Audit Logging
