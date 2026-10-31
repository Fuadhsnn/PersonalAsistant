import 'package:intl/intl.dart';

class CalendarEventItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String location;
  final String? meetLink;
  final String category;
  final String? colorHex;
  final bool isMilestone;

  const CalendarEventItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.location = '',
    this.meetLink,
    this.category = 'Teknologi',
    this.colorHex,
    this.isMilestone = false,
  });

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startTime.year == tomorrow.year &&
        startTime.month == tomorrow.month &&
        startTime.day == tomorrow.day;
  }

  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(startTime.year, startTime.month, startTime.day);
    return eventDay.difference(today).inDays;
  }

  String get milestoneBadge {
    final days = daysUntil;
    if (days == 0) return 'Hari H';
    if (days == 1) return 'H-1';
    if (days > 1 && days <= 7) return 'H-$days';
    return 'H-$days';
  }

  String get formattedTimeRange {
    if (isAllDay) return 'Sepanjang Hari';
    final startFmt = DateFormat('HH:mm').format(startTime);
    final endFmt = DateFormat('HH:mm').format(endTime);
    return '$startFmt - $endFmt WIB';
  }

  CalendarEventItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? location,
    String? meetLink,
    String? category,
    String? colorHex,
    bool? isMilestone,
  }) {
    return CalendarEventItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      meetLink: meetLink ?? this.meetLink,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      isMilestone: isMilestone ?? this.isMilestone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'location': location,
      'meetLink': meetLink,
      'category': category,
      'colorHex': colorHex,
      'isMilestone': isMilestone,
    };
  }

  factory CalendarEventItem.fromJson(Map<String, dynamic> json) {
    return CalendarEventItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Acara Tanpa Judul',
      description: json['description'] as String? ?? '',
      startTime: DateTime.tryParse(json['startTime'] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] as String? ?? '') ?? DateTime.now().add(const Duration(hours: 1)),
      isAllDay: json['isAllDay'] as bool? ?? false,
      location: json['location'] as String? ?? '',
      meetLink: json['meetLink'] as String?,
      category: json['category'] as String? ?? 'Teknologi',
      colorHex: json['colorHex'] as String?,
      isMilestone: json['isMilestone'] as bool? ?? false,
    );
  }
}

