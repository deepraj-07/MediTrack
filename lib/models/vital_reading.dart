class VitalReading {
  final String type;
  final String value;
  final String time;
  final String date;
  final DateTime timestamp;

  const VitalReading({
    required this.type,
    required this.value,
    required this.time,
    required this.date,
    required this.timestamp,
  });
}
