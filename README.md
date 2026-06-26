<div align="center">

<img src="assets/images/avatar.png" alt="MediTrack Logo" width="100" height="100" style="border-radius: 20px"/>

# 🏥 MediTrack

### AI-Powered Personal Health Companion for Every Indian Family

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![OpenRouter AI](https://img.shields.io/badge/OpenRouter-AI%20Powered-7F56D9?style=for-the-badge&logo=openai&logoColor=white)](https://openrouter.ai)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)](https://flutter.dev)

**Hackathon Project — Built to solve real healthcare problems for elderly Indians**

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack) • [Setup](#-setup) • [Architecture](#-architecture)

</div>

---

## 🎯 Problem Statement

India has over **140 million elderly citizens** aged 60+. Most of them:
- Struggle to track daily medicines and miss doses
- Can't easily communicate health data to family members or doctors
- Have no quick way to share vitals in an emergency
- Face language barriers with English-only health apps

**MediTrack solves all of this** — in Hindi, English, and Hinglish, with voice control, AI assistance, and one-tap SOS.

---

## ✨ Features

### 🎙️ AI Voice Assistant (MediBot)
- Talk to the app in **Hindi, English, or Hinglish** — completely hands-free
- Say _"mera BP 120/80 hai"_ and it auto-saves the vital reading
- Powered by **OpenRouter AI** with full patient context (medicines, vitals, conditions)
- Responds warmly in conversational Hinglish for elderly users
- Real-time speech-to-text with animated sound level feedback

### 💊 Medicine Tracker
- Daily medicine schedule with time-based reminders (morning ☀️ / night 🌙)
- One-tap "Taken / Pending" toggle with animated checkmark
- Add new medicines via modal with time picker, dose, and instructions
- Progress ring on home dashboard showing medicines taken today

### 📊 Vitals Monitoring
- Track **Blood Pressure, Blood Sugar, SpO₂, and Body Temperature**
- Beautiful **Bezier curve charts** with gradient fill (custom Canvas painter)
- Day / Week / Month / Year trend views
- Average calculations shown on every chart
- Voice-input readings instantly reflected on graphs

### 🚨 One-Tap SOS Emergency
- 3-second countdown SOS with cancel option
- Auto-sends SMS to emergency contacts (family + doctor)
- Shares location in the alert message
- Also triggerable via voice: _"emergency"_ or _"mujhe madad chahiye"_

### 🏥 Doctor Appointment Booking
- Browse doctors by specialty (Cardiology, Diabetes, Orthopedic, General)
- Custom vector-drawn doctor avatars (no stock images needed)
- 4-step booking flow: Doctor → Date/Time → Patient Info → Confirm
- Search by name, specialty, or symptom

### � Medical Records
- View and manage health reports, ECG, blood tests, X-rays
- PDF export and share functionality
- Year-wise organization

### 👨‍👩‍👧‍👦 Family Connect
- Add and manage family members with blood group and medicine info
- View health status of each family member
- "Self" badge for the primary account holder

### 📱 Patient QR Card
- Generates a QR code with complete patient medical data
- Shareable for emergency room use — doctors scan and instantly see vitals, conditions, allergies, medicines
- Built-in QR scanner to read other patients' cards

### � Health Report
- One-page health summary with all vitals, HbA1c, cholesterol
- Personalized recommendations (exercise, water, Vitamin D)
- Export as PDF and share

### 💡 Health Tips
- Curated tips across 4 categories: Diabetes, Heart Health, Nutrition, Medicine Management
- 12+ actionable health tips with icons

### � Dark Mode + Accessibility
- Full dark/light theme toggle with smooth transitions
- High Contrast Mode for visually impaired users
- Adjustable text size (Small / Medium / Large)
- Bilingual UI: **English 🇬🇧 and Hindi 🇮🇳** (complete localization)

---


## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.11) |
| **State Management** | Provider (ChangeNotifier) |
| **AI / LLM** | OpenRouter API (gpt-oss-120b:free) |
| **Voice Input** | speech_to_text ^7.0.0 |
| **Text-to-Speech** | flutter_tts ^4.2.2 |
| **QR Generation** | qr_flutter ^4.1.0 |
| **QR Scanning** | mobile_scanner ^6.0.2 |
| **PDF Export** | pdf ^3.11.1 |
| **Fonts** | Google Fonts — Noto Sans Devanagari + Outfit |
| **Localization** | Flutter Gen l10n (English + Hindi ARB files) |
| **Local Storage** | shared_preferences ^2.3.0 |
| **HTTP Client** | http ^1.3.0 |
| **File Sharing** | share_plus ^13.1.0 |
| **Image Picker** | image_picker ^1.1.2 |
| **Charts** | Custom Canvas Painters (Bezier curves + gradients) |
| **Environment** | flutter_dotenv ^5.2.1 |

---

## 🏗️ Architecture

```
lib/
├── config/
│   └── api_config.dart          # OpenRouter API config
├── l10n/
│   ├── app_en.arb               # English strings
│   └── app_hi.arb               # Hindi strings
├── models/
│   └── vital_reading.dart       # VitalReading data model
├── providers/
│   ├── language_provider.dart   # Language switching
│   ├── theme_provider.dart      # Dark/light + contrast + text size
│   ├── vitals_provider.dart     # Vitals state (ChangeNotifier)
│   └── profile_provider.dart    # User profile (SharedPreferences)
├── screens/
│   ├── home_screen.dart         # Dashboard
│   ├── vitals_screen.dart       # Charts + trends
│   ├── vital_detail_screen.dart # Per-vital detail + add reading
│   ├── medicines_screen.dart    # Medicine tracker
│   ├── doctor_appointment_screen.dart  # 4-step booking
│   ├── medical_records_screen.dart     # Records list
│   ├── health_report_screen.dart       # PDF report
│   ├── health_tips_screen.dart         # Tips by category
│   ├── family_screen.dart              # Family members
│   ├── qr_card_screen.dart             # Patient QR
│   ├── scan_qr_screen.dart             # QR scanner
│   ├── profile_screen.dart             # User settings
│   ├── notifications_screen.dart       # Notification center
│   └── patient_qr_detail_screen.dart   # Scanned QR details
├── services/
│   ├── openrouter_service.dart  # AI chat + vital extraction
│   └── pdf_export_service.dart  # Health report PDF generation
├── theme/
│   └── app_theme.dart           # Light + Dark theme definitions
├── utils/
│   └── qr_data.dart             # QR encoding/decoding
└── main.dart                    # App entry + MainShell + Voice AI
```

### Key Design Decisions
- **MainShell** acts as the root state holder — manages medicines, SOS, voice assistant, and notifications globally so all child screens share the same data
- **VitalsProvider** uses ChangeNotifier for reactive UI updates — voice-saved vitals instantly appear on charts
- **OpenRouter AI** is called with full patient context (vitals, medicines, conditions, current time) so responses are medically relevant
- All charts are **custom Canvas painters** — no third-party chart libraries, giving full design control over Bezier curves and gradient fills

---

## ⚙️ Setup

### Prerequisites
- Flutter SDK 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Dart 3.11+
- Android Studio / VS Code
- An OpenRouter API key ([get free key](https://openrouter.ai))

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/kripashankarcs3/MediTrack.git
cd MediTrack

# 2. Install dependencies
flutter pub get

# 3. Create environment file
# Create a .env file in the project root:
echo "OPENROUTER_API_KEY=your_api_key_here" > .env

# 4. Run the app
flutter run
```

### Environment Variables



### Build APK

```bash
flutter build apk --release
```

---

## � Localization

MediTrack is fully bilingual. All UI strings live in:
- `lib/l10n/app_en.arb` — English
- `lib/l10n/app_hi.arb` — Hindi

Users can switch language from **Profile → Language & Display** at runtime — the entire UI rebuilds instantly including voice assistant responses.

To add a new language, add a new `.arb` file and register the locale in `main.dart`.

---

## 🔑 Key Innovations

1. **Conversational Vital Logging** — Users don't fill forms. They just talk. The AI extracts the vital type and value from natural speech in any language.

2. **Context-Aware AI** — MediBot knows the patient's name, age, blood group, current medicines, recent vitals, and today's appointments before answering any question.

3. **Emergency QR Card** — In an unconscious emergency scenario, a first responder just scans the patient's QR code to instantly see all critical medical info.

4. **Zero-Dependency Charts** — Custom Bezier curves drawn with Flutter's Canvas API give smoother, more beautiful charts than any chart library.

5. **Elderly-First UX** — Large text support, high contrast mode, Hindi voice responses, simple navigation — designed for users 60+ years old.

---

## � Team

Built with ❤️ for the Indian healthcare ecosystem.

**Kripashankar Yadav** — Flutter Developer

---

## � License

This project is licensed under the MIT License.

---

<div align="center">

**⭐ Star this repo if MediTrack inspired you!**

*Built for Hackathon — Solving real health problems, one feature at a time.*

</div>
