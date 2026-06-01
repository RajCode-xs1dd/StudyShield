# StudyShield - Complete Architecture Documentation

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Technology Stack](#technology-stack)
3. [Folder Structure](#folder-structure)
4. [Database Design](#database-design)
5. [API Endpoints](#api-endpoints)
6. [Security Architecture](#security-architecture)
7. [Authentication Flow](#authentication-flow)

---

## System Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Android App (StudyShield)                │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────┐ │
│  │  UI Layer        │  │  Domain Layer    │  │  Data      │ │
│  │  (Compose)       │  │  (Use Cases)     │  │  Layer     │ │
│  └──────────────────┘  └──────────────────┘  └────────────┘ │
│         ↓                       ↓                      ↓       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         ViewModel Layer (MVVM State Management)      │   │
│  └──────────────────────────────────────────────────────┘   │
│         ↓                       ↓                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Repository Pattern (Local + Remote Data)           │   │
│  └──────────────────────────────────────────────────────┘   │
│         ↓                       ↓                             │
│  ┌────────────────┐      ┌──────────────────┐              │
│  │  Room Database │      │  Firebase        │              │
│  │  (Local Cache) │      │  (Remote Sync)   │              │
│  └────────────────┘      └──────────────────┘              │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  System Services (Accessibility, Device Admin)       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
         ↓                                           ↓
    ┌──────────────┐                        ┌──────────────┐
    │ Local Device │                        │  Firebase    │
    │ (Apps, OS)   │                        │  Services    │
    └──────────────┘                        └──────────────┘
```

### Layered Architecture (Clean Architecture)

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  - Screens (Composables)                │
│  - ViewModels                           │
│  - UI State Management                  │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│         Domain Layer                    │
│  - Use Cases / Interactors              │
│  - Entities                             │
│  - Repository Interfaces                │
│  - Business Logic                       │
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│         Data Layer                      │
│  - Repository Implementations           │
│  - Local DataSource (Room)              │
│  - Remote DataSource (Firebase)         │
│  - Mappers / Transformers               │
└─────────────────────────────────────────┘
```

---

## Technology Stack

### Frontend
- **Language**: Kotlin
- **UI Framework**: Jetpack Compose
- **Architecture Pattern**: MVVM + Clean Architecture
- **Dependency Injection**: Hilt
- **State Management**: ViewModel + StateFlow

### Local Storage
- **Database**: Room (SQLite)
- **Preferences**: DataStore

### Backend & Cloud Services
- **Backend**: Firebase (Realtime Database + Firestore)
- **Authentication**: Firebase Auth
- **Cloud Messaging**: Firebase Cloud Messaging (FCM)
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

### Libraries & Tools
- **Networking**: Retrofit + OkHttp
- **Image Loading**: Coil
- **JSON Serialization**: Kotlinx Serialization / Gson
- **Coroutines**: Kotlin Coroutines + Flow
- **Testing**: JUnit4, Mockito, Espresso
- **Build System**: Gradle with Kotlin DSL
- **Version Control**: Git

### AI/ML Integration
- **On-Device ML**: TensorFlow Lite (for video classification)
- **Cloud ML**: Firebase ML Kit
- **NLP**: BERT-based text classification

---

## Folder Structure

```
StudyShield/
├── app/
│   ├── build.gradle.kts
│   ├── proguard-rules.pro
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── java/com/studyshield/
│       │   │   ├── di/                           # Dependency Injection (Hilt modules)
│       │   │   │   ├── AppModule.kt
│       │   │   │   ├── DatabaseModule.kt
│       │   │   │   ├── FirebaseModule.kt
│       │   │   │   ├── NetworkModule.kt
│       │   │   │   └── RepositoryModule.kt
│       │   │   │
│       │   │   ├── data/                         # Data Layer
│       │   │   │   ├── datasource/
│       │   │   │   │   ├── local/
│       │   │   │   │   │   ├── StudySessionDao.kt
│       │   │   │   │   │   ├── AppManagementDao.kt
│       │   │   │   │   │   ├── ChannelDao.kt
│       │   │   │   │   │   └── StatisticsDao.kt
│       │   │   │   │   └── remote/
│       │   │   │   │       ├── FirebaseStudentService.kt
│       │   │   │   │       ├── FirebaseSessionService.kt
│       │   │   │   │       └── FirebaseAnalyticsService.kt
│       │   │   │   ├── database/
│       │   │   │   │   ├── StudyShieldDatabase.kt
│       │   │   │   │   └── entities/
│       │   │   │   │       ├── StudentEntity.kt
│       │   │   │   │       ├── StudySessionEntity.kt
│       │   │   │   │       ├── AllowedAppEntity.kt
│       │   │   │   │       ├── BlockedAppEntity.kt
│       │   │   │   │       ├── EducationalChannelEntity.kt
│       │   │   │   │       ├── DailyStatsEntity.kt
│       │   │   │   │       └── AchievementEntity.kt
│       │   │   │   ├── mapper/
│       │   │   │   │   ├── StudentMapper.kt
│       │   │   │   │   ├── SessionMapper.kt
│       │   │   │   │   ├── AppMapper.kt
│       │   │   │   │   └── StatsMapper.kt
│       │   │   │   └── repository/
│       │   │   │       ├── StudentRepository.kt
│       │   │   │       ├── StudySessionRepository.kt
│       │   │   │       ├── AppManagementRepository.kt
│       │   │   │       ├── ChannelRepository.kt
│       │   │   │       ├── StatisticsRepository.kt
│       │   │   │       ├── AchievementRepository.kt
│       │   │   │       └── AuthRepository.kt
│       │   │   │
│       │   │   ├── domain/                       # Domain Layer
│       │   │   │   ├── entity/
│       │   │   │   │   ├── Student.kt
│       │   │   │   │   ├── StudySession.kt
│       │   │   │   │   ├── AllowedApp.kt
│       │   │   │   │   ├── BlockedApp.kt
│       │   │   │   │   ├── EducationalChannel.kt
│       │   │   │   │   ├── DailyStats.kt
│       │   │   │   │   └── Achievement.kt
│       │   │   │   ├── repository/               # Interface definitions
│       │   │   │   │   ├── IStudentRepository.kt
│       │   │   │   │   ├── ISessionRepository.kt
│       │   │   │   │   ├── IAppRepository.kt
│       │   │   │   │   ├── IChannelRepository.kt
│       │   │   │   │   └── IStatisticsRepository.kt
│       │   │   │   └── usecase/                  # Use Cases / Interactors
│       │   │   │       ├── auth/
│       │   │   │       │   ├── LoginUseCase.kt
│       │   │   │       │   ├── RegisterUseCase.kt
│       │   │   │       │   └── LogoutUseCase.kt
│       │   │   │       ├── session/
│       │   │   │       │   ├── StartSessionUseCase.kt
│       │   │   │       │   ├── EndSessionUseCase.kt
│       │   │   │       │   ├── GetSessionsUseCase.kt
│       │   │   │       │   └── PauseSessionUseCase.kt
│       │   │   │       ├── appmanagement/
│       │   │   │       │   ├── GetAllowedAppsUseCase.kt
│       │   │   │       │   ├── AddAllowedAppUseCase.kt
│       │   │   │       │   ├── GetBlockedAppsUseCase.kt
│       │   │   │       │   └── AddBlockedAppUseCase.kt
│       │   │   │       ├── channel/
│       │   │   │       │   ├── GetChannelsUseCase.kt
│       │   │   │       │   ├── SubscribeChannelUseCase.kt
│       │   │   │       │   └── GetChannelByCategoryUseCase.kt
│       │   │   │       ├── analytics/
│       │   │   │       │   ├── GetDailyStatsUseCase.kt
│       │   │   │       │   ├── GetWeeklyStatsUseCase.kt
│       │   │   │       │   └── CalculateFocusScoreUseCase.kt
│       │   │   │       ├── achievement/
│       │   │   │       │   ├── GetAchievementsUseCase.kt
│       │   │   │       │   └── UnlockAchievementUseCase.kt
│       │   │   │       └── block/
│       │   │   │           ├── BlockAppUseCase.kt
│       │   │   │           └── DetectBlockAttemptUseCase.kt
│       │   │   │
│       │   │   ├── presentation/                 # Presentation Layer
│       │   │   │   ├── ui/
│       │   │   │   │   ├── screens/
│       │   │   │   │   │   ├── splash/
│       │   │   │   │   │   │   ├── SplashScreen.kt
│       │   │   │   │   │   │   └── SplashViewModel.kt
│       │   │   │   │   │   ├── auth/
│       │   │   │   │   │   │   ├── LoginScreen.kt
│       │   │   │   │   │   │   ├── LoginViewModel.kt
│       │   │   │   │   │   │   ├── RegisterScreen.kt
│       │   │   │   │   │   │   └── RegisterViewModel.kt
│       │   │   │   │   │   ├── dashboard/
│       │   │   │   │   │   │   ├── DashboardScreen.kt
│       │   │   │   │   │   │   ├── DashboardViewModel.kt
│       │   │   │   │   │   │   └── components/
│       │   │   │   │   │   │       ├── SessionCard.kt
│       │   │   │   │   │   │       ├── StatisticsWidget.kt
│       │   │   │   │   │   │       └── QuickStatsCard.kt
│       │   │   │   │   │   ├── study/
│       │   │   │   │   │   │   ├── StudySessionScreen.kt
│       │   │   │   │   │   │   ├── StudySessionViewModel.kt
│       │   │   │   │   │   │   ├── SessionTimerScreen.kt
│       │   │   │   │   │   │   └── SessionConfigScreen.kt
│       │   │   │   │   │   ├── appmanagement/
│       │   │   │   │   │   │   ├── AllowedAppsScreen.kt
│       │   │   │   │   │   │   ├── AllowedAppsViewModel.kt
│       │   │   │   │   │   │   ├── BlockedAppsScreen.kt
│       │   │   │   │   │   │   └── BlockedAppsViewModel.kt
│       │   │   │   │   │   ├── channels/
│       │   │   │   │   │   │   ├── ChannelsScreen.kt
│       │   │   │   │   │   │   ├── ChannelsViewModel.kt
│       │   │   │   │   │   │   ├── ChannelDetailScreen.kt
│       │   │   │   │   │   │   └── ChannelCategoryScreen.kt
│       │   │   │   │   │   ├── browser/
│       │   │   │   │   │   │   ├── FocusBrowserScreen.kt
│       │   │   │   │   │   │   ├── BrowserViewModel.kt
│       │   │   │   │   │   │   └── BrowserSettingsScreen.kt
│       │   │   │   │   │   ├── statistics/
│       │   │   │   │   │   │   ├── StatisticsScreen.kt
│       │   │   │   │   │   │   ├── StatisticsViewModel.kt
│       │   │   │   │   │   │   ├── DailyStatsScreen.kt
│       │   │   │   │   │   │   ├── WeeklyStatsScreen.kt
│       │   │   │   │   │   │   └── ChartsScreen.kt
│       │   │   │   │   │   ├── achievements/
│       │   │   │   │   │   │   ├── AchievementsScreen.kt
│       │   │   │   │   │   │   ├── AchievementsViewModel.kt
│       │   │   │   │   │   │   └── BadgeDetailScreen.kt
│       │   │   │   │   │   ├── settings/
│       │   │   │   │   │   │   ├── SettingsScreen.kt
│       │   │   │   │   │   │   ├── SettingsViewModel.kt
│       │   │   │   │   │   │   └── NotificationSettingsScreen.kt
│       │   │   │   │   │   ├── parent/
│       │   │   │   │   │   │   ├── ParentDashboardScreen.kt
│       │   │   │   │   │   │   ├── ParentDashboardViewModel.kt
│       │   │   │   │   │   │   ├── StudentMonitoringScreen.kt
│       │   │   │   │   │   │   └── ParentSettingsScreen.kt
│       │   │   │   │   │   └── emergency/
│       │   │   │   │   │       ├── EmergencyUnlockScreen.kt
│       │   │   │   │   │       └── EmergencyUnlockViewModel.kt
│       │   │   │   │   ├── components/                # Reusable UI components
│       │   │   │   │   │   ├── Button.kt
│       │   │   │   │   │   ├── TextField.kt
│       │   │   │   │   │   ├── TopAppBar.kt
│       │   │   │   │   │   ├── Card.kt
│       │   │   │   │   │   ├── Dialog.kt
│       │   │   │   │   │   ├── Loader.kt
│       │   │   │   │   │   ├── Charts.kt
│       │   │   │   │   │   └── AppListItem.kt
│       │   │   │   │   └── theme/
│       │   │   │   │       ├── Color.kt
│       │   │   │   │       ├── Typography.kt
│       │   │   │   │       ├── Theme.kt
│       │   │   │   │       └── Dimensions.kt
│       │   │   │   ├── viewmodel/
│       │   │   │   │   ├── MainViewModel.kt
│       │   │   │   │   └── base/
│       │   │   │   │       └── BaseViewModel.kt
│       │   │   │   └── navigation/
│       │   │   │       ├── NavGraph.kt
│       │   │   │       ├── Destinations.kt
│       │   │   │       └── NavigationHost.kt
│       │   │   │
│       │   │   ├── framework/                     # System Integration Layer
│       │   │   │   ├── service/
│       │   │   │   │   ├── AccessibilityService.kt
│       │   │   │   │   ├── DeviceAdminReceiver.kt
│       │   │   │   │   ├── NotificationListener.kt
│       │   │   │   │   └── TimerService.kt
│       │   │   │   ├── worker/
│       │   │   │   │   ├── SyncDataWorker.kt
│       │   │   │   │   ├── UpdateStatsWorker.kt
│       │   │   │   │   └── NotificationWorker.kt
│       │   │   │   ├── receiver/
│       │   │   │   │   ├── BootReceiver.kt
│       │   │   │   │   └── NotificationReceiver.kt
│       │   │   │   └── permission/
│       │   │   │       ├── PermissionManager.kt
│       │   │   │       └── PermissionChecker.kt
│       │   │   │
│       │   │   ├── util/                         # Utilities & Helpers
│       │   │   │   ├── Constants.kt
│       │   │   │   ├── DateTimeUtils.kt
│       │   │   │   ├── Logger.kt
│       │   │   │   ├── Extensions.kt
│       │   │   │   ├── Validators.kt
│       │   │   │   ├── AppBlocker.kt
│       │   │   │   ├── FocusScoreCalculator.kt
│       │   │   │   ├── NotificationManager.kt
│       │   │   │   └── EncryptionUtils.kt
│       │   │   │
│       │   │   ├── ai/                          # AI/ML Integration
│       │   │   │   ├── VideoClassifier.kt
│       │   │   │   ├── TextClassifier.kt
│       │   │   │   ├── ShortsDetector.kt
│       │   │   │   └── model/
│       │   │   │       ├── ClassificationModel.kt
│       │   │   │       └── ModelLoader.kt
│       │   │   │
│       │   │   └── MainActivity.kt
│       │   │
│       │   └── res/
│       │       ├── drawable/
│       │       ├── values/
│       │       │   ├── colors.xml
│       │       │   ├── strings.xml
│       │       │   ├── dimens.xml
│       │       │   └── styles.xml
│       │       └── mipmap/
│       │
│       ├── test/
│       │   └── java/com/studyshield/
│       │       ├── data/
│       │       ├── domain/
│       │       └── presentation/
│       │
│       └── androidTest/
│           └── java/com/studyshield/
│
├── build-logic/                            # Gradle plugins
│   └── convention/
│
├── gradle/
│   └── wrapper/
│
├── docs/
│   ├── ARCHITECTURE.md                    # This file
│   ├── API_DESIGN.md
│   ├── SECURITY.md
│   ├── database/
│   │   └── schema.sql
│   ├── wireframes/
│   ├── user-flows/
│   └── product/
│       ├── PRD.md
│       ├── MVP_ROADMAP.md
│       └── MONETIZATION.md
│
├── gradle.properties
├── settings.gradle.kts
├── build.gradle.kts
└── README.md
```

---

## Database Design

### Entity Relationship Diagram (ERD)

```
Student ──┬── StudySession ──┬── BlockAttempt
          │                  ├── EmergencyUnlock
          │                  └── SessionSettings
          │
          ├── AllowedApp
          ├── BlockedApp
          │
          ├── EducationalChannel (many-to-many via StudentChannel)
          ├── StudentChannel
          │
          ├── DailyStats
          ├── WeeklyStats
          ├── MonthlyStats
          │
          ├── Achievement
          ├── StudyStreak
          │
          ├── BrowsingHistory
          ├── WhitelistDomain
          ├── BlacklistDomain
          │
          ├── UserPreferences
          └── ParentSettings (many-to-many)
```

### Key Tables Summary

| Table | Purpose | Key Columns |
|-------|---------|------------|
| `students` | User profile & data | id, email, xp_points, level, current_streak |
| `study_sessions` | Study session tracking | id, student_id, duration, focus_score, completed |
| `allowed_apps` | Allowed apps during study | student_id, package_name, category |
| `blocked_apps` | Blocked apps during study | student_id, package_name, category |
| `educational_channels` | YouTube channels whitelist | channel_id, channel_name, category, ai_verified |
| `daily_stats` | Daily analytics | student_id, date, study_hours, focus_score |
| `achievements` | Badges & rewards | student_id, badge_id, is_unlocked, unlocked_date |

---

## API Endpoints

### Authentication Endpoints

```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/logout
POST /api/v1/auth/refresh-token
GET  /api/v1/auth/verify-email
POST /api/v1/auth/password-reset
```

### Student Profile Endpoints

```
GET    /api/v1/students/profile
PUT    /api/v1/students/profile
GET    /api/v1/students/{id}/stats
GET    /api/v1/students/{id}/achievements
POST   /api/v1/students/{id}/avatar
```

### Study Session Endpoints

```
POST   /api/v1/sessions/start
POST   /api/v1/sessions/{id}/end
GET    /api/v1/sessions/current
GET    /api/v1/sessions?from=DATE&to=DATE
POST   /api/v1/sessions/{id}/pause
POST   /api/v1/sessions/{id}/resume
POST   /api/v1/sessions/{id}/emergency-unlock
```

### App Management Endpoints

```
GET    /api/v1/apps/installed
POST   /api/v1/apps/allowed
GET    /api/v1/apps/allowed
DELETE /api/v1/apps/allowed/{id}

POST   /api/v1/apps/blocked
GET    /api/v1/apps/blocked
DELETE /api/v1/apps/blocked/{id}
```

### Educational Channels Endpoints

```
GET    /api/v1/channels
GET    /api/v1/channels/{id}
GET    /api/v1/channels?category=PROGRAMMING
POST   /api/v1/channels/subscribe
GET    /api/v1/channels/subscribed
GET    /api/v1/channels/search?q=query
```

### Analytics Endpoints

```
GET    /api/v1/analytics/daily?date=DATE
GET    /api/v1/analytics/weekly?week=WEEK
GET    /api/v1/analytics/monthly?month=MONTH
GET    /api/v1/analytics/summary
GET    /api/v1/analytics/focus-score
GET    /api/v1/analytics/blocked-attempts
```

### Achievements Endpoints

```
GET    /api/v1/achievements
GET    /api/v1/achievements/{id}
GET    /api/v1/achievements/unlocked
GET    /api/v1/achievements/progress
```

### Parent Mode Endpoints

```
POST   /api/v1/parent/link-student
GET    /api/v1/parent/students
GET    /api/v1/parent/student/{id}/sessions
GET    /api/v1/parent/student/{id}/stats
PUT    /api/v1/parent/settings
```

---

## Security Architecture

### Accessibility Service Usage

**Purpose**: Monitor app launches and block unauthorized access

**Implementation**:
```kotlin
class StudyShieldAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Detect app launches and block if necessary
        // Monitor notifications
        // Track app usage
    }
}
```

### Device Admin Usage

**Purpose**: Enforce device-level restrictions

**Capabilities**:
- Lock/unlock device
- Reset password
- Clear data
- Disable camera/microphone

### Data Encryption

- **Local**: SQLite encryption using SQLCipher
- **Transit**: TLS 1.3 for all API calls
- **Sensitive Data**: AES-256 for user credentials

### Privacy-First Architecture

- Minimal data collection
- User consent flows
- GDPR compliance
- Transparent data sharing
- Local-first processing

---

## Authentication Flow

### Login/Registration Flow

```
┌─────────────────┐
│  User Opens App │
└────────┬────────┘
         │
         ↓
    ┌────────────────┐
    │ Check Auth     │
    │ Token          │
    └────┬─────┬────┘
         │     │
      Valid   Invalid
         │     │
         ↓     ↓
    [Dashboard] [Login Screen]
                  │
         ┌────────┴────────┐
         │                 │
      Login or        SignUp
      Register
         │                 │
         ↓                 ↓
    Enter Credentials  Enter Details
         │                 │
         ↓                 ↓
    Firebase Auth     Firebase Auth
    VerifyIdToken     Create User
         │                 │
         ↓                 ↓
    Generate JWT      Generate JWT
         │                 │
         ↓                 ↓
    Save Token        Create Profile
    (Encrypted)       in Firestore
         │                 │
         ↓                 ↓
    Navigate to      Navigate to
    Dashboard        Onboarding
```

---

## Technology Decisions

### Why Kotlin + Compose?
- Modern, concise syntax
- Null safety
- Compose for reactive UI
- Easy state management
- Strong IDE support

### Why Room + Firebase?
- Room: Local-first, offline support
- Firebase: Real-time sync, scalability, managed backend

### Why Clean Architecture + MVVM?
- Separation of concerns
- Testable components
- Maintainable codebase
- Scalable architecture

### Why Jetpack Components?
- Recommended by Google
- Lifecycle-aware
- Built-in testing support
- Community support

---

## Deployment Architecture

### Android App Deployment

```
Local Development
    ↓
GitHub (Source Control)
    ↓
CI/CD Pipeline (GitHub Actions)
    ↓
Build & Test
    ↓
Google Play Console
    ↓
Production Release
```

### Firebase Deployment

```
Firebase Console
    ↓
├── Authentication Setup
├── Firestore Database
├── Real-time Database
├── Cloud Functions
└── Analytics Configuration
```

---

## Performance Considerations

### Database Optimization
- Indexed queries
- Pagination for large datasets
- Caching mechanisms
- Room pre-population

### Network Optimization
- Request batching
- Compression
- Offline-first strategy
- Incremental sync

### UI Performance
- Lazy loading
- Image optimization
- Compose recomposition optimization
- ViewModel state caching

---

## Monitoring & Analytics

### What We Track
- User engagement
- Session metrics
- Error rates
- Crash analytics
- Feature usage

### Privacy Compliance
- GDPR compliant
- User consent before tracking
- Data anonymization
- Opt-out options

