# 🕌 Islamii App

A Flutter application that brings essential Islamic resources and daily worship tools together in one place, with a clean interface designed to support Muslims in their daily routines.

## 📱 Screenshots

Screenshots are grouped by the app sections. Images are displayed at a smaller size to keep the README easy to browse.

### 🚀 Splash Screen

<p align="center">
  <img src="screenshots/splash_screen.png" alt="Splash Screen" width="180">
</p>

### 📖 Quran

<p align="center">
  <img src="screenshots/المصحف.png" alt="Quran Mushaf" width="180">
  <img src="screenshots/صفحه%20القراءة.png" alt="Quran Reading" width="180">
  <img src="screenshots/القراء.png" alt="Quran Reciters" width="180">
</p>

### 📿 Azkar & Duas

<p align="center">
  <img src="screenshots/الادعيه%20والاذكار%20اليوميه.png" alt="Daily Azkar and Duas" width="180">
  <img src="screenshots/الاذكار%20والادعيه.png" alt="Azkar and Duas" width="180">
  <img src="screenshots/اذكار%20الصباح.png" alt="Morning Azkar" width="180">
  <img src="screenshots/اذكار%20المساء.png" alt="Evening Azkar" width="180">
  <img src="screenshots/اذكار%20بعد%20الصلاة.png" alt="Azkar After Prayer" width="180">
</p>

### 📚 Hadith

<p align="center">
  <img src="screenshots/الاحاديث.png" alt="Hadith" width="180">
</p>

### 🕌 Prayer Times & Adhan

<p align="center">
  <img src="screenshots/المواقيت.png" alt="Prayer Times" width="180">
  <img src="screenshots/اعدادات%20الاذان.png" alt="Adhan Settings" width="180">
</p>

### 🧭 Qibla

<p align="center">
  <img src="screenshots/القبله.jpeg" alt="Qibla Direction" width="180">
</p>

### 📻 Radio

<p align="center">
  <img src="screenshots/الاذاعه.png" alt="Radio" width="180">
</p>

## ✨ Features

### 📖 Quran & Recitation
- Browse Quran-related content through the Mushaf section.
- Access Quran reading and reciters screens.
- Listen to Quran recitations through the available audio features.

### 📿 Azkar & Duas
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
- Refresh the location and prayer times together.
- Display a live countdown to the next prayer.
- Automatically scroll to the active prayer in the prayer list.
- Select a prayer-time calculation method.
- Save the selected calculation method using SharedPreferences.

### 🔊 Audio
- Audio playback support using the `audioplayers` package.
- Quran radio streaming through the available radio feature.
- Adhan audio player integration in the prayer-times interface.

> Note: Automatic Adhan playback in the background, after app termination, or after device restart should only be claimed after verifying the actual scheduling and background-execution implementation.

### 🧭 Qibla Direction
- Calculate the direction of the Qibla using the user's geographic coordinates and the coordinates of Makkah.
- Use compass sensor data when available.
- Provide a calculated geographic bearing as a fallback when compass hardware is unavailable.
- Handle location permission denial and missing compass sensors.
- Display a visual indicator when the device is facing within the configured tolerance of the Qibla direction.

### 🎨 User Experience
- Arabic-focused Islamic interface.
- Prayer countdown and active-prayer navigation.
- Location and prayer-time refresh controls.
- Persistent prayer calculation preferences.

## 🛠️ Built With

- **Flutter** — Cross-platform application development.
- **Dart** — Application programming language.
- **REST API** — Prayer times from the Al-Adhan API.
- **Provider / Flutter state management** — Used where implemented in the project.
- **SharedPreferences** — Local persistence for selected settings.
- **geolocator** — Device location access.
- **geocoding** — Converting coordinates into readable location information.
- **audioplayers** — Audio playback.
- **flutter_qiblah** — Compass and Qibla-related sensor functionality.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code

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

4. Generate any required files if the project configuration requires it:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Run the application:

   ```bash
   flutter run
   ```

## 📍 Permissions

The application uses Android location permissions to retrieve the device's geographic location for prayer-time calculations and Qibla direction.

Location features depend on device settings, granted permissions, and available hardware sensors.

## 👨‍💻 Author

**Mohamed Ibrahim Monge**

- GitHub: [@mohamedmonge58-create](https://github.com/mohamedmonge58-create)

---

Built with Flutter 💙
