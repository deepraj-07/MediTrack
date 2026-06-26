import 'package:flutter/foundation.dart';
import 'package:meditrack/models/vital_reading.dart';

class VitalsProvider extends ChangeNotifier {
  final List<VitalReading> _readings = [];

  List<VitalReading> get readings => List.unmodifiable(_readings);

  List<VitalReading> getReadingsByType(String type) {
    return _readings.where((r) => r.type == type).toList();
  }

  void addReading(VitalReading reading) {
    _readings.add(reading);
    notifyListeners();
  }
}
