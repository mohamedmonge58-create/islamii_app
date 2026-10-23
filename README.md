# 🕌 Islamii App

A Flutter application that brings essential Islamic resources and daily worship tools together in one place. Islamii App provides Quran reading and recitation, Hadith, Azkar, daily supplications, prayer times, Adhan scheduling, Qibla direction, and Quran radio through a clean, Arabic-focused interface.

## 📸 Screenshots

Explore **Islamii App** in both Dark Mode and Light Mode.

### 🌙 Dark Mode

#### 🚀 Splash Screen

<p align="center">
  <img src="screenshots/dark%20screens/splash_screen.png" alt="Islamii App Splash Screen" width="250"/>
</p>

#### 📖 Quran & Reciters

<p align="center">
  <img src="screenshots/dark%20screens/المصحف.png" alt="Holy Quran" width="220"/>
  <img src="screenshots/dark%20screens/صفحه%20القراءة.png" alt="Quran Reading" width="220"/>
  <img src="screenshots/dark%20screens/القراء.png" alt="Quran Reciters" width="220"/>
  <img src="screenshots/dark%20screens/audio%20screen.png" alt="Quran Audio Player" width="220"/>
</p>

#### 🤲 Azkar & Daily Supplications

<p align="center">
  <img src="screenshots/dark%20screens/الادعيه%20والاذكار%20اليوميه.png" alt="Daily Azkar and Supplications" width="220"/>
  <img src="screenshots/dark%20screens/الاذكار%20والادعيه.png" alt="Azkar and Duas" width="220"/>
  <img src="screenshots/dark%20screens/اذكار%20الصباح.png" alt="Morning Azkar" width="220"/>
  <img src="screenshots/dark%20screens/اذكار%20المساء.png" alt="Evening Azkar" width="220"/>
  <img src="screenshots/dark%20screens/اذكار%20بعد%20الصلاة.png" alt="After Prayer Azkar" width="220"/>
</p>

#### 📚 Hadith

<p align="center">
  <img src="screenshots/dark%20screens/الاحاديث.png" alt="Hadith Screen" width="220"/>
</p>

#### 🕌 Prayer Times & Adhan

<p align="center">
  <img src="screenshots/dark%20screens/المواقيت.png" alt="Prayer Times" width="220"/>
  <img src="screenshots/dark%20screens/اعدادات%20الاذان.png" alt="Adhan Settings" width="220"/>
</p>

#### 🧭 Qibla Direction

<p align="center">
  <img src="screenshots/dark%20screens/اتجاه%20القبلة.png" alt="Qibla Direction" width="220"/>
</p>

#### 📻 Quran Radio

<p align="center">
  <img src="screenshots/dark%20screens/الاذاعه.png" alt="Quran Radio" width="220"/>
</p>

---

### ☀️ Light Mode

#### 🏠 Home & Prayer Times

<p align="center">
  <img src="screenshots/light%20screens/home%20light.png" alt="Home Light Mode" width="220"/>
  <img src="screenshots/light%20screens/time%20light.png" alt="Prayer Times and Azkar Menu Light Mode" width="220"/>
</p>

#### 📖 Quran & Reciters

<p align="center">
  <img src="screenshots/light%20screens/light%20sura.png" alt="Quran Surah Light Mode" width="220"/>
  <img src="screenshots/light%20screens/reciters%20light.png" alt="Quran Reciters Light Mode" width="220"/>
  <img src="screenshots/light%20screens/audio%20light.png" alt="Audio Player Light Mode" width="220"/>
</p>

#### 🤲 Azkar & Daily Supplications

<p align="center">
  <img src="screenshots/light%20screens/الادعيه%20والاذكار%20اليوميه%20نهاري.png" alt="Daily Azkar and Supplications Light Mode" width="220"/>
  <img src="screenshots/light%20screens/الاذكار%20والادعيه.png" alt="Azkar and Duas Light Mode" width="220"/>
  <img src="screenshots/light%20screens/اذكار%20الصباح%20نهاري.png" alt="Morning Azkar Light Mode" width="220"/>
  <img src="screenshots/light%20screens/اذكار%20المساء%20نهاري.png" alt="Evening Azkar Light Mode" width="220"/>
  <img src="screenshots/light%20screens/اذكار%20بعد%20الصلاة%20نهاري.jpeg" alt="After Prayer Azkar Light Mode" width="220"/>
</p>

#### 📚 Hadith

<p align="center">
  <img src="screenshots/light%20screens/hadith%20light.png" alt="Hadith Light Mode" width="220"/>
</p>

#### 🕌 Prayer Times & Adhan

<p align="center">
  <img src="screenshots/light%20screens/time%20light.png" alt="Prayer Times Light Mode" width="220"/>
  <img src="screenshots/light%20screens/تنبيهات%20نهاري.png" alt="Adhan Notifications Light Mode" width="220"/>
</p>

#### 🧭 Qibla Direction

<p align="center">
  <img src="screenshots/light%20screens/القبلة%20نهاري.png" alt="Qibla Direction Light Mode" width="220"/>
</p>

#### 📻 Quran Radio

<p align="center">
  <img src="screenshots/light%20screens/radio%20light.png" alt="Quran Radio Light Mode" width="220"/>
  <img src="screenshots/light%20screens/radio%20audio%20light.png" alt="Radio Audio Player Light Mode" width="220"/>
</p>



## ✨ Features

### 📖 Quran & Recitation

- Browse Quran-related content through the Mushaf section.
- Access Quran reading and reciters screens.
- Listen to Quran recitations using the available audio features.
- Dedicated audio player interface.

### 📿 Azkar & Daily Supplications

- Morning Azkar.
- Evening Azkar.
- Azkar after obligatory prayers.
- Daily Azkar and supplications.
- Daily Duas.
- Tasbeeh and Istighfar.
- Repetition counts and remembrance notes in the Azkar data.

### 📚 Hadith

- Dedicated Hadith section for Islamic narrations.

### 🕌 Prayer Times & Location

- Fetch prayer times using the Al-Adhan API.
- Detect the user's location using GPS.
- Display the detected location or a default Cairo location when using the fallback.
- Refresh location and prayer times together.
- Display a live countdown to the next prayer.
- Automatically scroll to the active prayer in the prayer list.
- Select a prayer-time calculation method.
- Persist the selected calculation method using SharedPreferences.

### 🔊 Audio & Background Playback

- Quran recitation playback through the available audio implementation.
- Background audio architecture using `audio_service` and `just_audio`.
- Android media notification and lock-screen controls where supported by the implementation and device.
- Quran radio streaming.
- Adhan audio playback integration.
- Native Android Adhan scheduling using `AlarmManager`.
- Native foreground service implementation for full-length Adhan playback.
- Boot receiver implementation for restoring saved prayer alarms after device restart.

> **Note:** Background playback, automatic Adhan scheduling, and restoration after reboot depend on correct configuration, permissions, device restrictions, and physical-device testing. Android force-stop behavior cannot be guaranteed.

### 🧭 Qibla Direction

- Calculate the Qibla direction using the user's geographic coordinates and the coordinates of Makkah.
- Use compass sensor data when available.
- Provide a calculated geographic bearing as a fallback when compass hardware is unavailable.
- Handle location permission denial and missing compass sensors.
- Display a visual indicator when the device is facing within the configured tolerance of the Qibla direction.

### 🎨 User Experience

- Arabic-focused Islamic interface.
- Dark Mode and Light Mode screenshot galleries.
- Prayer countdown and active-prayer navigation.
- Location and prayer-time refresh controls.
- Persistent prayer calculation preferences.

## 🛠️ Built With

- **Flutter** — Cross-platform application development.
- **Dart** — Application programming language.
- **REST API** — Prayer times from the Al-Adhan API.
- **SharedPreferences** — Local persistence for selected settings.
- **geolocator** — Device location access.
- **geocoding** — Converting coordinates into readable location information.
- **audioplayers** — Audio playback.
- **just_audio** — Audio playback implementation.
- **audio_service** — Background audio service support.
- **flutter_local_notifications** — Local notifications and scheduled reminders.
- **timezone** — Time-zone support for scheduling.
- **flutter_qiblah** — Compass and Qibla-related sensor functionality.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- An Android device or emulator

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/mohamedmonge58-create/islamii_app.git
   ```

2. Navigate to the project directory:

   ```bash
   cd islamii_app
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## 📍 Permissions

Depending on the features used, the application may require:

- **Location permissions** to retrieve the device's geographic location for prayer-time calculations and Qibla direction.
- **Notification permission** to display notifications on supported Android versions.
- **Exact-alarm access** for precise prayer-time scheduling where required by Android.
- **Foreground-service permissions** for supported background audio and Adhan playback functionality.

Feature availability depends on granted permissions, Android version, device settings, and manufacturer-specific battery restrictions.

## 👨‍💻 Author

**Mohamed Ibrahim Monge**

- GitHub: [@mohamedmonge58-create](https://github.com/mohamedmonge58-create)

---

Built with Flutter 💙
