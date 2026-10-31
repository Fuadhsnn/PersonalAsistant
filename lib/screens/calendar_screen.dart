import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/calendar_event_item.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_burger_icon.dart';

class CalendarScreen extends StatefulWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;

  const CalendarScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  List<CalendarEventItem> _getEventsForDate(DateTime date) {
    return widget.state.calendarEvents.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
  }

  void _openAddEventModal([CalendarEventItem? initialEvent]) {
    final isDark = widget.state.isDarkMode;
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddEventSheet(
        state: widget.state,
        initialEvent: initialEvent,
        initialDate: _selectedDate,
        isDark: isDark,
      ),
    );
  }

  void _confirmDeleteEvent(CalendarEventItem event) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Hapus Acara?'),
        content: Text('Jadwal "${event.title}" akan dihapus dari sistem.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Hapus'),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.state.deleteCalendarEvent(event.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final selectedEvents = _getEventsForDate(_selectedDate);
    final milestones = widget.state.upcomingMilestones;

    return CupertinoTheme(
      data: AppleTheme.cupertinoTheme(isDark),
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            fontFamily: GoogleFonts.inter().fontFamily,
            color: AppleColors.textPrimary(isDark),
            fontSize: 14,
          ),
          child: CupertinoPageScaffold(
            backgroundColor: AppleColors.bg(isDark),
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. Top Bar
                        _buildTopBar(isDark),
                        const SizedBox(height: 14),

                        // 2. Milestone H-7 Countdown Card (if available)
                        if (milestones.isNotEmpty) ...[
                          _buildMilestoneCard(milestones.first, isDark),
                          const SizedBox(height: 14),
                        ],

                        // 3. Apple HIG Monthly Calendar Grid
                        _buildCalendarGrid(isDark),
                        const SizedBox(height: 20),

                        // 4. Agenda Header for Selected Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate.year == DateTime.now().year &&
                                      _selectedDate.month == DateTime.now().month &&
                                      _selectedDate.day == DateTime.now().day
                                  ? 'Agenda Hari Ini (${DateFormat('EEEE, d MMM', 'id_ID').format(_selectedDate)})'
                                  : 'Agenda ${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: AppleColors.textPrimary(isDark),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              onPressed: () => _openAddEventModal(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.add_circled_solid,
                                    size: 15,
                                    color: AppleColors.electricBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tambah Acara',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppleColors.electricBlue,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 5. Daily Events List
                        if (selectedEvents.isEmpty)
                          _buildEmptyAgenda(isDark)
                        else
                          ...selectedEvents.map((e) => _buildEventCard(e, isDark)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    final isSynced = widget.state.isGoogleCalendarSynced;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: widget.onOpenDrawer,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppleColors.card(isDark),
              shape: BoxShape.circle,
              border: Border.all(color: AppleColors.cardBorder(isDark), width: 1),
            ),
            child: Center(
              child: AppleBurgerIcon(
                color: AppleColors.textPrimary(isDark),
                size: 18,
              ),
            ),
          ),
        ),

        Text(
          'Kalender & Jadwal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppleColors.textPrimary(isDark),
            decoration: TextDecoration.none,
          ),
        ),

        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            widget.state.toggleGoogleCalendarSync();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppleColors.card(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppleColors.cardBorder(isDark), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Google',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.textPrimary(isDark),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isSynced ? AppleColors.systemGreen : AppleColors.textSecondary(isDark),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(CalendarEventItem event, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppleColors.systemRed.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x06000000),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppleColors.textPrimary(isDark),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(event.startTime)} WIB (${event.location.isNotEmpty ? event.location : 'Milestone Utama'})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppleColors.systemRed,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppleColors.systemRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              event.milestoneBadge,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: CupertinoColors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = _currentMonth.weekday; // 1 = Mon, 7 = Sun
    // Align with MIN (Sunday = 0, Mon = 1, ...)
    final offset = firstWeekday % 7;
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final monthTitle = DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppleColors.cardBorder(isDark), width: 1),
      ),
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppleColors.textPrimary(isDark),
                  decoration: TextDecoration.none,
                ),
              ),
              Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(6),
                    minimumSize: Size.zero,
                    onPressed: _previousMonth,
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      size: 16,
                      color: AppleColors.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.all(6),
                    minimumSize: Size.zero,
                    onPressed: _nextMonth,
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: AppleColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day Names Row (MIN, SEN, SEL, RAB, KAM, JUM, SAB)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'].map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppleColors.textSecondary(isDark),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Dates Grid
          Column(
            children: List.generate(rows, (r) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (c) {
                    final index = r * 7 + c;
                    final dayNum = index - offset + 1;

                    if (dayNum < 1 || dayNum > daysInMonth) {
                      return const Expanded(child: SizedBox());
                    }

                    final cellDate = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                    final isSelected = cellDate.year == _selectedDate.year &&
                        cellDate.month == _selectedDate.month &&
                        cellDate.day == _selectedDate.day;
                    final hasEvents = _getEventsForDate(cellDate).isNotEmpty;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = cellDate;
                          });
                        },
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected ? AppleColors.systemRed : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : AppleColors.textPrimary(isDark),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                if (hasEvents && !isSelected)
                                  Positioned(
                                    bottom: 2,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: AppleColors.systemRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEventItem event, bool isDark) {
    final hasMeet = event.meetLink != null && event.meetLink!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppleColors.cardBorder(isDark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.textPrimary(isDark),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1D1F27) : const Color(0xFFF0F2F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.category,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.electricBlue,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            event.formattedTimeRange,
            style: TextStyle(
              fontSize: 11,
              color: AppleColors.textSecondary(isDark),
              decoration: TextDecoration.none,
            ),
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 11,
                color: AppleColors.textSecondary(isDark),
                decoration: TextDecoration.none,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasMeet)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () => _launchUrl(event.meetLink!),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.video_camera_solid, size: 14, color: AppleColors.electricBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Google Meet (Buka Link)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppleColors.electricBlue,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                )
              else if (event.location.isNotEmpty)
                Row(
                  children: [
                    Icon(CupertinoIcons.location_solid, size: 12, color: AppleColors.textSecondary(isDark)),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppleColors.textSecondary(isDark),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(),

              Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(4),
                    minimumSize: Size.zero,
                    onPressed: () => _openAddEventModal(event),
                    child: Icon(
                      CupertinoIcons.pencil,
                      size: 15,
                      color: AppleColors.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.all(4),
                    minimumSize: Size.zero,
                    onPressed: () => _confirmDeleteEvent(event),
                    child: const Icon(
                      CupertinoIcons.trash,
                      size: 15,
                      color: AppleColors.systemRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAgenda(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppleColors.cardBorder(isDark), width: 1),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.calendar_badge_plus,
              size: 32,
              color: AppleColors.textSecondary(isDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada jadwal pada tanggal ini',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppleColors.textPrimary(isDark),
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "+ Tambah Acara" untuk menjadwalkan agenda baru.',
              style: TextStyle(
                fontSize: 11,
                color: AppleColors.textSecondary(isDark),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEventSheet extends StatefulWidget {
  final DashboardState state;
  final CalendarEventItem? initialEvent;
  final DateTime initialDate;
  final bool isDark;

  const _AddEventSheet({
    required this.state,
    this.initialEvent,
    required this.initialDate,
    required this.isDark,
  });

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _meetLinkController;
  late TextEditingController _aiPromptController;

  late DateTime _startDateTime;
  late DateTime _endDateTime;
  late String _category;
  late bool _isMilestone;
  bool _isAiParsing = false;

  @override
  void initState() {
    super.initState();
    final ev = widget.initialEvent;
    if (ev != null) {
      _titleController = TextEditingController(text: ev.title);
      _descController = TextEditingController(text: ev.description);
      _locationController = TextEditingController(text: ev.location);
      _meetLinkController = TextEditingController(text: ev.meetLink ?? '');
      _startDateTime = ev.startTime;
      _endDateTime = ev.endTime;
      _category = ev.category;
      _isMilestone = ev.isMilestone;
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _locationController = TextEditingController();
      _meetLinkController = TextEditingController();
      _startDateTime = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
        DateTime.now().hour + 1,
        0,
      );
      _endDateTime = _startDateTime.add(const Duration(hours: 1));
      _category = 'Teknologi';
      _isMilestone = false;
    }
    _aiPromptController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _meetLinkController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _parseWithGemini() async {
    final text = _aiPromptController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAiParsing = true);
    final parsed = await widget.state.createEventFromNaturalLanguage(text);
    setState(() => _isAiParsing = false);

    if (parsed != null && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _saveEvent() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newEvent = CalendarEventItem(
      id: widget.initialEvent?.id ?? 'cal_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descController.text.trim(),
      startTime: _startDateTime,
      endTime: _endDateTime,
      location: _locationController.text.trim(),
      meetLink: _meetLinkController.text.trim().isNotEmpty
          ? _meetLinkController.text.trim()
          : null,
      category: _category,
      isMilestone: _isMilestone,
    );

    if (widget.initialEvent != null) {
      widget.state.updateCalendarEvent(newEvent);
    } else {
      widget.state.addCalendarEvent(newEvent);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Batal'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                widget.initialEvent != null ? 'Ubah Acara' : 'Acara Baru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppleColors.textPrimary(isDark),
                  decoration: TextDecoration.none,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveEvent,
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // AI Natural Language Quick Input Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16181E) : const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppleColors.electricBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.sparkles,
                            size: 14,
                            color: AppleColors.electricBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Jadwalkan Instan dengan Gemini AI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppleColors.electricBlue,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CupertinoTextField(
                        controller: _aiPromptController,
                        placeholder: 'Contoh: Rapat evaluasi besok jam 14:00 di Google Meet',
                        placeholderStyle: TextStyle(
                          color: AppleColors.textSecondary(isDark),
                          fontSize: 12,
                        ),
                        style: TextStyle(
                          color: AppleColors.textPrimary(isDark),
                          fontSize: 13,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppleColors.cardInset(isDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _isAiParsing ? null : _parseWithGemini,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppleColors.electricBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _isAiParsing
                                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                                : const Text(
                                    'Proses dengan AI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: CupertinoColors.white,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Manual Form
                Text(
                  'FORMULIR MANUAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppleColors.textSecondary(isDark),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),

                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Judul Acara',
                  style: TextStyle(color: AppleColors.textPrimary(isDark), fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppleColors.cardInset(isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 10),

                CupertinoTextField(
                  controller: _locationController,
                  placeholder: 'Lokasi (misal: Google Meet / Zoom / Kampus)',
                  style: TextStyle(color: AppleColors.textPrimary(isDark), fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppleColors.cardInset(isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 10),

                CupertinoTextField(
                  controller: _meetLinkController,
                  placeholder: 'Link Meeting (URL)',
                  style: TextStyle(color: AppleColors.textPrimary(isDark), fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppleColors.cardInset(isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 10),

                CupertinoTextField(
                  controller: _descController,
                  placeholder: 'Catatan & Deskripsi',
                  maxLines: 3,
                  style: TextStyle(color: AppleColors.textPrimary(isDark), fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppleColors.cardInset(isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 16),

                // Category selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppleColors.textPrimary(isDark),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: ['Teknologi', 'Karir', 'Finansial', 'Pribadi'].map((cat) {
                        final isSel = _category == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSel ? AppleColors.electricBlue : AppleColors.cardInset(isDark),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSel ? CupertinoColors.white : AppleColors.textSecondary(isDark),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Milestone Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppleColors.cardInset(isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadikan Milestone H-7',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppleColors.textPrimary(isDark),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            'Tampilkan banner countdown di Beranda',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppleColors.textSecondary(isDark),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      CupertinoSwitch(
                        value: _isMilestone,
                        activeTrackColor: AppleColors.systemRed,
                        onChanged: (val) => setState(() => _isMilestone = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

