# StudyShield - AI-Powered Student Focus Android App

**Version**: 0.1.0 (MVP)  
**Status**: 🔄 In Active Development  
**Platform**: Android 8.0+ (API 26+)

## 🎯 Vision

StudyShield creates **distraction-free digital study environments** for students by intelligently blocking distracting apps and content while allowing educational resources.

### The Problem
Students rely on digital devices for learning but face constant distractions:
- YouTube Shorts consuming hours
- Instagram/Facebook notifications
- Gaming apps
- Entertainment streaming
- Uncontrolled app access

### The Solution
StudyShield provides intelligent app blocking, educational content verification, gamification, and analytics to help students focus.

---

## ✨ Core Features

### 1. **Study Mode**
- Start focused study sessions (30min, 1hr, 2hr, custom)
- Real-time countdown timer
- Pause/resume functionality
- Session notes and tracking

### 2. **Smart App Blocking**
- Block social media, games, entertainment apps
- Allow educational apps (user-configured)
- Track all block attempts
- Emergency unlock (limited per day)

### 3. **Educational Content Verification**
- AI-powered YouTube content classification
- YouTube Shorts detection and blocking
- 100+ verified educational channel whitelist
- User can add custom channels

### 4. **Gamification System**
- Study streaks (3-day, 7-day, 30-day)
- Achievement badges
- XP points per session
- Level system (Bronze → Silver → Gold → Platinum)

### 5. **Advanced Analytics**
- Daily, weekly, monthly statistics
- Focus score (0-100)
- Study hours tracking
- Peak productivity time analysis

### 6. **Parent Mode**
- Link student account to parent
- View session history and statistics
- Set restrictions
- Privacy-first design

### 7. **Anti-Cheat Mechanisms**
- Detect app force-stop attempts
- Split-screen detection
- Intent redirection blocking
- Device admin integration

---

## 🛠 Technology Stack

### Frontend
- **Language**: Kotlin
- **UI**: Jetpack Compose
- **Architecture**: MVVM + Clean Architecture
- **State Management**: ViewModel + StateFlow

### Backend & Cloud
- **Auth**: Firebase Authentication
- **Database**: Firestore + Realtime DB
- **Messaging**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

### Key Libraries
- **Database**: Room + SQLCipher (Encryption)
- **DI**: Hilt
- **Networking**: Retrofit + OkHttp
- **ML/AI**: TensorFlow Lite + Firebase ML Kit
- **Testing**: JUnit4, Mockito, Espresso

---

## 📁 Project Structure

```
StudyShield/
├── app/
│   ├── src/main/java/com/studyshield/
│   │   ├── di/                  # Dependency Injection
│   │   ├── data/                # Data Layer (Repository, DAO, Entities)
│   │   ├── domain/              # Domain Layer (Use Cases)
│   │   ├── presentation/        # UI Layer (Screens, ViewModels)
│   │   ├── framework/           # System Services
│   │   ├── util/                # Utilities
│   │   ├── ai/                  # AI/ML Integration
│   │   └── MainActivity.kt
│   └── build.gradle.kts
├── docs/
│   ├── ARCHITECTURE.md
│   ├── API_DESIGN.md
│   ├── SECURITY.md
│   ├── PERMISSIONS.md
│   ├── PRODUCT_REQUIREMENTS.md
│   ├── MVP_ROADMAP.md
│   └── database/schema.sql
├── README.md
└── build.gradle.kts
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** | System architecture, folder structure |
| **[API_DESIGN.md](docs/API_DESIGN.md)** | REST API endpoints specification |
| **[SECURITY.md](docs/SECURITY.md)** | Security, authentication, compliance |
| **[PERMISSIONS.md](docs/PERMISSIONS.md)** | Android permissions & privacy |
| **[PRODUCT_REQUIREMENTS.md](docs/PRODUCT_REQUIREMENTS.md)** | Features, requirements, PRD |
| **[MVP_ROADMAP.md](docs/MVP_ROADMAP.md)** | Development timeline & phases |

---

## 🚀 Quick Start

### Prerequisites
- Android Studio 2023.1+
- Kotlin 1.9+
- JDK 17+
- Firebase project

### Setup

```bash
# Clone repository
git clone https://github.com/RajCode-xs1dd/StudyShield.git
cd StudyShield

# Setup Firebase
# Download google-services.json from Firebase Console
cp ~/path/to/google-services.json app/

# Build project
./gradlew build

# Run on emulator/device
./gradlew installDebug
```

### Initial Setup
1. Enable Accessibility Service in Settings
2. Activate Device Admin in Settings
3. Complete onboarding
4. Start your first study session!

---

## 👨‍💻 Development

### Branching Strategy
```
main → develop → feature/* → Pull Request → Code Review → Merge
```

### Code Style
- Follow Kotlin conventions
- 4-space indentation
- Max line length: 120 chars

### Testing
```bash
# Unit tests
./gradlew test

# UI tests
./gradlew connectedAndroidTest

# Coverage report
./gradlew jacocoTestReport
```

---

## 📅 Roadmap

**Phase 1 (MVP)**: Months 1-3
- Core auth, study sessions, app blocking, stats
- Target: 100-500 beta users

**Phase 2 (Growth)**: Months 4-6  
- Educational content, gamification, parent mode
- Target: 1,000-5,000 users

**Phase 3 (Scale)**: Months 7-12
- AI/ML, global expansion, infrastructure scaling
- Target: 50,000-200,000 users

**Phase 4 (Future)**: Year 2+
- iOS app, web dashboard, study groups
- Target: 1M+ users

---

## 📊 Key Metrics

| Metric | Target (Month 6) |
|--------|-----------------|
| DAU | 10,000 |
| MAU | 50,000 |
| Session Completion | >80% |
| Avg Session Duration | >45 min |
| App Rating | >4.7 stars |

---

## 🔒 Security & Privacy

- ✅ End-to-end encryption
- ✅ GDPR compliant
- ✅ CCPA compliant
- ✅ Child safety (COPPA)
- ✅ No personal data sold
- ✅ Transparent privacy policy

---

## 💡 Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes with tests
3. Submit Pull Request
4. Code review required
5. Merge after approval

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/RajCode-xs1dd/StudyShield/issues)
- **Discussions**: [GitHub Discussions](https://github.com/RajCode-xs1dd/StudyShield/discussions)

---

## 📄 License

Proprietary - StudyShield Inc. All rights reserved.

---

**Last Updated**: June 2026  
**Founder**: Rajesh Patra (@RajCode-xs1dd)
