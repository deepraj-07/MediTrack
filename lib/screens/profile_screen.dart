import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/providers/language_provider.dart';
import 'package:meditrack/providers/theme_provider.dart';
import 'package:meditrack/providers/profile_provider.dart';
import 'package:meditrack/theme/app_theme.dart';
import 'package:meditrack/screens/qr_card_screen.dart';
import 'package:meditrack/screens/scan_qr_screen.dart';

class ProfileScreen extends StatelessWidget {
  final List<Map<String, String>> emergencyContacts;
  final void Function(String name, String phone) onAddContact;
  final void Function(int index) onRemoveContact;

  const ProfileScreen({
    super.key,
    this.emergencyContacts = const [],
    required this.onAddContact,
    required this.onRemoveContact,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.myProfile,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.primaryText),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: c.secondaryText),
            onPressed: () => _navigateTo(context, const PrivacySecuritySubScreen()),
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, l, context.watch<ProfileProvider>()),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatItem('❤️', l.statHealthScore, l.profileHealthScore, c),
                const SizedBox(width: 12),
                _buildStatItem('🗓️', l.statMemberSince, l.profileMemberSince, c),
                const SizedBox(width: 12),
                _buildStatItem('👥', l.statFamilyMembers, l.profileFamilyCount, c),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              l.myOptions,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.primaryText),
            ),
            const SizedBox(height: 16),
            _buildOptionItem(context, Icons.person_outline_rounded, l.personalInfo, const Color(0xFF7F56D9), onTap: () => _navigateTo(context, const EditProfileSubScreen())),
            _buildOptionItem(context, Icons.favorite_outline_rounded, l.healthInfo, const Color(0xFFF43F5E), onTap: () => _navigateTo(context, const HealthInfoSubScreen())),
            _buildOptionItem(context, Icons.people_outline_rounded, l.emergencyContactsLabel, const Color(0xFF2E90FA), onTap: () => _navigateTo(context, EmergencyContactsSubScreen(
              contacts: emergencyContacts,
              onAddContact: onAddContact,
              onRemoveContact: onRemoveContact,
            ))),
            _buildOptionItem(context, Icons.language_rounded, l.languageDisplay, const Color(0xFFF79009), onTap: () => _navigateTo(context, const LanguageDisplaySubScreen())),
            _buildOptionItem(context, Icons.notifications_none_rounded, l.notificationSettings, const Color(0xFF667085), onTap: () => _navigateTo(context, const NotificationSettingsSubScreen())),
            _buildOptionItem(context, Icons.qr_code_scanner_rounded, l.scanQrOption, const Color(0xFF2E90FA), onTap: () => _navigateTo(context, const ScanQrScreen())),
            _buildOptionItem(context, Icons.shield_outlined, l.privacySecurity, const Color(0xFF12B76A), onTap: () => _navigateTo(context, const PrivacySecuritySubScreen())),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildProfileHeader(BuildContext context, AppLocalizations l, ProfileProvider profile) {
    final imagePath = profile.imagePath;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F56D9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF7F56D9).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateTo(context, const EditProfileSubScreen()),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(radius: 40, backgroundImage: imagePath != null ? FileImage(File(imagePath)) as ImageProvider : const AssetImage('assets/images/avatar.png')),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFF12B76A), shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(profile.name.isNotEmpty ? profile.name : l.profileNameEn, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(l.profileNameEn, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                              child: Text(l.profileId, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                            Text(l.primaryAccount, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _navigateTo(context, const QrCardScreen()),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, AppColors c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.secondaryText), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String label, Color color, {required VoidCallback onTap}) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.tertiaryText, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SUB SCREENS ---

class PersonalInfoSubScreen extends StatelessWidget {
  const PersonalInfoSubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    final profile = context.watch<ProfileProvider>();
    final imagePath = profile.imagePath;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.personalInfoHeading, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(imagePath)),
                ),
              ),
            _buildInfoTile(Icons.calendar_today_outlined, l.dobLabel, l.userDob, c),
            _buildInfoTile(Icons.transgender_rounded, l.genderLabel, l.userGender, c),
            _buildInfoTile(Icons.phone_outlined, l.mobileLabel, profile.mobile, c),
            _buildInfoTile(Icons.email_outlined, l.emailLabel, profile.email, c),
            _buildInfoTile(Icons.location_on_outlined, l.addressLabel, profile.address, c),
            _buildInfoTile(Icons.bloodtype_outlined, l.bloodGroupLabel, l.userBloodGroup, c),
            const SizedBox(height: 24),
            _buildMainButton(l.editInfo, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileSubScreen()));
            }),
          ],
        ),
      ),
    );
  }
}

class HealthInfoSubScreen extends StatefulWidget {
  const HealthInfoSubScreen({super.key});

  @override
  State<HealthInfoSubScreen> createState() => _HealthInfoSubScreenState();
}

class _HealthInfoSubScreenState extends State<HealthInfoSubScreen> {
  final List<Map<String, String>> _conditions = [
    {'name': 'Hypertension', 'color': 'red', 'icon': 'favorite'},
    {'name': 'Diabetes Type 2', 'color': 'blue', 'icon': 'water_drop'},
    {'name': 'Arthritis', 'color': 'purple', 'icon': 'accessibility_new'},
  ];
  final List<Map<String, String>> _allergies = [
    {'name': 'Dust Allergy', 'color': 'green', 'icon': 'warning'},
    {'name': 'Penicillin', 'color': 'orange', 'icon': 'warning'},
  ];
  final List<Map<String, String>> _medicines = [
    {'name': 'Amlodipine 5mg', 'desc': 'Morning - 1 pill'},
    {'name': 'Metformin 500mg', 'desc': '1 pill'},
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.healthInfoHeading, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l.primaryConditions, c),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                ..._conditions.map((cond) => _buildConditionChip(cond['name']!, _parseColor(cond['color']!), _parseIcon(cond['icon']!))),
                _buildAddChip(l.addNewCondition, c, onTap: () => _showAddDialog(context, l, 'condition')),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionHeader(l.allergiesLabel, c),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                ..._allergies.map((a) => _buildAllergyChip(a['name']!, _parseColor(a['color']!), c)),
                _buildAddChip(l.addNewAllergy, c, onTap: () => _showAddDialog(context, l, 'allergy')),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionHeader(l.regularMedicines, c),
            const SizedBox(height: 12),
            ..._medicines.map((m) => _buildMedInfoTile(m['name']!, m['desc']!, c)),
            const SizedBox(height: 12),
            _buildAddChip(l.addMedicine, c, onTap: () => _showAddDialog(context, l, 'medicine')),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppLocalizations l, String type) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String title = type == 'condition' ? l.addNewCondition : type == 'allergy' ? l.addNewAllergy : l.addMedicine;
    String nameLabel = type == 'medicine' ? l.medicineName : l.fullNameLabel;
    String descLabel = type == 'medicine' ? l.dose : '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: nameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            if (descLabel.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: descLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  if (type == 'condition') {
                    _conditions.add({'name': nameCtrl.text.trim(), 'color': 'gray', 'icon': 'favorite'});
                  } else if (type == 'allergy') {
                    _allergies.add({'name': nameCtrl.text.trim(), 'color': 'gray', 'icon': 'warning'});
                  } else {
                    _medicines.add({'name': nameCtrl.text.trim(), 'desc': descCtrl.text.trim().isEmpty ? '1 pill' : descCtrl.text.trim()});
                  }
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(l.save, style: const TextStyle(color: Color(0xFF7F56D9))),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String color) {
    switch (color) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _parseIcon(String icon) {
    switch (icon) {
      case 'favorite': return Icons.favorite;
      case 'water_drop': return Icons.water_drop;
      case 'accessibility_new': return Icons.accessibility_new;
      default: return Icons.warning_amber_rounded;
    }
  }
}

class EmergencyContactsSubScreen extends StatefulWidget {
  final List<Map<String, String>> contacts;
  final void Function(String name, String phone) onAddContact;
  final void Function(int index) onRemoveContact;

  const EmergencyContactsSubScreen({
    super.key,
    this.contacts = const [],
    required this.onAddContact,
    required this.onRemoveContact,
  });

  @override
  State<EmergencyContactsSubScreen> createState() => _EmergencyContactsSubScreenState();
}

class _EmergencyContactsSubScreenState extends State<EmergencyContactsSubScreen> {
  late List<Map<String, String>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.contacts);
  }

  void _showAddContactDialog(BuildContext context, AppLocalizations l) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addNewContact),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l.fullNameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: l.mobileLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                widget.onAddContact(nameCtrl.text.trim(), phoneCtrl.text.trim());
                setState(() {
                  _contacts.add({'name': nameCtrl.text.trim(), 'phone': phoneCtrl.text.trim()});
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(l.save, style: const TextStyle(color: Color(0xFF7F56D9))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.emergencyContactsLabel, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF6366F1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.emergencyInfo,
                      style: TextStyle(fontSize: 12, color: c.secondaryText, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._contacts.asMap().entries.map((entry) {
              final i = entry.key;
              final contact = entry.value;
              return _buildContactTile(
                context,
                contact['name'] ?? '',
                contact['phone'] ?? '',
                i == 0 ? l.tagPrimary : l.tagSecondary,
                'assets/images/avatar.png',
                onDelete: () {
                  widget.onRemoveContact(i);
                  setState(() => _contacts.removeAt(i));
                },
              );
            }),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showAddContactDialog(context, l),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.addNewContact),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF7F56D9)),
                foregroundColor: const Color(0xFF7F56D9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageDisplaySubScreen extends StatefulWidget {
  const LanguageDisplaySubScreen({super.key});

  @override
  State<LanguageDisplaySubScreen> createState() => _LanguageDisplaySubScreenState();
}

class _LanguageDisplaySubScreenState extends State<LanguageDisplaySubScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    final locale = context.watch<LanguageProvider>().locale;
    final langProvider = context.read<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    bool isHindi = locale.languageCode == 'hi';
    final selectedLevel = themeProvider.textSizeLevel;
    final highContrast = themeProvider.highContrast;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.languageDisplay, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l.selectLanguage, c),
            const SizedBox(height: 12),
            _buildRadioOption(l.languageEnglish, !isHindi, () => langProvider.setLocale(const Locale('en')), c),
            _buildRadioOption(l.languageHindi, isHindi, () => langProvider.setLocale(const Locale('hi')), c),
            
            const SizedBox(height: 30),
            _buildSectionHeader(l.textSize, c),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSizeOption(l.sizeSmall, 0, selectedLevel == 0, c, themeProvider),
                const SizedBox(width: 10),
                _buildSizeOption(l.sizeMedium, 1, selectedLevel == 1, c, themeProvider),
                const SizedBox(width: 10),
                _buildSizeOption(l.sizeLarge, 2, selectedLevel == 2, c, themeProvider),
              ],
            ),
            
            const SizedBox(height: 30),
            _buildSwitchTile(Icons.dark_mode_outlined, l.darkMode, themeProvider.isDarkMode, (v) => themeProvider.setDarkMode(v), c),
            _buildSwitchTile(Icons.contrast_rounded, l.highContrast, highContrast, (v) => themeProvider.setHighContrast(v), c),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, int level, bool isSelected, AppColors c, ThemeProvider themeProvider) {
    return Expanded(
      child: GestureDetector(
        onTap: () => themeProvider.setTextSizeLevel(level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2B4E) : const Color(0xFFEEF2FF)) : c.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF7F56D9) : c.border),
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF7F56D9) : c.secondaryText)),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String text, bool isSelected, VoidCallback onChange, AppColors c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? const Color(0xFF7F56D9) : c.border)),
      child: InkWell(
        onTap: onChange,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(text, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: c.primaryText)),
              ),
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? const Color(0xFF7F56D9) : c.tertiaryText, width: 2),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7F56D9)),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationSettingsSubScreen extends StatefulWidget {
  const NotificationSettingsSubScreen({super.key});

  @override
  State<NotificationSettingsSubScreen> createState() => _NotificationSettingsSubScreenState();
}

class _NotificationSettingsSubScreenState extends State<NotificationSettingsSubScreen> {
  final Map<String, bool> _settings = {
    'All': true, 'Meds': true, 'Appts': true, 'Alerts': true, 'Family': true, 'Tips': false
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.notificationSettings, context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitchTile(Icons.notifications_active_outlined, l.allNotifications, _settings['All']!, (v) => setState(() => _settings['All'] = v), c),
          Divider(height: 32, color: c.divider),
          _buildSwitchTile(Icons.medication_rounded, l.medicineReminders, _settings['Meds']!, (v) => setState(() => _settings['Meds'] = v), c),
          _buildSwitchTile(Icons.calendar_month_rounded, l.appointmentReminders, _settings['Appts']!, (v) => setState(() => _settings['Appts'] = v), c),
          _buildSwitchTile(Icons.favorite_rounded, l.healthAlerts, _settings['Alerts']!, (v) => setState(() => _settings['Alerts'] = v), c),
          _buildSwitchTile(Icons.people_alt_rounded, l.familyUpdates, _settings['Family']!, (v) => setState(() => _settings['Family'] = v), c),
          _buildSwitchTile(Icons.lightbulb_outline_rounded, l.promotionsTips, _settings['Tips']!, (v) => setState(() => _settings['Tips'] = v), c),
        ],
      ),
    );
  }
}

class PrivacySecuritySubScreen extends StatefulWidget {
  const PrivacySecuritySubScreen({super.key});

  @override
  State<PrivacySecuritySubScreen> createState() => _PrivacySecuritySubScreenState();
}

class _PrivacySecuritySubScreenState extends State<PrivacySecuritySubScreen> {
  bool _passcodeEnabled = true;
  bool _twoFactorEnabled = false;
  bool _dataSharingEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.privacySecurity, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSecurityTile(
              Icons.lock_outline_rounded, l.passcodeBiometric,
              l.passcodeEnabled, Colors.green, c,
              onTap: () {
                setState(() => _passcodeEnabled = !_passcodeEnabled);
              },
            ),
            _buildSecurityTile(
              Icons.password_rounded, l.changePasscode, '', null, c,
              onTap: () => _showPasscodeChangeDialog(context, l),
            ),
            _buildSecurityTile(
              Icons.security_rounded, l.twoFactorAuth,
              _twoFactorEnabled ? l.passcodeEnabled : l.twoFactorDisabled,
              _twoFactorEnabled ? Colors.green : Colors.grey, c,
              onTap: () {
                setState(() => _twoFactorEnabled = !_twoFactorEnabled);
              },
            ),
            _buildSecurityTile(
              Icons.data_usage_rounded, l.dataSharing,
              _dataSharingEnabled ? l.passcodeEnabled : l.twoFactorDisabled,
              _dataSharingEnabled ? Colors.green : Colors.grey, c,
              onTap: () {
                setState(() => _dataSharingEnabled = !_dataSharingEnabled);
              },
            ),
            _buildSecurityTile(
              Icons.description_outlined, l.privacyPolicy, '', null, c,
              onTap: () => _showPrivacyPolicyDialog(context, l),
            ),
            const SizedBox(height: 40),
            _buildLogoutButton(context, l),
          ],
        ),
      ),
    );
  }

  void _showPasscodeChangeDialog(BuildContext context, AppLocalizations l) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.changePasscode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, decoration: InputDecoration(labelText: 'Current Passcode', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), obscureText: true),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, decoration: InputDecoration(labelText: 'New Passcode', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), obscureText: true),
            const SizedBox(height: 12),
            TextField(controller: confirmCtrl, decoration: InputDecoration(labelText: 'Confirm Passcode', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(
            onPressed: () {
              final newPass = newCtrl.text;
              final confirm = confirmCtrl.text;
              if (newPass.isEmpty || newPass.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passcode must be at least 4 characters'), behavior: SnackBarBehavior.floating),
                );
                return;
              }
              if (newPass != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New passcode and confirm do not match'), behavior: SnackBarBehavior.floating),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Passcode updated successfully'), behavior: SnackBarBehavior.floating),
              );
            },
            child: Text(l.save, style: const TextStyle(color: Color(0xFF7F56D9))),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.privacyPolicy),
        content: const Text(
          'We respect your privacy. Your health data is stored securely on your device and is never shared without your explicit consent. '
          'We do not collect, store, or transmit any personal health information to external servers. '
          'All data processing happens locally on your device.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.close)),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(IconData icon, String label, String status, Color? statusColor, AppColors c, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
        child: Row(
          children: [
            Icon(icon, color: c.secondaryText, size: 22),
            const SizedBox(width: 16),
            Expanded(
                child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor?.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: c.tertiaryText, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l) {
    return TextButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.logoutTitle),
            content: Text(l.logoutQuestion),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.logoutCancel)),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.logoutSnackbar), behavior: SnackBarBehavior.floating),
                  );
                },
                child: Text(l.logoutConfirm, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.logout_rounded, color: Color(0xFFD92D20), size: 20),
      label: Text(l.logoutButton, style: const TextStyle(color: Color(0xFFD92D20), fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class EditProfileSubScreen extends StatefulWidget {
  const EditProfileSubScreen({super.key});

  @override
  State<EditProfileSubScreen> createState() => _EditProfileSubScreenState();
}

class _EditProfileSubScreenState extends State<EditProfileSubScreen> {
  String? _imagePath;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _bloodGroupCtrl;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final profile = context.read<ProfileProvider>();
      final l = AppLocalizations.of(context)!;
      _nameCtrl = TextEditingController(text: profile.name.isNotEmpty ? profile.name : l.profileNameEn);
      _mobileCtrl = TextEditingController(text: profile.mobile.isNotEmpty ? profile.mobile : l.userMobile);
      _emailCtrl = TextEditingController(text: profile.email.isNotEmpty ? profile.email : l.userEmail);
      _addressCtrl = TextEditingController(text: profile.address.isNotEmpty ? profile.address : l.userAddress);
      _dobCtrl = TextEditingController(text: profile.dob.isNotEmpty ? profile.dob : l.userDob);
      _genderCtrl = TextEditingController(text: profile.gender.isNotEmpty ? profile.gender : l.userGender);
      _bloodGroupCtrl = TextEditingController(text: profile.bloodGroup.isNotEmpty ? profile.bloodGroup : l.userBloodGroup);
      _imagePath = profile.imagePath;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _bloodGroupCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _saveChanges() async {
    await context.read<ProfileProvider>().updateProfile(
      name: _nameCtrl.text,
      mobile: _mobileCtrl.text,
      email: _emailCtrl.text,
      address: _addressCtrl.text,
      imagePath: _imagePath,
      dob: _dobCtrl.text,
      gender: _genderCtrl.text,
      bloodGroup: _bloodGroupCtrl.text,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.editProfile, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : const AssetImage('assets/images/avatar.png') as ImageProvider,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF7F56D9), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(l.fullNameLabel, _nameCtrl, c),
            _buildTextField(l.mobileLabel, _mobileCtrl, c),
            _buildTextField(l.emailLabel, _emailCtrl, c),
            _buildTextField(l.addressLabel, _addressCtrl, c),
            const SizedBox(height: 20),
            _buildTextField(l.dobLabel, _dobCtrl, c),
            _buildTextField(l.genderLabel, _genderCtrl, c),
            _buildTextField(l.bloodGroupLabel, _bloodGroupCtrl, c),
            const SizedBox(height: 40),
            _buildMainButton(l.saveChanges, _saveChanges),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.secondaryText)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(color: c.primaryText),
            decoration: InputDecoration(
              filled: true, fillColor: c.cardBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.secondaryText)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(icon, color: c.tertiaryText, size: 20),
                const SizedBox(width: 12),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.primaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- GLOBAL HELPER WIDGETS ---

PreferredSizeWidget _buildSubAppBar(String title, BuildContext context) {
  final c = context.appColors;
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: c.primaryText), onPressed: () => Navigator.pop(context)),
    title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
    centerTitle: true,
  );
}

Widget _buildInfoTile(IconData icon, String label, String value, AppColors c) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
    child: Row(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c.scaffoldBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF7F56D9), size: 20)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c.tertiaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.primaryText), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSectionHeader(String title, AppColors c) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.primaryText)),
  ]);
}

Widget _buildConditionChip(String label, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    ]),
  );
}

Widget _buildAllergyChip(String label, Color color, AppColors c) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.border),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.warning_amber_rounded, color: color, size: 16),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    ]),
  );
}

Widget _buildAddChip(String label, AppColors c, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7F56D9), style: BorderStyle.solid),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.add, size: 14, color: Color(0xFF7F56D9)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7F56D9))),
      ]),
    ),
  );
}

Widget _buildMedInfoTile(String name, String desc, AppColors c) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
    child: Row(children: [
      const Icon(Icons.medication_outlined, color: Color(0xFF7F56D9)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(desc, style: TextStyle(fontSize: 12, color: c.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]),
  );
}

Widget _buildContactTile(BuildContext context, String name, String phone, String tag, String img, {VoidCallback? onDelete}) {
  final c = context.appColors;
  bool isPrimary = tag == 'Primary';
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
    child: Row(
      children: [
        CircleAvatar(radius: 24, backgroundImage: AssetImage(img)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(phone, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: isPrimary ? const Color(0xFFECFDF3) : const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(4)),
          child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPrimary ? const Color(0xFF027A48) : const Color(0xFF344054)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.cardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFD92D20)),
            ),
          ),
        ] else ...[
          const SizedBox(width: 8),
          Icon(Icons.more_vert, size: 18, color: c.tertiaryText),
        ],
      ],
    ),
  );
}

Widget _buildSwitchTile(IconData icon, String label, bool val, Function(bool) onChange, AppColors c) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(color: c.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
    child: Row(
      children: [
        Icon(icon, color: c.secondaryText, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Switch(value: val, onChanged: onChange, activeTrackColor: const Color(0xFF7F56D9), activeThumbColor: Colors.white),
      ],
    ),
  );
}

Widget _buildMainButton(String text, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity, height: 54,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7F56D9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}
