import 'package:meditrack/l10n/app_localizations.dart';

class InstructionHelper {
  static const String afterBreakfast = 'after_breakfast';
  static const String afterLunch = 'after_lunch';
  static const String afterDinner = 'after_dinner';
  static const String beforeSleep = 'before_sleep';
  static const String emptyStomach = 'empty_stomach';
  static const String dose1PillCode = 'dose_1_pill';

  static List<String> get allInstructionCodes =>
      [afterBreakfast, afterLunch, afterDinner, beforeSleep, emptyStomach];

  static String getInstructionText(AppLocalizations l, String? code) {
    switch (code) {
      case afterBreakfast:
        return l.instructionAfterBreakfast;
      case afterLunch:
        return l.instructionAfterLunch;
      case afterDinner:
        return l.instructionAfterDinner;
      case beforeSleep:
        return l.instructionBeforeSleep;
      case emptyStomach:
        return l.instructionEmptyStomach;
      default:
        return code ?? l.instructionAfterBreakfast;
    }
  }

  static String getDoseText(AppLocalizations l, String? dose) {
    if (dose == dose1PillCode) return l.dose1Pill;
    return dose ?? l.dose1Pill;
  }
}
