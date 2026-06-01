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

#### JWT Token Structure

```
Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload:
{
  "sub": "student_id_123",
  "email": "student@example.com",
  "iat": 1704067200,
  "exp": 1704070800,
  "role": "STUDENT",
  "permissions": ["read:profile", "write:sessions"]
}

Signature:
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), SECRET)
```

#### Token Management

```kotlin
class TokenManager @Inject constructor(
    private val encryptedSharedPreferences: EncryptedSharedPreferences
) {
    
    // Store encrypted token
    fun saveToken(token: String) {
        encryptedSharedPreferences.edit().putString("jwt_token", token).apply()
    }
    
    // Retrieve token
    fun getToken(): String? = encryptedSharedPreferences.getString("jwt_token", null)
    
    // Check if token is expired
    fun isTokenExpired(): Boolean {
        val token = getToken() ?: return true
        val payload = decodePayload(token)
        return payload.exp * 1000 < System.currentTimeMillis()
    }
    
    // Refresh token
    suspend fun refreshToken(): String {
        val refreshToken = encryptedSharedPreferences.getString("refresh_token", null)
        val response = authService.refreshToken(refreshToken)
        saveToken(response.token)
        return response.token
    }
    
    // Clear tokens on logout
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
    // Student Permissions
    object READ_OWN_PROFILE : Permission()
    object WRITE_OWN_PROFILE : Permission()
    object READ_OWN_SESSIONS : Permission()
    object CREATE_SESSION : Permission()
    object END_SESSION : Permission()
    
    // Parent Permissions
    object READ_CHILD_PROFILE : Permission()
    object READ_CHILD_SESSIONS : Permission()
    object READ_CHILD_STATS : Permission()
    object MODIFY_CHILD_SETTINGS : Permission()
    
    // Admin Permissions
    object MANAGE_USERS : Permission()
    object MANAGE_CONTENT : Permission()
    object VIEW_ANALYTICS : Permission()
}

class AuthorizationInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val token = tokenManager.getToken() ?: return chain.proceed(request)
        
        // Verify token and permissions
        val decodedToken = jwtDecoder.decode(token)
        val permissions = decodedToken.permissions
        
        if (!hasRequiredPermission(request, permissions)) {
            return Response.Builder()
                .code(403)
                .message("Forbidden")
                .build()
        }
        
        return chain.proceed(request)
    }
}
```

---

## Data Protection

### Database Encryption

```kotlin
// Room Database with SQLCipher
@Database(
    entities = [StudentEntity::class, StudySessionEntity::class, ...],
    version = 1,
    exportSchema = true
)
abstract class StudyShieldDatabase : RoomDatabase() {
    abstract fun studentDao(): StudentDao
    
    companion object {
        @Volatile
        private var INSTANCE: StudyShieldDatabase? = null
        
        fun getInstance(context: Context): StudyShieldDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    StudyShieldDatabase::class.java,
                    "studyshield.db"
                )
                    .openHelperFactory(
                        FrameworkSQLiteOpenHelperFactory()
                    )
                    .addMigrations(MIGRATION_1_2)
                    .build()
                
                INSTANCE = instance
                instance
            }
        }
        
        // SQLCipher encryption
        private fun createEncryptedDatabase(context: Context): SupportSQLiteOpenHelper.Factory {
            val passphrase = SecurityUtils.derivePassphrase(context)
            return SupportSQLiteOpenHelperFactory(passphrase)
        }
    }
}
```

### Field-Level Encryption

```kotlin
class EncryptedDataConverter {
    
    @TypeConverter
    fun encryptString(value: String?): String? {
        if (value == null) return null
        return CipherUtils.encrypt(value, getEncryptionKey())
    }
    
    @TypeConverter
    fun decryptString(value: String?): String? {
        if (value == null) return null
        return CipherUtils.decrypt(value, getEncryptionKey())
    }
    
    companion object {
        private fun getEncryptionKey(): SecretKey {
            val keyStore = KeyStore.getInstance("AndroidKeyStore")
            keyStore.load(null)
            
            val keySpec = KeyGenParameterSpec.Builder(
                "studyshield_key",
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build()
            
            return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
                .apply { init(keySpec) }
                .generateKey()
        }
    }
}
```

### Sensitive Data Handling

```kotlin
// Secure handling of passwords
class PasswordValidator {
    
    fun isValid(password: String): Boolean {
        val pattern = Regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}$")
        return pattern.containsMatchIn(password)
    }
    
    fun hashPassword(password: String): String {
        return BCrypt.hashpw(password, BCrypt.gensalt(12))
    }
    
    fun verifyPassword(password: String, hash: String): Boolean {
        return BCrypt.checkpw(password, hash)
    }
}

// Clear sensitive data from memory
class SensitiveDataCleanup {
    
    fun clearSensitiveFields() {
        // Clear password
        password?.fill(Char(0))
        password = null
        
        // Clear tokens
        token?.fill(Char(0))
        token = null
    }
}
```

---

## Accessibility Service Security

### Purpose & Risks

**Purpose**:
- Monitor app launches
- Block unauthorized apps
- Detect bypass attempts

**Risks**:
- Access to all text on screen
- Access to UI structure
- Potential privacy concerns

### Implementation with Safeguards

```kotlin
class StudyShieldAccessibilityService : AccessibilityService() {
    
    private val allowedApps = mutableListOf<String>()
    private val blockedApps = mutableListOf<String>()
    
    override fun onServiceConnected() {
        logAudit("Accessibility Service Connected")
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                handleWindowStateChange(event)
            }
            AccessibilityEvent.TYPE_NOTIFICATION_STATE_CHANGED -> {
                handleNotificationStateChange(event)
            }
        }
    }
    
    private fun handleWindowStateChange(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        
        if (isStudySessionActive()) {
            when {
                allowedApps.contains(packageName) -> {
                    // Allow the app
                    logAudit("App Allowed: $packageName")
                }
                blockedApps.contains(packageName) -> {
                    // Block the app
                    blockAppLaunch(packageName)
                    logAudit("App Blocked: $packageName", "SECURITY_EVENT")
                }
            }
        }
    }
    
    private fun blockAppLaunch(packageName: String) {
        val intent = Intent(Settings.ACTION_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
        
        // Record block attempt
        recordBlockAttempt(packageName)
    }
    
    private fun recordBlockAttempt(packageName: String) {
        // Store in database for analytics
        viewModelScope.launch {
            sessionRepository.recordBlockAttempt(
                sessionId = getCurrentSessionId(),
                packageName = packageName,
                timestamp = System.currentTimeMillis()
            )
        }
    }
    
    override fun onInterrupt() {
        // Called when service is interrupted
        logAudit("Accessibility Service Interrupted")
    }
    
    override fun onDestroy() {
        logAudit("Accessibility Service Destroyed")
        super.onDestroy()
    }
}
```

### User Consent Flow

```xml
<!-- accessibility_consent_screen.xml -->
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android">
    <LinearLayout>
        
        <TextView
            android:text="@string/accessibility_permission_title"
            android:textSize="24sp"
            android:textStyle="bold" />
        
        <TextView
            android:text="@string/accessibility_permission_explanation"
            android:textSize="16sp" />
        
        <CardView>
            <LinearLayout
                android:orientation="vertical">
                <TextView
                    android:text="Why we need this permission:"
                    android:textStyle="bold" />
                <TextView
                    android:text="• Block unauthorized app launches\n• Prevent distraction during study sessions\n• Monitor focus and productivity" />
            </LinearLayout>
        </CardView>
        
        <CardView>
            <LinearLayout
                android:orientation="vertical">
                <TextView
                    android:text="What we DON'T do:"
                    android:textStyle="bold" />
                <TextView
                    android:text="• Never collect your personal data\n• Never share data with third parties\n• Never access private messages" />
            </LinearLayout>
        </CardView>
        
        <Button
            android:id="@+id/enable_accessibility"
            android:text="Enable Accessibility Service" />
        
    </LinearLayout>
</ScrollView>
```

---

## Device Admin Security

### Device Admin Implementation

```kotlin
class StudyShieldDeviceAdminReceiver : DeviceAdminReceiver() {
    
    override fun onEnabled(context: Context, intent: Intent) {
        logAudit("Device Admin Enabled", "SECURITY_EVENT")
    }
    
    override fun onDisabled(context: Context, intent: Intent) {
        logAudit("Device Admin Disabled", "SECURITY_EVENT")
    }
    
    override fun onPasswordChanged(context: Context, intent: Intent) {
        logAudit("Device Password Changed", "SECURITY_EVENT")
    }
}

// Managing Device Admin
class DeviceAdminManager @Inject constructor(
    private val context: Context
) {
    
    private val devicePolicyManager = context.getSystemService(DeviceAdminManager)
    private val adminComponent = ComponentName(context, StudyShieldDeviceAdminReceiver::class.java)
    
    fun requestDeviceAdmin() {
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
        intent.putExtra(
            DevicePolicyManager.EXTRA_ADD_EXPLANATION,
            "Enable device management for study session enforcement"
        )
        context.startActivity(intent)
    }
    
    fun isDeviceAdminEnabled(): Boolean {
        return devicePolicyManager.isAdminActive(adminComponent)
    }
    
    fun lockDevice() {
        if (isDeviceAdminEnabled()) {
            devicePolicyManager.lockNow()
            logAudit("Device Locked", "SECURITY_EVENT")
        }
    }
}
```

### Limited Capabilities

StudyShield uses Device Admin ONLY for:
- Locking device (if session compromised)
- NOT for password changes
- NOT for factory reset
- NOT for camera/microphone control

---

## Privacy Architecture

### Privacy-First Design Principles

1. **Data Minimization**: Collect only necessary data
2. **Purpose Limitation**: Use data only for stated purposes
3. **User Control**: Users can delete/export their data
4. **Transparency**: Clear privacy policies
5. **Security**: Encrypt all sensitive data

### Privacy Settings

```kotlin
class PrivacySettings {
    var analyticsEnabled: Boolean = true
    var crashReportingEnabled: Boolean = true
    var personalizedRecommendations: Boolean = true
    var parentCanViewSessions: Boolean = false
    var dataRetentionMonths: Int = 12
    
    fun deleteAllPersonalData() {
        // GDPR Right to be Forgotten
        sessionRepository.deleteAllUserSessions()
        profileRepository.anonymizeProfile()
        analyticsRepository.deleteUserAnalytics()
        logAudit("User Data Deleted", "PRIVACY_EVENT")
    }
    
    fun exportPersonalData(): File {
        // GDPR Right to Data Portability
        val userData = mapOf(
            "profile" to profileRepository.getProfile(),
            "sessions" to sessionRepository.getAllSessions(),
            "stats" to analyticsRepository.getAllStats()
        )
        return exportAsJSON(userData)
    }
}
```

### Compliance Settings Screen

```xml
<PreferenceScreen>
    
    <SwitchPreferenceCompat
        android:key="analytics_enabled"
        android:title="Analytics"
        android:summary="Allow us to collect usage analytics"
        android:defaultValue="true" />
    
    <SwitchPreferenceCompat
        android:key="crash_reporting"
        android:title="Crash Reporting"
        android:summary="Help us improve by reporting crashes"
        android:defaultValue="true" />
    
    <SwitchPreferenceCompat
        android:key="personalized_recommendations"
        android:title="Personalized Recommendations"
        android:summary="Get AI-powered study recommendations"
        android:defaultValue="true" />
    
    <Preference
        android:key="export_data"
        android:title="Export My Data"
        android:summary="Download your data in JSON format" />
    
    <Preference
        android:key="delete_data"
        android:title="Delete My Data"
        android:summary="Permanently delete all your data (GDPR compliant)" />
    
</PreferenceScreen>
```

---

## Compliance

### GDPR Compliance

- [x] Right to Access
- [x] Right to Rectification
- [x] Right to Erasure ("Right to be Forgotten")
- [x] Right to Data Portability
- [x] Right to Restrict Processing
- [x] Privacy by Design
- [x] Data Protection Impact Assessment

### CCPA Compliance (California)

- [x] Disclose data collection
- [x] Allow data deletion
- [x] Allow opt-out of sale
- [x] Non-discrimination for privacy choices

### Child Safety (COPPA)

- [x] Parental consent for users <13
- [x] Limited data collection for minors
- [x] No targeted advertising to minors
- [x] Parental controls

### India (India Data Protection Act)

- [x] Lawful basis for processing
- [x] Data localization (store data in India)
- [x] Sensitive data protection
- [x] Right to correction and erasure

---

## Security Best Practices

### Input Validation

```kotlin
class InputValidator {
    
    fun validateEmail(email: String): Boolean {
        return email.matches(Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$"))
    }
    
    fun validatePassword(password: String): Boolean {
        // At least 8 chars, uppercase, lowercase, digit, special char
        return password.matches(
            Regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}$")
        )
    }
    
    fun sanitizeInput(input: String): String {
        // Remove potentially malicious characters
        return input.replace(Regex("[^a-zA-Z0-9._-]"), "")
    }
}
```

### Rate Limiting

```kotlin
class RateLimitInterceptor : Interceptor {
    
    private val requestTimes = mutableListOf<Long>()
    private val maxRequests = 100
    private val timeWindowMs = 60000 // 1 minute
    
    override fun intercept(chain: Interceptor.Chain): Response {
        val now = System.currentTimeMillis()
        
        // Remove old requests outside time window
        requestTimes.removeAll { now - it > timeWindowMs }
        
        // Check if rate limit exceeded
        if (requestTimes.size >= maxRequests) {
            return Response.Builder()
                .code(429)
                .message("Too Many Requests")
                .build()
        }
        
        requestTimes.add(now)
        return chain.proceed(chain.request())
    }
}
```

### Secure Logging

```kotlin
class SecureLogger {
    
    fun logSecurityEvent(event: String, severity: String = "INFO") {
        // Never log sensitive information
        val sanitized = event
            .replace(Regex("password[=:][^,}\\s]+"), "password=***")
            .replace(Regex("token[=:][^,}\\s]+"), "token=***")
        
        Log.d("SecurityEvent", "[$severity] $sanitized")
        
        // Send to server for audit trail
        sendToAuditLog(sanitized, severity)
    }
}
```

### Anti-Tampering

```kotlin
class TamperDetection {
    
    fun detectRooting(): Boolean {
        return checkForSuBinary() ||
               checkForCommonRootingPaths() ||
               checkForSignatureValidation()
    }
    
    private fun checkForSignatureValidation(): Boolean {
        val sig = context.packageManager.getPackageInfo(
            context.packageName,
            PackageManager.GET_SIGNATURES
        ).signatures
        
        // Verify signature matches Google Play
        return !isValidGooglePlaySignature(sig)
    }
}
```

---

## Security Audit Trail

All security-related events are logged:

```kotlin
data class AuditLog(
    val id: String,
    val userId: String,
    val event: String,
    val severity: String, // INFO, WARNING, CRITICAL
    val timestamp: Long,
    val ipAddress: String?,
    val deviceInfo: String,
    val details: String
)

// Audit events
sealed class AuditEvent {
    object LOGIN : AuditEvent()
    object LOGOUT : AuditEvent()
    object TOKEN_REFRESH : AuditEvent()
    object PERMISSION_GRANTED : AuditEvent()
    object PERMISSION_DENIED : AuditEvent()
    object APP_BLOCKED : AuditEvent()
    object BYPASS_ATTEMPTED : AuditEvent()
    object DEVICE_ADMIN_ENABLED : AuditEvent()
    object DEVICE_ADMIN_DISABLED : AuditEvent()
    object DATA_EXPORT : AuditEvent()
    object DATA_DELETED : AuditEvent()
}
```

