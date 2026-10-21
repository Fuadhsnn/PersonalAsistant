import 'package:flutter/cupertino.dart';
import '../theme/apple_colors.dart';

class CategoryPills extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onSelectCategory;
  final bool isDark;

  const CategoryPills({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.isDark,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Semua', 'icon': CupertinoIcons.sparkles},
    {'name': 'Kuliah', 'icon': CupertinoIcons.book_fill},
    {'name': 'Project', 'icon': CupertinoIcons.device_laptop},
    {'name': 'Pribadi', 'icon': CupertinoIcons.person_fill},
    {'name': 'Mendesak', 'icon': CupertinoIcons.bolt_fill},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected = selectedCategory == name;

          return CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => onSelectCategory(name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? CupertinoColors.white : CupertinoColors.black)
                    : (isDark ? AppleColors.darkCardSecondary : const Color(0xFFE5E5EA)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? (isDark ? CupertinoColors.black : CupertinoColors.white)
                        : AppleColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? CupertinoColors.black : CupertinoColors.white)
                          : AppleColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
