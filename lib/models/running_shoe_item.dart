class ShoeItem {
  final String id;
  final String name;
  final String brand;
  final double currentKm;
  final double targetMaxKm;
  final int colorValue;
  final bool isRetired;

  ShoeItem({
    required this.id,
    required this.name,
    required this.brand,
    this.currentKm = 0.0,
    this.targetMaxKm = 600.0,
    required this.colorValue,
    this.isRetired = false,
  });

  double get wearPercentage => (currentKm / targetMaxKm).clamp(0.0, 1.0);

  ShoeItem addKm(double km) {
    return ShoeItem(
      id: id,
      name: name,
      brand: brand,
      currentKm: currentKm + km,
      targetMaxKm: targetMaxKm,
      colorValue: colorValue,
      isRetired: isRetired,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'currentKm': currentKm,
        'targetMaxKm': targetMaxKm,
        'colorValue': colorValue,
        'isRetired': isRetired,
      };

  factory ShoeItem.fromJson(Map<String, dynamic> json) => ShoeItem(
        id: json['id'] as String,
        name: json['name'] as String,
        brand: json['brand'] as String? ?? 'Nike',
        currentKm: (json['currentKm'] as num?)?.toDouble() ?? 0.0,
        targetMaxKm: (json['targetMaxKm'] as num?)?.toDouble() ?? 600.0,
        colorValue: json['colorValue'] as int? ?? 0xFF007AFF,
        isRetired: json['isRetired'] as bool? ?? false,
      );
}

class RunLog {
  final String id;
  final double distanceKm;
  final int durationMinutes;
  final String pace; // e.g. "5:24 /km"
  final String shoeId;
  final String shoeName;
  final DateTime date;
  final String? notes;

  RunLog({
    required this.id,
    required this.distanceKm,
    required this.durationMinutes,
    required this.pace,
    required this.shoeId,
    required this.shoeName,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'distanceKm': distanceKm,
        'durationMinutes': durationMinutes,
        'pace': pace,
        'shoeId': shoeId,
        'shoeName': shoeName,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory RunLog.fromJson(Map<String, dynamic> json) => RunLog(
        id: json['id'] as String,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        durationMinutes: json['durationMinutes'] as int? ?? 30,
        pace: json['pace'] as String? ?? '5:30 /km',
        shoeId: json['shoeId'] as String? ?? '',
        shoeName: json['shoeName'] as String? ?? 'Default Shoe',
        date: DateTime.parse(json['date'] as String),
        notes: json['notes'] as String?,
      );
}

class PersonalBest {
  final String distanceLabel; // '5 KM', '10 KM', '21 KM (Half)'
  final String time; // '24:15', '52:10', '1:58:30'
  final String pace;
  final String dateStr;

  const PersonalBest({
    required this.distanceLabel,
    required this.time,
    required this.pace,
    required this.dateStr,
  });

  Map<String, dynamic> toJson() => {
        'distanceLabel': distanceLabel,
        'time': time,
        'pace': pace,
        'dateStr': dateStr,
      };

  factory PersonalBest.fromJson(Map<String, dynamic> json) => PersonalBest(
        distanceLabel: json['distanceLabel'] as String,
        time: json['time'] as String,
        pace: json['pace'] as String,
        dateStr: json['dateStr'] as String,
      );
}
