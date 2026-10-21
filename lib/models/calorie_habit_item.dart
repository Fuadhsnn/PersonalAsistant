class FoodPreset {
  final String name;
  final int calories;
  final String category; // 'Kopi & Minuman', 'Makanan Harian', 'Camilan & Protein'
  final String portionDesc;

  const FoodPreset({
    required this.name,
    required this.calories,
    required this.category,
    required this.portionDesc,
  });

  static const List<FoodPreset> indonesianPresets = [
    // Kopi & Minuman
    FoodPreset(name: 'Kopi Susu Jago (Aren)', calories: 195, category: 'Kopi & Minuman', portionDesc: '1 cup (susu & aren)'),
    FoodPreset(name: 'Kopi Jago Americano (No Sugar)', calories: 8, category: 'Kopi & Minuman', portionDesc: '1 cup hitam'),
    FoodPreset(name: 'Kopi Kenangan Mantan', calories: 215, category: 'Kopi & Minuman', portionDesc: '1 cup reguler'),
    FoodPreset(name: 'Kopi Susu Point Coffee', calories: 210, category: 'Kopi & Minuman', portionDesc: '1 cup'),
    FoodPreset(name: 'Susu Ultra Milk Cokelat 250ml', calories: 170, category: 'Kopi & Minuman', portionDesc: '1 kotak 250ml'),
    FoodPreset(name: 'Teh Botol Sosro Kotak', calories: 120, category: 'Kopi & Minuman', portionDesc: '1 kotak 250ml'),
    FoodPreset(name: 'Air Mineral 600ml', calories: 0, category: 'Kopi & Minuman', portionDesc: '1 botol'),

    // Makanan Harian & Warteg
    FoodPreset(name: 'Nasi Padang + Ayam Gulai', calories: 680, category: 'Makanan Harian', portionDesc: '1 bungkus + sayur & kuah'),
    FoodPreset(name: 'Nasi Padang + Rendang Daging', calories: 720, category: 'Makanan Harian', portionDesc: '1 bungkus + sambal ijo'),
    FoodPreset(name: 'Ayam Geprek + Nasi Putih', calories: 580, category: 'Makanan Harian', portionDesc: '1 porsi sambal korek'),
    FoodPreset(name: 'Nasi Goreng Telur Spesial', calories: 510, category: 'Makanan Harian', portionDesc: '1 piring'),
    FoodPreset(name: 'Warteg (Nasi + Telur Dadar + Orek Tempe)', calories: 430, category: 'Makanan Harian', portionDesc: '1 porsi hemat'),
    FoodPreset(name: 'Mie Dok-Dok / Indomie Rebus Telur', calories: 490, category: 'Makanan Harian', portionDesc: '1 mangkok + sawi'),
    FoodPreset(name: 'Sate Ayam Madura (10 tusuk)', calories: 420, category: 'Makanan Harian', portionDesc: '10 tusuk + bumbu kacang'),

    // Camilan & Fitness
    FoodPreset(name: 'Telur Rebus (2 Butir)', calories: 140, category: 'Camilan & Protein', portionDesc: '2 butir telur utuh'),
    FoodPreset(name: 'Dada Ayam Panggang 100g', calories: 165, category: 'Camilan & Protein', portionDesc: '100 gram matang'),
    FoodPreset(name: 'Pisang Cavendish / Sunpride', calories: 95, category: 'Camilan & Protein', portionDesc: '1 buah sedang'),
    FoodPreset(name: 'Whey Protein Shake', calories: 120, category: 'Camilan & Protein', portionDesc: '1 scoop + air'),
    FoodPreset(name: 'Roti Aoka Cokelat', calories: 210, category: 'Camilan & Protein', portionDesc: '1 bungkus'),
    FoodPreset(name: 'Tahu / Tempe Goreng (2 potong)', calories: 180, category: 'Camilan & Protein', portionDesc: '2 potong gorengan'),
  ];
}

class CalorieLog {
  final String id;
  final String foodName;
  final int calories;
  final String mealType; // 'Sarapan', 'Makan Siang', 'Makan Malam', 'Camilan/Kopi'
  final DateTime dateTime;

  CalorieLog({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.mealType,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'foodName': foodName,
        'calories': calories,
        'mealType': mealType,
        'dateTime': dateTime.toIso8601String(),
      };

  factory CalorieLog.fromJson(Map<String, dynamic> json) => CalorieLog(
        id: json['id'] as String,
        foodName: json['foodName'] as String,
        calories: json['calories'] as int,
        mealType: json['mealType'] as String? ?? 'Camilan/Kopi',
        dateTime: DateTime.parse(json['dateTime'] as String),
      );
}

class HabitItem {
  final String id;
  final String title;
  final String iconCode;
  final int colorValue;
  final List<String> completedDateStrings; // 'yyyy-MM-dd'

  HabitItem({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.colorValue,
    List<String>? completedDateStrings,
  }) : completedDateStrings = completedDateStrings ?? [];

  bool isCompletedToday() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return completedDateStrings.contains(todayStr);
  }

  HabitItem toggleToday() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final updated = List<String>.from(completedDateStrings);
    if (updated.contains(todayStr)) {
      updated.remove(todayStr);
    } else {
      updated.add(todayStr);
    }
    return HabitItem(
      id: id,
      title: title,
      iconCode: iconCode,
      colorValue: colorValue,
      completedDateStrings: updated,
    );
  }

  int get currentStreak {
    if (completedDateStrings.isEmpty) return 0;
    final now = DateTime.now();
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    final todayStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
    if (!completedDateStrings.contains(todayStr)) {
      // Check yesterday if not completed today yet
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (completedDateStrings.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconCode': iconCode,
        'colorValue': colorValue,
        'completedDateStrings': completedDateStrings,
      };

  factory HabitItem.fromJson(Map<String, dynamic> json) => HabitItem(
        id: json['id'] as String,
        title: json['title'] as String,
        iconCode: json['iconCode'] as String? ?? 'flame',
        colorValue: json['colorValue'] as int? ?? 0xFFFF9500,
        completedDateStrings: (json['completedDateStrings'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}
