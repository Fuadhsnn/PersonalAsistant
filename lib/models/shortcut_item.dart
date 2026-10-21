class ShortcutItem {
  final String id;
  final String title;
  final String url;
  final String category;
  final String iconCode; // 'briefcase', 'code', 'run', 'ai', 'video', 'globe'
  final int colorValue;

  const ShortcutItem({
    required this.id,
    required this.title,
    required this.url,
    required this.category,
    required this.iconCode,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'category': category,
        'iconCode': iconCode,
        'colorValue': colorValue,
      };

  factory ShortcutItem.fromJson(Map<String, dynamic> json) => ShortcutItem(
        id: json['id'] as String,
        title: json['title'] as String,
        url: json['url'] as String,
        category: json['category'] as String? ?? 'Umum',
        iconCode: json['iconCode'] as String? ?? 'globe',
        colorValue: json['colorValue'] as int? ?? 0xFF007AFF,
      );
}
