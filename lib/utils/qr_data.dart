import 'dart:convert';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/providers/profile_provider.dart';
import 'package:meditrack/models/vital_reading.dart';

class PatientQrData {
  final String name;
  final String nameEn;
  final String age;
  final String gender;
  final String mobile;
  final String email;
  final String address;
  final String bloodGroup;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> medicines;
  final List<EmergencyContact> emergencyContacts;
  final Map<String, VitalInfo> vitals;

  const PatientQrData({
    required this.name,
    required this.nameEn,
    required this.age,
    required this.gender,
    required this.mobile,
    required this.email,
    required this.address,
    required this.bloodGroup,
    required this.conditions,
    required this.allergies,
    required this.medicines,
    required this.emergencyContacts,
    required this.vitals,
  });

  Map<String, dynamic> toJson() => {
    'n': name,
    'ne': nameEn,
    'a': age,
    'g': gender,
    'm': mobile,
    'e': email,
    'ad': address,
    'bg': bloodGroup,
    'c': conditions,
    'al': allergies,
    'med': medicines,
    'ec': emergencyContacts.map((e) => e.toJson()).toList(),
    'v': vitals.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory PatientQrData.fromJson(Map<String, dynamic> json) => PatientQrData(
    name: json['n'] as String,
    nameEn: json['ne'] as String,
    age: json['a'] as String,
    gender: json['g'] as String,
    mobile: json['m'] as String,
    email: json['e'] as String,
    address: json['ad'] as String,
    bloodGroup: json['bg'] as String,
    conditions: List<String>.from(json['c']),
    allergies: List<String>.from(json['al']),
    medicines: List<String>.from(json['med']),
    emergencyContacts: (json['ec'] as List).map((e) => EmergencyContact.fromJson(e)).toList(),
    vitals: (json['v'] as Map<String, dynamic>).map((k, v) => MapEntry(k, VitalInfo.fromJson(v))),
  );

  String encode() => jsonEncode(toJson());

  static PatientQrData decode(String data) => PatientQrData.fromJson(jsonDecode(data) as Map<String, dynamic>);

  static PatientQrData fromLocalization(AppLocalizations l, List<VitalReading> vitals, ProfileProvider? profile) {
    final latestVitals = <String, VitalInfo>{};
    for (final type in ['bp', 'sugar', 'oxygen', 'temperature']) {
      final readings = vitals.where((r) => r.type == type).toList();
      if (readings.isNotEmpty) {
        final last = readings.last;
        String? unit;
        switch (type) {
          case 'bp': unit = 'mmHg'; break;
          case 'sugar': unit = 'mg/dL'; break;
          case 'oxygen': unit = '%'; break;
          case 'temperature': unit = '°F'; break;
        }
        latestVitals[type] = VitalInfo(latest: last.value, unit: unit ?? '');
      }
    }

    final pName = (profile != null && profile.name.isNotEmpty) ? profile.name : l.profileNameEn;
    final pMobile = (profile != null && profile.mobile.isNotEmpty) ? profile.mobile : l.userMobile;
    final pEmail = (profile != null && profile.email.isNotEmpty) ? profile.email : l.userEmail;
    final pAddress = (profile != null && profile.address.isNotEmpty) ? profile.address : l.userAddress;

    return PatientQrData(
      name: pName,
      nameEn: pName,
      age: '70 yrs',
      gender: l.userGender,
      mobile: pMobile,
      email: pEmail,
      address: pAddress,
      bloodGroup: l.userBloodGroup,
      conditions: [l.condHypertension, l.condDiabetes, l.condArthritis],
      allergies: [l.allergyDust, l.allergyPenicillin],
      medicines: [
        '${l.medAmlodipine} - ${l.medAmlodipineDose}',
        '${l.medMetformin} - ${l.dose1Pill}',
      ],
      emergencyContacts: [
        EmergencyContact(name: l.contactWife, phone: l.contactWifePhone),
        EmergencyContact(name: l.contactSon, phone: l.contactSonPhone),
        EmergencyContact(name: l.contactDaughter, phone: l.contactDaughterPhone),
      ],
      vitals: latestVitals,
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {'n': name, 'p': phone};

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(name: json['n'] as String, phone: json['p'] as String);
}

class VitalInfo {
  final String latest;
  final String unit;

  const VitalInfo({required this.latest, required this.unit});

  Map<String, dynamic> toJson() => {'l': latest, 'u': unit};

  factory VitalInfo.fromJson(Map<String, dynamic> json) =>
      VitalInfo(latest: json['l'] as String, unit: json['u'] as String);
}
