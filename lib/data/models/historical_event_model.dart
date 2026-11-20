class HistoricalEventModel {
  final String year;
  final String month;
  final String day;
  final String event;

  HistoricalEventModel({
    required this.year,
    required this.month,
    required this.day,
    required this.event,
  });

  factory HistoricalEventModel.fromJson(Map<String, dynamic> json) {
    return HistoricalEventModel(
      year: json['year']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      event: json['event']?.toString() ?? 'Нет описания события',
    );
  }

  String get formattedDate {
    final parts = [
      if (day.isNotEmpty) day.padLeft(2, '0'),
      if (month.isNotEmpty) month.padLeft(2, '0'),
      if (year.isNotEmpty) '$year г.',
    ];
    return parts.isEmpty ? 'Дата неизвестна' : parts.join('.');
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
      'event': event,
    };
  }
}
