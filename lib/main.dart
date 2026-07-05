import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/vitals_provider.dart';
import 'providers/profile_provider.dart';
import 'models/vital_reading.dart';
import 'services/openrouter_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/vitals_screen.dart';
import 'screens/medicines_screen.dart';
import 'screens/vital_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/doctor_appointment_screen.dart';
import 'screens/medical_records_screen.dart';
import 'screens/family_screen.dart';
import 'screens/health_report_screen.dart';
import 'screens/health_tips_screen.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/instruction_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLocale()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => VitalsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
      ],
      child: const MediTrackApp(),
    ),
  );
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final textScale = context.watch<ThemeProvider>().textScaleFactor;
    final highContrast = context.watch<ThemeProvider>().highContrast;
    return MaterialApp(
      title: 'MediTrack',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      builder: (context, child) {
        var data = MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale));
        child = MediaQuery(data: data, child: child!);
        if (highContrast) {
          child = DefaultTextStyle(
            style: const TextStyle(color: Colors.black),
            child: child,
          );
        }
        return child;
      },
      theme: buildLightTheme().copyWith(
        textTheme: GoogleFonts.notoSansDevanagariTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          titleLarge: GoogleFonts.notoSansDevanagari(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
          bodyMedium: GoogleFonts.notoSansDevanagari(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      darkTheme: buildDarkTheme().copyWith(
        textTheme: GoogleFonts.notoSansDevanagariTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          titleLarge: GoogleFonts.notoSansDevanagari(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
          bodyMedium: GoogleFonts.notoSansDevanagari(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Master Medicines List
  List<Map<String, dynamic>> _medicines = [];

  // SOS Countdown state
  bool _isSosCountdownActive = false;
  int _sosCountdownVal = 3;
  Timer? _sosTimer;
  bool _isSosAlertSent = false;
  // Emergency contacts
  List<Map<String, String>> _emergencyContacts = [];
  int _sosSmsSentCount = 0;

  // Voice overlay state
  bool _isVoiceAssistantActive = false;
  String _assistantState = 'none';
  String _voicePromptText = "";
  String _voiceSubText = "";
  String _voiceTranscript = "";

  // Speech-to-text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _voiceSavedMessage = '';
  double _soundLevel = 0.0;
  int _consecutiveRestarts = 0;

  // Chat + TTS
  final FlutterTts _tts = FlutterTts();
  final List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _tts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
          _voiceSubText = _getLangCode() == 'hi' ? 'सहायक बोल रहा है...' : 'Assistant is speaking...';
        });
      }
    });

    _tts.setCompletionHandler(() {
      if (mounted && _isVoiceAssistantActive && _assistantState != 'closing') {
        setState(() {
          _voiceTranscript = '';
          _voiceSubText = _getLangCode() == 'hi' ? 'आपकी बात सुन रहा हूँ...' : 'Listening to you...';
        });
        _consecutiveRestarts = 0;
        _initAndListen();
      }
    });

    _tts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
    });
  }

  String _getLangCode() => context.read<LanguageProvider>().locale.languageCode;

  String _sanitizeForTts(String text) {
    return text
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'#+\s?'), '')
        .replaceAll(RegExp(r'_+'), '')
        .replaceAll(RegExp(r'~~'), '')
        .replaceAll(RegExp(r'`+'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'>\s?'), '')
        .replaceAll(RegExp(r'-\s'), '')
        .trim();
  }

  Future<void> _safeSpeak(String text) async {
    final code = _getLangCode();
    await _tts.setLanguage(code == 'hi' ? 'hi-IN' : 'en-US');
    await _tts.speak(_sanitizeForTts(text));
  }

  // Notification state
  List<Map<String, dynamic>> _notifications = [];
  bool _dataInitialized = false;

  void _initSampleData() {
    if (_dataInitialized) return;
    _dataInitialized = true;
    final l = AppLocalizations.of(context)!;
    context.read<ProfileProvider>().setDefaults(
      name: l.userName,
      mobile: l.userMobile,
      email: l.userEmail,
      address: l.userAddress,
    );
    _medicines = [
      {'name': l.medMetformin, 'time': '08:00 AM', 'dose': InstructionHelper.dose1PillCode, 'instruction': InstructionHelper.afterBreakfast, 'isTaken': true},
      {'name': l.medTelmisartan, 'time': '01:00 PM', 'dose': InstructionHelper.dose1PillCode, 'instruction': InstructionHelper.afterLunch, 'isTaken': false},
      {'name': l.medVitaminD3, 'time': '08:00 PM', 'dose': InstructionHelper.dose1PillCode, 'instruction': InstructionHelper.afterDinner, 'isTaken': false},
      {'name': l.medAtorvastatin, 'time': '10:00 PM', 'dose': InstructionHelper.dose1PillCode, 'instruction': InstructionHelper.beforeSleep, 'isTaken': false},
    ];
    _emergencyContacts = [
      {'name': l.contactWife, 'phone': l.contactWifePhone},
      {'name': l.contactSon, 'phone': l.contactSonPhone},
      {'name': l.contactDaughter, 'phone': l.contactDaughterPhone},
    ];

    final vitals = context.read<VitalsProvider>();
    if (vitals.readings.isEmpty) {
      final now = DateTime.now();
      final todayTimes = ['08:00 AM', '10:30 AM', '01:30 PM', '04:00 PM', '08:00 PM'];
      final todayBpValues = ['120/80', '122/82', '125/85', '118/78', '121/80'];
      final todaySugarValues = ['98', '110', '105', '95', '108'];
      final todayOxygenValues = ['98%', '97%', '99%', '98%', '97%'];
      final todayTempValues = ['98.4°F', '98.6°F', '98.5°F', '98.2°F', '98.6°F'];

      for (int i = 0; i < todayTimes.length; i++) {
        final parts = todayTimes[i].split(' ');
        final hm = parts[0].split(':');
        int hour = int.parse(hm[0]);
        final minute = int.parse(hm[1]);
        if (parts[1] == 'PM' && hour != 12) hour += 12;
        if (parts[1] == 'AM' && hour == 12) hour = 0;
        final ts = DateTime(now.year, now.month, now.day, hour, minute);
        final ds = '${now.day}/${now.month}/${now.year}';
        vitals.addReading(VitalReading(type: 'bp', value: todayBpValues[i], time: todayTimes[i], date: ds, timestamp: ts));
        vitals.addReading(VitalReading(type: 'sugar', value: todaySugarValues[i], time: todayTimes[i], date: ds, timestamp: ts));
        vitals.addReading(VitalReading(type: 'oxygen', value: todayOxygenValues[i], time: todayTimes[i], date: ds, timestamp: ts));
        vitals.addReading(VitalReading(type: 'temperature', value: todayTempValues[i], time: todayTimes[i], date: ds, timestamp: ts));
      }

      final weekBp = [120.0, 118.0, 124.0, 120.0, 122.0, 119.0];
      final weekSugar = [98.0, 95.0, 105.0, 96.0, 99.0, 94.0];
      final weekOxygen = [98.0, 98.0, 99.0, 98.0, 97.0, 98.0];
      final weekTemp = [98.5, 98.2, 98.8, 98.4, 98.6, 98.3];

      for (int i = 0; i < 6; i++) {
        final dayDiff = 6 - i;
        final targetDate = now.subtract(Duration(days: dayDiff));
        final ds = '${targetDate.day}/${targetDate.month}/${targetDate.year}';
        final ts = DateTime(targetDate.year, targetDate.month, targetDate.day, 12, 0);
        vitals.addReading(VitalReading(type: 'bp', value: '${weekBp[i].toInt()}/80', time: '12:00 PM', date: ds, timestamp: ts));
        vitals.addReading(VitalReading(type: 'sugar', value: weekSugar[i].toInt().toString(), time: '12:00 PM', date: ds, timestamp: ts));
        vitals.addReading(VitalReading(type: 'oxygen', value: '${weekOxygen[i].toInt()}%', time: '12:00 PM', date: ds, timestamp: ts));
        vitals.addReading(VitalReading(type: 'temperature', value: '${weekTemp[i]}°F', time: '12:00 PM', date: ds, timestamp: ts));
      }
    }

    _notifications = [
      {
        'id': '1',
        'icon': Icons.check_circle_rounded,
        'iconColor': const Color(0xFF12B76A),
        'title': l.notifMedTaken,
        'body': l.notifMedTakenBody(l.medMetformin, '8:00'),
        'time': '${l.today}, 8:05 AM',
        'isRead': false,
      },
      {
        'id': '2',
        'icon': Icons.access_alarm_rounded,
        'iconColor': const Color(0xFF7F56D9),
        'title': l.notifMedReminder,
        'body': l.notifMedReminderBody(l.medTelmisartan, '1:00'),
        'time': '${l.today}, 12:30 PM',
        'isRead': false,
      },
      {
        'id': '3',
        'icon': Icons.favorite_rounded,
        'iconColor': const Color(0xFFF43F5E),
        'title': l.notifBpReading('130/85'),
        'body': l.notifBpReadingBody,
        'time': '${l.today}, 10:15 AM',
        'isRead': false,
      },
      {
        'id': '4',
        'icon': Icons.calendar_today_rounded,
        'iconColor': const Color(0xFF2E82FF),
        'title': l.notifAppointment,
        'body': l.notifAppointmentBody(l.recordDocGupta, '10:00'),
        'time': '${l.today}, 9:00 AM',
        'isRead': false,
      },
    ];
  }

  int get _unreadCount => _notifications.where((n) => n['isRead'] == false).length;

  void _markNotificationRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) _notifications[idx]['isRead'] = true;
    });
  }

  void _markAllNotificationsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1D2939)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.of(context)!.notifications,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D2939),
              ),
            ),
            centerTitle: false,
          ),
          body: NotificationsScreen(
            notifications: _notifications,
            onMarkRead: _markNotificationRead,
            onMarkAllRead: _markAllNotificationsRead,
          ),
        ),
      ),
    );
  }

  void _openVoiceAssistant() {
    _chatHistory.clear();
    if (_isListening) {
      _speech.stop();
    }
    _tts.stop();

    final profile = context.read<ProfileProvider>();
    final name = (profile.name.isNotEmpty ? profile.name : AppLocalizations.of(context)!.userName).split(' ')[0];
    final greetingText = _getLangCode() == 'hi'
        ? 'नमस्ते $name, आज आप कैसे हैं? आपकी तबीयत कैसी है?'
        : 'Hello $name, how are you today? How is your health?';

    setState(() {
      _isVoiceAssistantActive = true;
      _assistantState = 'waitingForHealthStatus';
      _voicePromptText = greetingText;
      _voiceSubText = _getLangCode() == 'hi' ? 'आपकी बात सुन रहा हूँ...' : 'Listening to you...';
      _voiceTranscript = '';
      _voiceSavedMessage = '';
      _soundLevel = 0.0;
      _consecutiveRestarts = 0;
      _chatHistory.add({'role': 'ai', 'text': greetingText});
    });

    _speakAndListen(greetingText, 'waitingForHealthStatus');
  }

  Future<void> _speakAndListen(String text, String nextState) async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
        });
      }
    }

    if (mounted && _isVoiceAssistantActive) {
      setState(() {
        _assistantState = nextState;
        _voiceSubText = _getLangCode() == 'hi'
            ? 'सहायक बोल रहा है...'
            : 'Assistant is speaking...';
      });
    }

    _safeSpeak(text);
  }

  bool _isRestarting = false;

  void _restartListening() {
    if (!mounted || !_isVoiceAssistantActive || _isRestarting) return;
    
    if (_speech.isListening) {
      setState(() {
        _isListening = true;
      });
      return;
    }

    if (_consecutiveRestarts >= 3) {
      debugPrint("Max consecutive restarts reached. Stopping auto-restart.");
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
        _voiceSubText = _getLangCode() == 'hi' ? 'बोलने के लिए माइक दबाएं' : 'Tap mic to speak';
      });
      return;
    }

    _isRestarting = true;
    _consecutiveRestarts++;
    
    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
    });

    _speech.stop().then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        _isRestarting = false;
        if (mounted && _isVoiceAssistantActive && !_speech.isListening) {
          _startListening();
        }
      });
    });
  }

  Future<void> _initAndListen() async {
    if (!_speechAvailable) {
      setState(() {
        _voiceSubText = 'Requesting microphone permission...';
      });
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' && _isListening && mounted) {
            if (_voiceTranscript.trim().isNotEmpty) {
              _stopListeningAndProcess();
            } else {
              if (_isVoiceAssistantActive) {
                _restartListening();
              }
            }
          }
        },
        onError: (error) {
          final errMsg = error.errorMsg.toLowerCase();
          if (errMsg.contains('timeout') || errMsg.contains('no_match') || errMsg.contains('client') || errMsg.contains('busy')) {
            if (_isVoiceAssistantActive) {
              _restartListening();
            }
            return;
          }
          if (mounted) {
            setState(() {
              _speechAvailable = false;
              _isListening = false;
              _soundLevel = 0.0;
              _voicePromptText = 'Error: ${error.errorMsg}';
            });
          }
        },
      );
      if (!mounted) return;
      if (!available) {
        setState(() {
          _speechAvailable = false;
          _voicePromptText = 'Permission denied. Allow mic access in settings.';
        });
        return;
      }
      setState(() {
        _speechAvailable = true;
      });
    }
    _startListening();
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          _voiceTranscript = result.recognizedWords;
          if (_voiceTranscript.isNotEmpty) {
            _voiceSubText = '';
            _consecutiveRestarts = 0;
          }
        });
      },
      onSoundLevelChange: (level) {
        setState(() {
          _soundLevel = level;
        });
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 6),
        partialResults: true,
      ),
    );
    setState(() {
      _isListening = true;
      if (_voicePromptText.isEmpty) {
        _voicePromptText = AppLocalizations.of(context)!.voiceListening;
      }
    });
  }

  void _stopListeningAndProcess() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
    });
    if (_voiceTranscript.trim().isNotEmpty) {
      _processVoiceCommand(_voiceTranscript);
    } else {
      if (_assistantState == 'waitingForHealthStatus') {
        setState(() {
          _voiceSubText = _getLangCode() == 'hi' ? 'बोलने के लिए माइक दबाएं' : 'Tap mic to speak';
        });
      } else {
        setState(() {
          _voicePromptText = AppLocalizations.of(context)!.voiceRespFallback;
        });
        _closeVoiceAfterDelay();
      }
    }
  }

  Map<String, String>? _parseVitalFromText(String text) {
    final lower = text.toLowerCase();

    RegExp bpRegex = RegExp(r'(\d{2,3})\s*(?:/|over|by|upon|par)\s*(\d{2,3})');
    var bpMatch = bpRegex.firstMatch(lower);
    if (bpMatch != null &&
        (lower.contains('bp') ||
            lower.contains('blood') ||
            lower.contains('बीपी') ||
            lower.contains('ब्लड') ||
            lower.contains('press'))) {
      return {'type': 'bp', 'value': '${bpMatch.group(1)}/${bpMatch.group(2)}'};
    }

    RegExp numRegex = RegExp(r'(\d{2,3}(?:\.\d)?)');
    var numMatch = numRegex.firstMatch(lower);
    if (numMatch == null) return null;

    var num = numMatch.group(1)!;

    if (lower.contains('sugar') || lower.contains('शुगर') || lower.contains('glucose') || lower.contains('ग्लूकोज')) {
      return {'type': 'sugar', 'value': num};
    }
    if (lower.contains('oxygen') || lower.contains('ऑक्सीजन') || lower.contains('spo2') || lower.contains('saturat')) {
      return {'type': 'oxygen', 'value': '$num%'};
    }
    if (lower.contains('temperature') || lower.contains('तापमान') || lower.contains('temp')) {
      return {'type': 'temperature', 'value': '$num°F'};
    }

    if (bpMatch != null) {
      return {'type': 'bp', 'value': '${bpMatch.group(1)}/${bpMatch.group(2)}'};
    }

    return null;
  }

  String _vitalTypeLabel(String type) {
    final l = AppLocalizations.of(context)!;
    switch (type) {
      case 'bp': return l.vitalBp;
      case 'sugar': return l.vitalSugar;
      case 'oxygen': return l.vitalOxygen;
      case 'temperature': return l.vitalTemp;
      default: return type;
    }
  }

  void _saveVitalReading(String type, String value) {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '${hour.toString().padLeft(2, '0')}:$minute $period';
    final dateStr = '${now.day}/${now.month}/${now.year}';

    final reading = VitalReading(
      type: type,
      value: value,
      time: timeStr,
      date: dateStr,
      timestamp: now,
    );

    context.read<VitalsProvider>().addReading(reading);

    setState(() {
      _voiceSavedMessage = '${_vitalTypeLabel(type)}: $value ${AppLocalizations.of(context)!.readingSavedLabel}';
      _currentIndex = 1;
    });
  }

  String _buildHealthContext() {
    final l = AppLocalizations.of(context)!;
    final vitals = context.read<VitalsProvider>();
    final buffer = StringBuffer();

    // 1. Current timestamp context (essential for relative questions like "agli dawai" or "dophar me")
    final now = DateTime.now();
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final weekdayName = weekdays[now.weekday % 7];
    buffer.writeln('Current Date and Time: ${now.day}/${now.month}/${now.year} ($weekdayName) | ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    final profile = context.read<ProfileProvider>();
    buffer.writeln('Patient Profile:');
    buffer.writeln('- Name: ${profile.name}');
    buffer.writeln('- Age/DOB: ${l.userDob}');
    buffer.writeln('- Gender: ${l.userGender}');
    buffer.writeln('- Blood Group: ${l.userBloodGroup}');

    buffer.writeln('Medical Conditions: ${l.condHypertension}, ${l.condDiabetes}, ${l.condArthritis}');
    buffer.writeln('Allergies: ${l.allergyDust}, ${l.allergyPenicillin}');

    buffer.writeln('Current Medicines Schedule:');
    for (final med in _medicines) {
      buffer.writeln('- ${med['name']} | Dose: ${InstructionHelper.getDoseText(l, med['dose'])} at ${med['time']} | ${InstructionHelper.getInstructionText(l, med['instruction'])} | Already Taken: ${med['isTaken']}');
    }

    // 2. Vitals readings (recent first)
    final bpReadings = vitals.getReadingsByType('bp');
    final sugarReadings = vitals.getReadingsByType('sugar');
    final oxygenReadings = vitals.getReadingsByType('oxygen');
    final tempReadings = vitals.getReadingsByType('temperature');

    if (bpReadings.isNotEmpty) {
      buffer.writeln('Recent BP Readings (most recent first):');
      for (final r in bpReadings.reversed.take(5)) {
        buffer.writeln('- ${r.value} mmHg (recorded at ${r.time} on ${r.date})');
      }
    }
    if (sugarReadings.isNotEmpty) {
      buffer.writeln('Recent Sugar Readings (most recent first):');
      for (final r in sugarReadings.reversed.take(5)) {
        buffer.writeln('- ${r.value} mg/dL (recorded at ${r.time} on ${r.date})');
      }
    }
    if (oxygenReadings.isNotEmpty) {
      buffer.writeln('Recent Oxygen Readings (most recent first):');
      for (final r in oxygenReadings.reversed.take(5)) {
        buffer.writeln('- ${r.value} (recorded at ${r.time} on ${r.date})');
      }
    }
    if (tempReadings.isNotEmpty) {
      buffer.writeln('Recent Temperature Readings (most recent first):');
      for (final r in tempReadings.reversed.take(5)) {
        buffer.writeln('- ${r.value} (recorded at ${r.time} on ${r.date})');
      }
    }

    // 3. Appointments
    buffer.writeln('Doctor Appointments:');
    buffer.writeln('- Dr. R. K. Gupta (Family Doctor) | Today at 10:00 AM');

    if (_emergencyContacts.isNotEmpty) {
      buffer.writeln('Emergency Contacts:');
      for (final c in _emergencyContacts) {
        buffer.writeln('- ${c['name']}: ${c['phone']}');
      }
    }

    return buffer.toString();
  }

  void _closeVoiceAfterDelay() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isVoiceAssistantActive = false;
          _soundLevel = 0.0;
        });
      }
    });
  }

  void _processVoiceCommand(String command) async {
    setState(() {
      _voicePromptText = AppLocalizations.of(context)!.voiceProcessing;
      _chatHistory.add({'role': 'user', 'text': command});
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final l = AppLocalizations.of(context)!;
    final lowerCmd = command.toLowerCase();

    // 1. Check for manual close/stop/bye intent
    bool isCloseIntent = lowerCmd.contains('close') || lowerCmd.contains('exit') || lowerCmd.contains('stop') ||
                        lowerCmd.contains('bye') || lowerCmd.contains('thank you') || lowerCmd.contains('dhanyawad') ||
                        lowerCmd.contains('shukriya') || lowerCmd.contains('बंद करो') || lowerCmd.contains('बाय') ||
                        lowerCmd.contains('टाटा') || lowerCmd.contains('धन्यवाद') || lowerCmd.contains('शुक्रिया');
    if (isCloseIntent) {
      final closeReply = _getLangCode() == 'hi'
          ? 'आपका स्वागत है। सहायक बंद कर रहा हूँ।'
          : 'You are welcome! Closing assistant.';
      setState(() {
        _assistantState = 'closing';
        _voicePromptText = closeReply;
        _voiceTranscript = command;
      });
      await _safeSpeak(closeReply);
      _closeVoiceAfterDelay();
      return;
    }

    // 2. Try to extract vitals (global capability)
    var vital = _parseVitalFromText(command) ??
        await OpenRouterService.parseVitalFromSpeech(command);

    if (vital != null) {
      final v = vital;
      _saveVitalReading(v['type']!, v['value']!);
      String label = _vitalTypeLabel(v['type']!);
      setState(() {
        _voiceSavedMessage = '$label: ${v['value']} ${l.readingSavedLabel}';
        _voiceTranscript = command;
      });
      // Get AI comment on the vital
      String? aiComment = await OpenRouterService.chat(
        'Mera ${v['type']} ${v['value']} hai. Kya ye normal hai?',
        healthContext: _buildHealthContext(),
        languageCode: _getLangCode(),
      );
      if (aiComment != null && mounted) {
        setState(() {
          _assistantState = 'closing';
          _chatHistory.add({'role': 'ai', 'text': aiComment});
        });
        await _safeSpeak(aiComment);
      } else {
        setState(() {
          _assistantState = 'closing';
        });
      }
      _closeVoiceAfterDelay();
      return;
    }

    // 3. Turn-Based Flow Check
    if (_assistantState == 'greeting' || _assistantState == 'waitingForHealthStatus') {
      // User is responding to how their health is
      bool isFeelingBad = lowerCmd.contains('pain') || lowerCmd.contains('bad') || lowerCmd.contains('not well') || 
                          lowerCmd.contains('sick') || lowerCmd.contains('fever') || lowerCmd.contains('unwell') ||
                          lowerCmd.contains('ill') || lowerCmd.contains('headache') || lowerCmd.contains('ache') ||
                          lowerCmd.contains('hurt') || lowerCmd.contains('दर्द') || lowerCmd.contains('ठीक नहीं') ||
                          lowerCmd.contains('तबीयत खराब') || lowerCmd.contains('बुखार') || lowerCmd.contains('परेशानी') ||
                          lowerCmd.contains('तकलीफ') || lowerCmd.contains('अस्वस्थ') || lowerCmd.contains('बीमार') ||
                          lowerCmd.contains('खराब');

      String reply = "";
      if (_getLangCode() == 'hi') {
        reply = isFeelingBad
            ? "मुझे सुनकर बहुत दुख हुआ। तो आपको आज किस प्रकार की सहायता चाहिए? क्या मैं डॉक्टर बुक करूँ या कोई और सहायता?"
            : "यह सुनकर अच्छा लगा। तो आपको आज किस प्रकार की सहायता चाहिए?";
      } else {
        reply = isFeelingBad
            ? "I'm very sorry to hear that. What kind of assistance do you need today? Should I book a doctor or help with something else?"
            : "Glad to hear that! So what kind of assistance do you need today?";
      }

      setState(() {
        _assistantState = 'waitingForAssistanceRequest';
        _voicePromptText = reply;
        _voiceTranscript = command;
        _chatHistory.add({'role': 'ai', 'text': reply});
      });

      _speakAndListen(reply, 'waitingForAssistanceRequest');
      return;
    }

    // 4. Assistance Request handling (waitingForAssistanceRequest or general chat turns)
    // Check for emergency/SOS
    if (lowerCmd.contains('sos') || lowerCmd.contains('emergency') || lowerCmd.contains('एसओएस') || lowerCmd.contains('आपातकाल') || lowerCmd.contains('आपातकालीन')) {
      final sosReply = _getLangCode() == 'hi'
          ? 'एसओएस आपातकालीन चेतावनी सक्रिय कर रहा हूँ। कृपया घबराएं नहीं।'
          : 'Activating SOS emergency alert. Please do not panic.';
      setState(() {
        _assistantState = 'closing';
        _voicePromptText = sosReply;
        _voiceTranscript = command;
      });
      await _safeSpeak(sosReply);
      _triggerSOSFlow();
      return;
    }

    // Check for App Navigation / Access Commands
    bool isNavAction = false;
    String actionReply = "";
    int targetIndex = _currentIndex;
    Widget? screenToPush;

    if (lowerCmd.contains('medicine') || lowerCmd.contains('dawai') || lowerCmd.contains('दवाई') || lowerCmd.contains('मेडिसिन') || lowerCmd.contains('दवा')) {
      targetIndex = 3;
      actionReply = _getLangCode() == 'hi'
          ? 'दवाइयों की स्क्रीन पर जा रहा हूँ।'
          : 'Navigating to your medicines screen.';
      isNavAction = true;
    } else if (lowerCmd.contains('vital') || lowerCmd.contains('विटल') || lowerCmd.contains('बीपी') || lowerCmd.contains('शुगर') || lowerCmd.contains('blood pressure') || lowerCmd.contains('sugar')) {
      targetIndex = 1;
      actionReply = _getLangCode() == 'hi'
          ? 'स्वास्थ्य माप और रिपोर्ट की स्क्रीन पर जा रहा हूँ।'
          : 'Navigating to your vitals and reports screen.';
      isNavAction = true;
    } else if (lowerCmd.contains('home') || lowerCmd.contains('dashboard') || lowerCmd.contains('मुख्य स्क्रीन') || lowerCmd.contains('होम') || lowerCmd.contains('डैशबोर्ड')) {
      targetIndex = 0;
      actionReply = _getLangCode() == 'hi'
          ? 'मुख्य डैशबोर्ड पर वापस जा रहा हूँ।'
          : 'Going back to the main dashboard.';
      isNavAction = true;
    } else if (lowerCmd.contains('doctor') || lowerCmd.contains('appointment') || lowerCmd.contains('डॉक्टर') || lowerCmd.contains('अपॉइंटमेंट')) {
      actionReply = _getLangCode() == 'hi'
          ? 'डॉक्टर अपॉइंटमेंट बुक करने की स्क्रीन खोल रहा हूँ।'
          : 'Opening the doctor appointment booking screen.';
      screenToPush = const ChooseDoctorScreen();
      isNavAction = true;
    } else if (lowerCmd.contains('record') || lowerCmd.contains('prescription') || lowerCmd.contains('medical record') || lowerCmd.contains('दस्तावेज़') || lowerCmd.contains('पर्चा') || lowerCmd.contains('प्रिस्क्रिप्शन')) {
      actionReply = _getLangCode() == 'hi'
          ? 'मेडिकल रिकॉर्ड्स और पर्चे खोल रहा हूँ।'
          : 'Opening your medical records and prescriptions.';
      screenToPush = const MedicalRecordsScreen();
      isNavAction = true;
    } else if (lowerCmd.contains('family') || lowerCmd.contains('member') || lowerCmd.contains('परिवार') || lowerCmd.contains('सदस्य')) {
      actionReply = _getLangCode() == 'hi'
          ? 'परिवार के सदस्यों की स्क्रीन खोल रहा हूँ।'
          : 'Opening your family members screen.';
      screenToPush = const FamilyScreen();
      isNavAction = true;
    } else if (lowerCmd.contains('report') || lowerCmd.contains('analyt') || lowerCmd.contains('स्वास्थ्य रिपोर्ट') || lowerCmd.contains('रिपोर्ट')) {
      actionReply = _getLangCode() == 'hi'
          ? 'स्वास्थ्य विश्लेषण रिपोर्ट खोल रहा हूँ।'
          : 'Opening your health analysis report.';
      screenToPush = const HealthReportScreen();
      isNavAction = true;
    } else if (lowerCmd.contains('tips') || lowerCmd.contains('सलाह') || lowerCmd.contains('सुझाव') || lowerCmd.contains('tip')) {
      actionReply = _getLangCode() == 'hi'
          ? 'स्वास्थ्य संबंधी टिप्स और सलाह खोल रहा हूँ।'
          : 'Opening health tips and recommendations.';
      screenToPush = const HealthTipsScreen();
      isNavAction = true;
    } else if (lowerCmd.contains('profile') || lowerCmd.contains('प्रोफाइल') || lowerCmd.contains('मेरी प्रोफाइल')) {
      targetIndex = 4;
      actionReply = _getLangCode() == 'hi'
          ? 'आपकी प्रोफाइल स्क्रीन पर जा रहा हूँ।'
          : 'Navigating to your profile screen.';
      isNavAction = true;
    }

    if (isNavAction) {
      setState(() {
        _assistantState = 'closing';
        _voicePromptText = actionReply;
        _voiceTranscript = command;
      });
      await _safeSpeak(actionReply);
      if (mounted) {
        setState(() {
          _currentIndex = targetIndex;
        });
        if (screenToPush != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screenToPush!));
        }
      }
      _closeVoiceAfterDelay();
      return;
    }

    // 5. Fallback - General conversational reply using Gemini AI
    setState(() {
      _voiceSubText = _getLangCode() == 'hi' ? 'सोच रहा हूँ...' : 'Thinking...';
    });

    String? aiReply = await OpenRouterService.chat(
      command,
      healthContext: _buildHealthContext(),
      languageCode: _getLangCode(),
    );

    if (!mounted) return;

    if (aiReply != null) {
      setState(() {
        _voicePromptText = aiReply;
        _voiceSubText = '';
        _voiceTranscript = command;
        _chatHistory.add({'role': 'ai', 'text': aiReply});
      });
      _speakAndListen(aiReply, 'waitingForAssistanceRequest');
    } else {
      final fallbackText = l.voiceRespFallback;
      setState(() {
        _voicePromptText = fallbackText;
        _voiceTranscript = command;
      });
      _speakAndListen(fallbackText, 'waitingForAssistanceRequest');
    }
  }

  void _triggerSOSFlow() {
    setState(() {
      _isVoiceAssistantActive = false;
      _soundLevel = 0.0;
      _isSosCountdownActive = true;
      _sosCountdownVal = 3;
      _isSosAlertSent = false;
    });

    _sosTimer?.cancel();
    _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sosCountdownVal > 1) {
        setState(() {
          _sosCountdownVal--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isSosCountdownActive = false;
        });
        _sendSosAlerts();
      }
    });
  }

  Future<void> _sendSosAlerts() async {
    final l = AppLocalizations.of(context)!;
    final message = l.sosMessage;
    int sentCount = 0;
    for (final contact in _emergencyContacts) {
      final phone = contact['phone'] ?? '';
      if (phone.isNotEmpty) {
        final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
        final uri = Uri.parse('sms:$cleaned?body=${Uri.encodeComponent(message)}');
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            sentCount++;
          }
        } catch (_) {}
      }
    }
    if (mounted) {
      setState(() {
        _isSosAlertSent = true;
        _sosSmsSentCount = sentCount;
      });
    }
  }

  void _cancelSOS() {
    _sosTimer?.cancel();
    setState(() {
      _isSosCountdownActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.sosCancelled,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _calculateProgress() {
    if (_medicines.isEmpty) return 0.0;
    int takenCount = _medicines.where((med) => med['isTaken'] == true).length;
    return takenCount / _medicines.length;
  }

  void _toggleMedicineStatus(int index) {
    setState(() {
      _medicines[index]['isTaken'] = !_medicines[index]['isTaken'];
    });
  }

  void _addEmergencyContact(String name, String phone) {
    setState(() {
      _emergencyContacts.add({'name': name, 'phone': phone});
    });
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
  }

  void _addNewMedicine(String name, String time, String dose, String instruction) {
    setState(() {
      _medicines.add({
        'name': name,
        'time': time,
        'dose': dose,
        'instruction': instruction,
        'isTaken': false,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.scheduleMedicine,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7F56D9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final c = context.appColors;
    _initSampleData();

    // Watch VitalsProvider for dynamic updates
    final vitals = context.watch<VitalsProvider>();
    final bpReadings = vitals.getReadingsByType('bp');
    final sugarReadings = vitals.getReadingsByType('sugar');
    final oxygenReadings = vitals.getReadingsByType('oxygen');
    final tempReadings = vitals.getReadingsByType('temperature');

    final String latestBp = bpReadings.isNotEmpty ? bpReadings.last.value : '120/80';
    final String latestSugar = sugarReadings.isNotEmpty ? sugarReadings.last.value : '98';
    final String latestOxygen = oxygenReadings.isNotEmpty ? oxygenReadings.last.value : '98%';
    final String latestTemp = tempReadings.isNotEmpty ? tempReadings.last.value : '98.6°F';

    var nextMed = _medicines.isEmpty
        ? <String, dynamic>{}
        : _medicines.firstWhere((med) => med['isTaken'] == false, orElse: () => _medicines.first);
    bool isNextMedTaken = nextMed['isTaken'] ?? false;

    final List<Widget> screens = [
      HomeScreen(
        medicineProgress: _calculateProgress(),
        nextMedicine: nextMed,
        isNextMedTaken: isNextMedTaken,
        medicineTakenCount: _medicines.where((m) => m['isTaken'] == true).length,
        medicineTotalCount: _medicines.length,
        notificationCount: _unreadCount,
        onOpenNotifications: _openNotifications,
        onTakeMedicine: () {
          int idx = _medicines.indexOf(nextMed);
          _toggleMedicineStatus(idx);
        },
        onTriggerSos: _triggerSOSFlow,
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onOpenVitalDetail: (index) {
          final types = [VitalType.bloodPressure, VitalType.bloodSugar, VitalType.oxygen, VitalType.temperature];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VitalDetailScreen(
                vitalType: types[index],
              ),
            ),
          );
        },
        latestBp: latestBp,
        latestSugar: latestSugar,
        latestOxygen: latestOxygen,
        latestTemp: latestTemp,
      ),
      VitalsScreen(onBack: () {
        setState(() {
          _currentIndex = 0;
        });
      }),
      const SizedBox(), // Spacer
      MedicinesScreen(
        medicinesList: _medicines,
        onToggleStatus: _toggleMedicineStatus,
        onAddMedicine: _addNewMedicine,
        notificationCount: _unreadCount,
        onOpenNotifications: _openNotifications,
      ),
      ProfileScreen(
        emergencyContacts: _emergencyContacts,
        onAddContact: _addEmergencyContact,
        onRemoveContact: _removeEmergencyContact,
      ),
    ];

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Current Screen View (Fills body area and resizes automatically above bottom navigation bar)
          screens[_currentIndex],
          
          // Voice Assistant Siri Overlay dialog
          if (_isVoiceAssistantActive) _buildVoiceOverlay(),
          
          // SOS Countdown Overlay
          if (_isSosCountdownActive) _buildSosCountdownOverlay(),
          
          // SOS Sent Success Dialog
          if (_isSosAlertSent) _buildSosSuccessOverlay(),
        ],
      ),
      // Placed inside the bottomNavigationBar parameter so body content stops exactly above it
      bottomNavigationBar: _buildFloatingBottomNav(),
    );
  }

  // Custom Floating Bottom Navigation Bar
  Widget _buildFloatingBottomNav() {
    final cnv = context.appColors;
    double bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomInset + 14,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Nav bar
          Container(
            height: 82,
            decoration: BoxDecoration(
              color: cnv.cardBg.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, AppLocalizations.of(context)!.navHome, icon: Icons.home_rounded),
                _buildNavItem(1, AppLocalizations.of(context)!.navVitals, icon: Icons.favorite_rounded),
                const SizedBox(width: 52),
                _buildNavItem(
                  3,
                  AppLocalizations.of(context)!.navMedicines,
                  customIcon: CapsuleIcon(
                    color: _currentIndex == 3 ? const Color(0xFF6C4DFF) : const Color(0xFFB0B7C3),
                    size: 22,
                  ),
                ),
                _buildNavItem(4, AppLocalizations.of(context)!.navProfile, icon: Icons.person_rounded),
              ],
            ),
          ),
          // Floating mic button above nav bar
          Positioned(
            top: -14,
            child: _buildFloatingMicButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, {IconData? icon, Widget? customIcon}) {
    bool isActive = _currentIndex == index;
    Color iconColor = isActive ? const Color(0xFF6C4DFF) : const Color(0xFFB0B7C3);
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon ?? Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMicButton() {
    return GestureDetector(
      onTap: _openVoiceAssistant,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF5B3DFF), Color(0xFF7B61FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B3DFF).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.mic_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // Voice Assistant Siri Overlay Dialog UI
  Widget _buildVoiceOverlay() {
    final c = context.appColors;
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: const Offset(0, -5),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.voiceAssistantTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: c.secondaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: c.tertiaryText),
                    onPressed: () {
                      _speech.stop();
                      _tts.stop();
                      setState(() {
                        _isListening = false;
                        _isVoiceAssistantActive = false;
                        _soundLevel = 0.0;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isListening
                    ? _stopListeningAndProcess
                    : () {
                        _tts.stop();
                        setState(() {
                          _voiceSubText = _getLangCode() == 'hi'
                              ? 'आपकी बात सुन रहा हूँ...'
                              : 'Listening to you...';
                          _voiceTranscript = '';
                        });
                        _consecutiveRestarts = 0;
                        _initAndListen();
                      },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isListening)
                      for (int i = 0; i < 3; i++)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 150 + i * 50),
                          width: 64 + (_soundLevel.clamp(0, 10) * (6 + i * 4)),
                          height: 64 + (_soundLevel.clamp(0, 10) * (6 + i * 4)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7F56D9)
                                .withValues(alpha: (0.12 - i * 0.035) * (_soundLevel / 8).clamp(0.3, 1.0)),
                          ),
                        ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: _isListening ? 96 : 76,
                      height: _isListening ? 96 : 76,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? const Color(0xFF7F56D9).withValues(alpha: 0.12)
                            : const Color(0xFF7F56D9).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isListening ? const Color(0xFF7F56D9) : const Color(0xFF7F56D9),
                        shape: BoxShape.circle,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF7F56D9).withValues(alpha: 0.4 * (_soundLevel / 8).clamp(0.2, 1.0)),
                                  blurRadius: 20 + _soundLevel * 2,
                                  spreadRadius: _soundLevel * 0.5,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    if (_isListening)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF12B76A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isListening)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppLocalizations.of(context)!.tapToStop,
                    style: TextStyle(
                      fontSize: 12,
                      color: c.tertiaryText,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                _voicePromptText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: c.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _voiceSubText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: [
                  ActionChip(
                    label: Text(AppLocalizations.of(context)!.voiceMedicine),
                    onPressed: () {
                      if (_isListening) _speech.stop();
                      _processVoiceCommand(AppLocalizations.of(context)!.voiceCmdMedicine);
                    },
                    backgroundColor: const Color(0xFFF3E8FF),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  ActionChip(
                    label: Text(AppLocalizations.of(context)!.voiceVitals),
                    onPressed: () {
                      if (_isListening) _speech.stop();
                      _processVoiceCommand(AppLocalizations.of(context)!.voiceCmdVitals);
                    },
                    backgroundColor: const Color(0xFFEBF5FF),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  ActionChip(
                    label: Text(AppLocalizations.of(context)!.voiceSos),
                    onPressed: () {
                      if (_isListening) _speech.stop();
                      _processVoiceCommand(AppLocalizations.of(context)!.voiceCmdSos);
                    },
                    backgroundColor: const Color(0xFFFEF3F2),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  ActionChip(
                    label: Text(AppLocalizations.of(context)!.voiceHome),
                    onPressed: () {
                      if (_isListening) _speech.stop();
                      _processVoiceCommand(AppLocalizations.of(context)!.voiceCmdHome);
                    },
                    backgroundColor: const Color(0xFFF2F4F7),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_chatHistory.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: ListView.builder(
                    itemCount: _chatHistory.length,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      final msg = _chatHistory[i];
                      final isUser = msg['role'] == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Container(
                                width: 22, height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7F56D9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isUser ? const Color(0xFF7F56D9) : const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: Radius.circular(isUser ? 12 : 4),
                                    bottomRight: Radius.circular(isUser ? 4 : 12),
                                  ),
                                ),
                                child: Text(
                                  msg['text'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isUser ? Colors.white : const Color(0xFF344054),
                                  ),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 22, height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF9CA3AF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_rounded, color: Colors.white, size: 14),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _voiceSavedMessage.isNotEmpty
                        ? const Color(0xFFDCFCE7)
                        : c.scaffoldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _voiceSavedMessage.isNotEmpty
                        ? '$_voiceSavedMessage $_voiceTranscript'
                        : (_voiceTranscript.isNotEmpty
                            ? _voiceTranscript
                            : AppLocalizations.of(context)!.voiceTranscript),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: _voiceSavedMessage.isNotEmpty
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF7F56D9),
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Full screen SOS Countdown UI dialog
  Widget _buildSosCountdownOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🚨',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.emergencyAlert,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.sosSending,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD92D20).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFFD92D20),
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD92D20).withValues(alpha: 0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$_sosCountdownVal',
                    style: const TextStyle(
                      
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  AppLocalizations.of(context)!.sosInforming,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _cancelSOS,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.close_rounded, color: Color(0xFFD92D20), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.sosCancel,
                        style: const TextStyle(
                          color: Color(0xFFD92D20),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SOS Success details overlay
  Widget _buildSosSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF12B76A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context)!.sosSent,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF12B76A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.sosDontWorry,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475467),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildLogItem('SMS sent to $_sosSmsSentCount contact(s)'),
                    if (_emergencyContacts.isNotEmpty)
                      ..._emergencyContacts.map((c) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(Icons.check_circle_outline, size: 14, color: const Color(0xFF12B76A)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${c['name']} (${c['phone']})',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF475467)),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSosAlertSent = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F56D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.sosClose,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7F56D9))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1D2939), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// Custom Rotating Capsule Icon Widget for Bottom Navigation Bar
class CapsuleIcon extends StatelessWidget {
  final Color color;
  final double size;
  const CapsuleIcon({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CapsuleIconPainter(color),
    );
  }
}

class _CapsuleIconPainter extends CustomPainter {
  final Color color;
  _CapsuleIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi / 4); // Rotate 45 degrees

    final rect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: size.width * 0.36,
      height: size.height * 0.8,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.18));
    canvas.drawRRect(rrect, paint);

    // Divider line splitting capsule halves
    canvas.drawLine(Offset(-size.width * 0.18, 0), Offset(size.width * 0.18, 0), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CapsuleIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
