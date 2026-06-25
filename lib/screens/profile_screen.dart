import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/providers/language_provider.dart';
import 'package:meditrack/providers/theme_provider.dart';
import 'package:meditrack/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.settingsComingSoon),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
            _buildProfileHeader(context, l),
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
            _buildOptionItem(context, Icons.person_outline_rounded, l.personalInfo, const Color(0xFF7F56D9), onTap: () => _navigateTo(context, const PersonalInfoSubScreen())),
            _buildOptionItem(context, Icons.favorite_outline_rounded, l.healthInfo, const Color(0xFFF43F5E), onTap: () => _navigateTo(context, const HealthInfoSubScreen())),
            _buildOptionItem(context, Icons.people_outline_rounded, l.emergencyContactsLabel, const Color(0xFF2E90FA), onTap: () => _navigateTo(context, const EmergencyContactsSubScreen())),
            _buildOptionItem(context, Icons.language_rounded, l.languageDisplay, const Color(0xFFF79009), onTap: () => _navigateTo(context, const LanguageDisplaySubScreen())),
            _buildOptionItem(context, Icons.notifications_none_rounded, l.notificationSettings, const Color(0xFF667085), onTap: () => _navigateTo(context, const NotificationSettingsSubScreen())),
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

  Widget _buildProfileHeader(BuildContext context, AppLocalizations l) {
    return GestureDetector(
      onTap: () => _navigateTo(context, const EditProfileSubScreen()),
      child: Container(
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
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/images/avatar.png')),
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
                    Text(l.profileNameHi, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
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
            const Icon(Icons.qr_code_2_rounded, color: Colors.white70, size: 24),
          ],
        ),
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
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: _buildSubAppBar(l.personalInfoHeading, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoTile(Icons.person_outline, l.fullNameLabel, l.profileNameHi, c),
            _buildInfoTile(Icons.calendar_today_outlined, l.dobLabel, l.userDob, c),
            _buildInfoTile(Icons.transgender_rounded, l.genderLabel, l.userGender, c),
            _buildInfoTile(Icons.phone_outlined, l.mobileLabel, l.userMobile, c),
            _buildInfoTile(Icons.email_outlined, l.emailLabel, l.userEmail, c),
            _buildInfoTile(Icons.location_on_outlined, l.addressLabel, l.userAddress, c),
            _buildInfoTile(Icons.bloodtype_outlined, l.bloodGroupLabel, l.userBloodGroup, c),
            const SizedBox(height: 24),
            _buildMainButton(l.editInfo, () {}),
          ],
        ),
      ),
    );
  }
}

class HealthInfoSubScreen extends StatelessWidget {
  const HealthInfoSubScreen({super.key});

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
                _buildConditionChip(l.condHypertension, Colors.red, Icons.favorite),
                _buildConditionChip(l.condDiabetes, Colors.blue, Icons.water_drop),
                _buildConditionChip(l.condArthritis, Colors.purple, Icons.accessibility_new),
                _buildAddChip(l.addNewCondition, c),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionHeader(l.allergiesLabel, c),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                _buildAllergyChip(l.allergyDust, Colors.green),
                _buildAllergyChip(l.allergyPenicillin, Colors.orange),
                _buildAddChip(l.addNewAllergy, c),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionHeader(l.regularMedicines, c),
            const SizedBox(height: 12),
            _buildMedInfoTile(l.medAmlodipine, l.medAmlodipineDose, c),
            _buildMedInfoTile(l.medMetformin, l.dose1Pill, c),
          ],
        ),
      ),
    );
  }
}

class EmergencyContactsSubScreen extends StatelessWidget {
  const EmergencyContactsSubScreen({super.key});

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
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(16)),
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
            _buildContactTile(context, l.contactWife, l.contactWifePhone, l.tagPrimary, 'assets/images/avatar.png'),
            _buildContactTile(context, l.contactSon, l.contactSonPhone, l.tagSecondary, 'assets/images/avatar.png'),
            _buildContactTile(context, l.contactDaughter, l.contactDaughterPhone, l.tagSecondary, 'assets/images/avatar.png'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.addContactComingSoon),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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

enum _TextSize { small, medium, large }

class _LanguageDisplaySubScreenState extends State<LanguageDisplaySubScreen> {
  _TextSize _selectedSize = _TextSize.medium;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.appColors;
    final locale = context.watch<LanguageProvider>().locale;
    final langProvider = context.read<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    bool isHindi = locale.languageCode == 'hi';

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
                _buildSizeOption(l.sizeSmall, _TextSize.small, _selectedSize == _TextSize.small, c),
                const SizedBox(width: 10),
                _buildSizeOption(l.sizeMedium, _TextSize.medium, _selectedSize == _TextSize.medium, c),
                const SizedBox(width: 10),
                _buildSizeOption(l.sizeLarge, _TextSize.large, _selectedSize == _TextSize.large, c),
              ],
            ),
            
            const SizedBox(height: 30),
            _buildSwitchTile(Icons.dark_mode_outlined, l.darkMode, themeProvider.isDarkMode, (v) => themeProvider.setDarkMode(v), c),
            _buildSwitchTile(Icons.contrast_rounded, l.highContrast, _highContrast, (v) => setState(() => _highContrast = v), c),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, _TextSize size, bool isSelected, AppColors c) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSize = size),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2FF) : c.cardBg,
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

class PrivacySecuritySubScreen extends StatelessWidget {
  const PrivacySecuritySubScreen({super.key});

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
            _buildSecurityTile(Icons.lock_outline_rounded, l.passcodeBiometric, l.passcodeEnabled, Colors.green, c),
            _buildSecurityTile(Icons.password_rounded, l.changePasscode, '', null, c),
            _buildSecurityTile(Icons.security_rounded, l.twoFactorAuth, l.twoFactorDisabled, Colors.grey, c),
            _buildSecurityTile(Icons.data_usage_rounded, l.dataSharing, '', null, c),
            _buildSecurityTile(Icons.description_outlined, l.privacyPolicy, '', null, c),
            const SizedBox(height: 40),
            _buildLogoutButton(context, l),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTile(IconData icon, String label, String status, Color? statusColor, AppColors c) {
    return Container(
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

class EditProfileSubScreen extends StatelessWidget {
  const EditProfileSubScreen({super.key});

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
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/avatar.png')),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF7F56D9), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(l.fullNameLabel, l.userName, c),
            _buildTextField(l.mobileLabel, l.userMobile, c),
            _buildTextField(l.emailLabel, l.userEmail, c),
            _buildTextField(l.addressLabel, l.userAddress, c),
            const SizedBox(height: 40),
            _buildMainButton(l.saveChanges, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialVal, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.secondaryText)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialVal,
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

Widget _buildAllergyChip(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.warning_amber_rounded, color: color, size: 16),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    ]),
  );
}

Widget _buildAddChip(String label, AppColors c) {
  return Container(
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

Widget _buildContactTile(BuildContext context, String name, String phone, String tag, String img) {
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
        const SizedBox(width: 8),
        Icon(Icons.more_vert, size: 18, color: c.tertiaryText),
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
