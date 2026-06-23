<div align="center">

# ☽ Aya — Islamic Companion App

**A premium, beautifully crafted Islamic app for Quran reading, prayer times, and daily Islamic practice.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-00B4AB?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?logo=android)](https://github.com/Cancelllls/Islamic-App)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

</div>

---

## 🌙 About Aya

**Aya** is a full-featured Islamic companion app built with Flutter. It combines a beautifully designed Quran reader with essential daily Islamic tools — all in one elegant, premium experience.

The UI is inspired by modern design trends: glass-morphism, dark gradients, golden accents, and smooth micro-animations — so users feel spiritually connected *and* visually delighted.

---

## ✨ Features

### 📖 Quran Reader
- **4 reading modes** — Translation, Arabic Only, Tafsir (Al-Muyassar), and Continuous Page
- Full **Arabic text** with Amiri font
- **English & Arabic translations** with language switching
- **Tafsir** overlay per ayah via bottom sheet
- **Bookmark** any ayah and resume where you left off
- **Hizb dividers** for navigation
- Adjustable font size

### 🔊 Audio Recitation
- **Stream full Surahs** from top reciters
- **Ayah-level playback** control
- Auto-scrolls to the currently playing ayah
- Background playback support

### 🕌 Prayer Times
- Precise times based on **GPS location** (updates 10–15 min before each prayer while traveling)
- **Azan notifications** with pre-prayer reminders
- Uses the same **Five-Prayers API** for accuracy
- Displays exact city/neighborhood (not generic area)

### 🧭 Qibla Direction
- Accurate **compass-based Qibla** finder

### 📿 Azkar & Dhikr
- **Morning & Evening Azkar** with Arabic text
- **Tasbih counter** with haptic feedback
- Swipeable card layout

### 📅 Daily Verse
- **Verse of the Day** displayed in full Arabic Quranic script
- Scheduled daily reminder notification

### 🎨 Design
- Stunning **dark & light themes**
- **Glassmorphism** card effects
- Golden (`#E5C158`) accent palette
- Google Fonts (Amiri for Arabic, Inter for UI)
- Smooth page transitions and animations

---

## 📱 Screenshots

> *Coming soon — add to `assets/screenshots/`*

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x / Dart 3 |
| Fonts | Google Fonts (Amiri, Inter) |
| Audio | just_audio |
| Location | geolocator |
| Storage | shared_preferences |
| Notifications | flutter_local_notifications |
| Sensors | flutter_compass |
| HTTP | http |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0
- Android SDK or Xcode (for iOS)

### Clone & Run

```bash
git clone https://github.com/Cancelllls/Islamic-App.git
cd Islamic-App
flutter pub get
flutter run
```

### Build Release APK (Android arm64)

```bash
flutter build apk --release --target-platform=android-arm64
```

The output APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🏗 Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/                    # Data models (Quran, Prayer, etc.)
├── screens/                   # All app screens
│   ├── dashboard_screen.dart
│   ├── quran_screen.dart
│   ├── surah_reader_screen.dart
│   ├── prayer_times_screen.dart
│   ├── qibla_screen.dart
│   ├── azkar_screen.dart
│   └── tasbih_screen.dart
├── services/                  # Business logic & APIs
│   ├── api_service.dart
│   ├── audio_manager.dart
│   ├── notification_service.dart
│   ├── storage_service.dart
│   └── translation_service.dart
├── theme/                     # App theme & color system
└── widgets/                   # Reusable UI components
```

---

## 🤝 Contributing

Pull requests are welcome!

1. Fork the repo
2. Create your branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push the branch: `git push origin feature/your-feature`
5. Open a Pull Request

Please make sure `flutter analyze` passes with no errors before submitting.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with 🤍 for the Muslim community**

*بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ*

</div>
