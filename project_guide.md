# MediTrack: Interview & Hackathon Preparation Guide

Aapki presentation aur interview ke liye ye ek complete **Cheat-Sheet** hai. Ise dhyan se padh lijiye, aapko project ke baare me sab kuch samajh aa jayega.

---

## 1. Elevator Pitch (App ko 1 minute me kaise introduce karein)
> *"MediTrack ek elder-friendly, accessibility-focused health tracking companion app hai. Ise humne elderly (buzurg) logo aur unke family members ke liye design kiya hai. Isme user apne health vitals (BP, Sugar, Oxygen, Temperature) ko voice commands ke through record kar sakte hain, doctor appointments aur medicines manage kar sakte hain, aur Emergency me single tap par SOS alerts bhej sakte hain. Ye app completely offline-first kaam karti hai aur isme AI integration hai jo user ke health data ke hisab se guide karta hai."*

---

## 2. Core Features (Kya-Kya Features hain aur kaise chalte hain?)

Aapko in features ke baare me pata hona chahiye:

### A. Voice Assistant & AI Integration (MediBot)
* **Feature:** User bolkar (Hindi/English/Hinglish me) apna BP ya Sugar record kar sakta hai. Jaise: *"Mera BP 120/80 hai"*. App automatic parse karke vitals database me add kar degi. Iske alawa ek chatbot hai jisse user apna health status pooch sakta hai.
* **Tech behind it:** 
  * Speech-to-Text (`speech_to_text` package) user ki aawaz ko text me convert karta hai.
  * Ye text **OpenRouter API** (Llama 3.2 Model) ko jata hai jo text se numerical data extract karta hai ya chatbot ka reply generate karta hai.
  * Text-to-Speech (`flutter_tts`) AI ke response ko wapas bolkar sunata hai.

### B. Accessibility & Elder-Friendly Design
* **Feature:** Buzurg logo ko dekhne me dikkat hoti hai, isliye app me:
  * **Text Scaling:** User app ke text ka size bada ya chhota kar sakta hai.
  * **High Contrast Mode:** Visual clarity badhane ke liye.
  * **Dual Theme:** Light aur Dark mode support.
* **Tech behind it:** `ThemeProvider` aur `LanguageProvider` state ko manage karte hain aur user ki preferences ko `SharedPreferences` me save rakhte hain.

### C. SOS Emergency System
* **Feature:** Agar patient ko koi emergency ho, toh home screen par **SOS** button dabane par 3-second ka countdown chalu hota hai aur emergency contacts ko alert/SMS chala jata hai.
* **Tech behind it:** `url_launcher` package ka use karke predefined emergency numbers par call/SMS trigger kiya jata hai.

### D. QR Medical Card
* **Feature:** Har user ka ek unique QR Code generate hota hai jisme unki medical profile (Name, Blood Group, Age, Emergency Contact) hoti hai. Koi bhi doctor ya family member ise scan karke turant patient ki details dekh sakta hai.
* **Tech behind it:** `qr_flutter` (QR generate karne ke liye) aur `mobile_scanner` (QR scan karne ke liye).

### E. Health Report & PDF Export
* **Feature:** User apne pure mahine ka health data (Vitals, Medicines) ka ek PDF report generate karke doctor ke sath share kar sakta hai.
* **Tech behind it:** `pdf` aur `share_plus` packages ka use karke PDF device par generate hoti hai aur share hoti hai.

### F. Doctor Appointments & Medicine Reminders
* **Feature:** Medicine scheduling aur doctor appointments ko track karne ke liye dedicated screens hain.

---

## 3. Tech Stack (Technical Specifications)

Agar interviewer pooche ki **"Isme kya use kiya hai?"**, toh ye bataiye:

| Layer | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | **Flutter (Dart)** | Cross-platform mobile app development ke liye. |
| **State Management** | **Provider** | App ke data aur UI state ko sync rakhne ke liye. |
| **Local Database** | **SharedPreferences** | User profile, settings aur vitals offline save karne ke liye. |
| **AI Cloud Integration** | **OpenRouter API (Llama 3.2)** | Speech-to-vitals parsing aur MediBot Chatbot ke liye. |
| **Speech Services** | **SpeechToText** & **FlutterTTS** | Voice commands aur voice feedback ke liye. |
| **QR System** | **qr_flutter** & **mobile_scanner** | Medical profile share aur scan karne ke liye. |
| **Utilities** | **pdf**, **share_plus**, **url_launcher** | Report generation, sharing aur SOS calling ke liye. |

---

## 4. Architecture & File Structure

Humne **Feature-First / Clean Architecture** ki tarah code ko structure kiya hai:
1. **`lib/main.dart`**: App ka entry point jahan Providers initialize hote hain aur localization setup hoti hai.
2. **`lib/screens/`**: Saare UI screens (e.g., [home_screen.dart](file:///c:/Users/kripa/Desktop/MediTrack/lib/screens/home_screen.dart), [vitals_screen.dart](file:///c:/Users/kripa/Desktop/MediTrack/lib/screens/vitals_screen.dart)).
3. **`lib/providers/`**: State management classes jo data logic handle karti hain (e.g., [profile_provider.dart](file:///c:/Users/kripa/Desktop/MediTrack/lib/providers/profile_provider.dart)).
4. **`lib/services/`**: External API call aur helper services (e.g., [openrouter_service.dart](file:///c:/Users/kripa/Desktop/MediTrack/lib/services/openrouter_service.dart), [pdf_export_service.dart](file:///c:/Users/kripa/Desktop/MediTrack/lib/services/pdf_export_service.dart)).
5. **`lib/l10n/`**: Localization files (Hindi aur English translations).

---

## 5. Top 5 Expected Interview / Hackathon Questions & Answers

### Q1. Apne local storage ke liye SharedPreferences hi kyun choose kiya, SQLite ya Hive kyun nahi?
* **Answer:** *"SharedPreferences lightweight aur simple key-value pair storage ke liye perfect hai. Kyunki humara data structured tabular format me bohot bada nahi tha (sirf profile settings, user preferences aur last vitals save karne the), isliye SharedPreferences se app fast load hoti hai aur boilerplate code kam ho jata hai. Future me agar hume bohot bade medical records save karenge, toh hum SQLite ya Hive par migrate kar sakte hain."*

### Q2. Aapka AI backend kaise kaam karta hai aur iski accuracy kaisi hai?
* **Answer:** *"Humne **OpenRouter API** ke through lightweight LLMs (jaise Llama 3.2 3B Instruct) ka use kiya hai. Humne strict system prompts likhe hain jo response ko sirf JSON format me limit karte hain. Isse parsing errors zero ho jaate hain. Speech-to-Text se jo text milta hai, use AI model parse karke numeric value aur vital type (jaise BP, Sugar) return karta hai, jise humara `VitalsProvider` direct save kar leta hai."*

### Q3. Agar internet nahi hai, toh kya ye app kaam karegi?
* **Answer:** *"Haan, ye app **Offline-First** hai. QR code scan/generate karna, PDF reports banana, local vitals save karna, SOS trigger karna, aur medicines/appointments manage karna completely offline chalta hai. Sirf AI Voice Assistant aur Chatbot ke liye internet ki zarurat hoti hai."*

### Q4. Is app ka social impact kya hai? (Hackathon special question)
* **Answer:** *"India me bohot se elderly log akele rehte hain aur unhe smartphone chalane me dikkat hoti hai. MediTrack unki is problem ko door karta hai: unhe type nahi karna padta (voice se kaam ho jata hai), unhe chhhote akshar dekhne nahi padte (text scaling aur high contrast hai), aur emergency me unhe kisi ka number dhoondhna nahi padta (one-tap SOS hai)."*

### Q5. Agar aapko is project ko aage scale karna ho, toh kya features add karenge?
* **Answer:**
  1. *"Hum local machine learning models (jaise TensorFlow Lite) integrate karenge taaki voice parsing bhi offline ho sake."*
  2. *"Wearable devices (smartwatches) ke sath integration karenge taaki vitals automatic track hote rahein."*
  3. *"Real-time database (jaise Firebase ya Supabase) add karenge taaki family members apne parents ka health status live dekh sakein."*
