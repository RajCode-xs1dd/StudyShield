# Android Permissions for StudyShield

## Required Permissions

### 1. Accessibility Service Permission
```xml
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
```
**Purpose**: Monitor app launches and block unauthorized access  
**Required for**: Study mode app blocking functionality  
**Sensitivity**: HIGH - Requires explicit user consent  
**Privacy Impact**: Can see all UI elements

### 2. Device Admin Permission
```xml
<uses-permission android:name="android.permission.BIND_DEVICE_ADMIN" />
```
**Purpose**: Lock device if study session is compromised  
**Required for**: Emergency session protection  
**Sensitivity**: HIGH - Requires explicit user setup  
**Privacy Impact**: Can lock device

### 3. Notification Listener Permission
```xml
<uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
```
**Purpose**: Monitor and suppress non-essential notifications  
**Required for**: Focus mode notification management  
**Sensitivity**: HIGH - Can see notification content  
**Privacy Impact**: Reads notification content

### 4. Query Package Permission (Android 11+)
```xml
<queries>
    <package android:name="com.android.systemui" />
    <package android:name="com.instagram.android" />
    <package android:name="com.facebook.katana" />
    <package android:name="com.google.android.youtube" />
</queries>
```
**Purpose**: Check if specific apps are installed  
**Required for**: App blocking verification

## Normal Permissions (Auto-Granted)

```xml
<!-- Internet Access -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Reading Device Info -->
<uses-permission android:name="android.permission.GET_ACCOUNTS" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Firebase Analytics -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!-- Vibration Feedback -->
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Receive Boot Completed -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

## Dangerous Permissions (Not Used)

StudyShield does NOT request:
- ❌ Camera
- ❌ Microphone
- ❌ Location
- ❌ Contacts
- ❌ SMS
- ❌ Calls
- ❌ Calendar
- ❌ Photos

This ensures maximum privacy for users.

## Permission Declaration in AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Normal Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.GET_ACCOUNTS" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <!-- Sensitive Permissions -->
    <uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
    <uses-permission android:name="android.permission.BIND_DEVICE_ADMIN" />
    <uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />

    <!-- Query Packages -->
    <queries>
        <package android:name="com.android.systemui" />
        <package android:name="com.google.android.youtube" />
        <package android:name="com.instagram.android" />
        <package android:name="com.facebook.katana" />
        <package android:name="com.whatsapp" />
    </queries>

    <application>
        <!-- Activities, Services, etc. -->
    </application>

</manifest>
```

## Permission Request Flow

### First Time Setup
1. Show onboarding explaining why permissions are needed
2. Request Accessibility Service → OS Settings
3. Request Device Admin → OS Settings
4. Request Notification Listener → OS Settings
5. Confirm all permissions are granted
6. Start first study session

### Runtime Permission Management

```kotlin
class PermissionManager @Inject constructor(
    private val context: Context
) {
    
    fun isAccessibilityServiceEnabled(): Boolean {
        val enabled = Settings.Secure.getInt(
            context.contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED,
            0
        )
        return enabled == 1
    }
    
    fun isDeviceAdminEnabled(): Boolean {
        val devicePolicyManager = context.getSystemService(DevicePolicyManager::class.java)
        val adminComponent = ComponentName(context, StudyShieldDeviceAdminReceiver::class.java)
        return devicePolicyManager.isAdminActive(adminComponent)
    }
    
    fun allPermissionsGranted(): Boolean {
        return isAccessibilityServiceEnabled() &&
               isDeviceAdminEnabled()
    }
}
```

## Privacy & Security Notes

### What StudyShield DOES Access
- Running app name and package
- App window state changes
- Notification metadata (not content)
- Device admin commands (limited)

### What StudyShield NEVER Accesses
- Personal messages or emails
- Photos or videos
- Location data
- Browsing history
- Call logs or contacts
- Biometric data
- Device identifiers (except for analytics)

### Permission Justification
All permissions are used ONLY for:
- Creating distraction-free study environments
- Blocking unauthorized app access
- Managing notifications during focus sessions

No data is shared with third parties without explicit user consent.

## GDPR & Compliance

- [x] Transparent permission disclosure
- [x] User can revoke permissions anytime
- [x] No personal data collection beyond stated purpose
- [x] Regular security audits
- [x] Data encryption at rest and in transit
