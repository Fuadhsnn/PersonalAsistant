import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_application.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/apple_burger_icon.dart';

class JobCrmScreen extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;

  const JobCrmScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
  });

  void _openAddJobSheet(BuildContext context, {JobApplication? existing}) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddJobModalSheet(state: state, existing: existing),
    );
  }

  void _showChangeStatusSheet(BuildContext context, JobApplication job) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Ubah Status Lamaran: ${job.company}'),
        message: const Text('Pilih tahapan proses rekrutmen saat ini'),
        actions: JobStatus.values.map((status) {
          final isCurrent = job.status == status;
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              state.updateJobStatus(job.id, status);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status.label,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: status.color,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 6),
                  const Icon(CupertinoIcons.checkmark_alt, size: 16),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final filteredJobs = state.filteredJobs;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Navigation Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 36,
                  onPressed: onBackToHome,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.chevron_back,
                        size: 22,
                        color: AppleColors.systemBlue,
                      ),
                      Text(
                        'Beranda',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppleColors.systemBlue,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 36,
                  onPressed: onOpenDrawer,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppleColors.cardBg(isDark),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppleColors.separator(isDark)),
                    ),
                    alignment: Alignment.center,
                    child: AppleBurgerIcon(
                      size: 18,
                      color: isDark ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 36,
                  onPressed: () => _openAddJobSheet(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppleColors.systemBlue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.plus,
                      size: 20,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Title Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Hunt CRM',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppleColors.label(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pipeline karir, tracking interview, & tindak lanjut lamaran',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),

        // KPI Summary Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    isDark,
                    title: 'Total Dilamar',
                    count: '${state.totalJobsCount}',
                    icon: Icons.work_rounded,
                    accentColor: AppleColors.systemBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    isDark,
                    title: 'Proses Aktif',
                    count: '${state.activeInterviewsCount}',
                    icon: Icons.sync_rounded,
                    accentColor: AppleColors.systemOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    isDark,
                    title: 'Offering 🏆',
                    count: '${state.offeringCount}',
                    icon: Icons.verified_rounded,
                    accentColor: AppleColors.systemGreen,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Status Filter Chips
        SliverToBoxAdapter(
          child: Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip('Semua', isDark),
                _buildFilterChip('Terkirim', isDark),
                _buildFilterChip('HR Screening', isDark),
                _buildFilterChip('Technical Test', isDark),
                _buildFilterChip('User Interview', isDark),
                _buildFilterChip('Offering 🏆', isDark),
                _buildFilterChip('Ditolak / Arsip', isDark),
              ],
            ),
          ),
        ),

        // Job Cards List
        if (filteredJobs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.briefcase,
                    size: 48,
                    color: AppleColors.tertiaryLabel(isDark),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada lamaran pada kategori ini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppleColors.label(isDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap tombol + di kanan atas untuk mencatat lamaran baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppleColors.secondaryLabel(isDark),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final job = filteredJobs[index];
                  return _buildJobCard(context, job, isDark);
                },
                childCount: filteredJobs.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  Widget _buildKpiCard(
    bool isDark, {
    required String title,
    required String count,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppleColors.separator(isDark)),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const Spacer(),
              Text(
                count,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppleColors.label(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppleColors.secondaryLabel(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = state.selectedJobStatusFilter == label;
    return GestureDetector(
      onTap: () => state.setJobStatusFilter(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppleColors.systemBlue
              : AppleColors.cardBg(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppleColors.systemBlue
                : AppleColors.separator(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? CupertinoColors.white
                : AppleColors.label(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobApplication job, bool isDark) {
    final dateFormat = DateFormat('d MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppleColors.separator(isDark)),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Company + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.company,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.position,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppleColors.systemBlue,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showChangeStatusSheet(context, job),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: job.status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: job.status.color.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: job.status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        job.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: job.status.color,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 10,
                        color: job.status.color,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Details Row: Work System & Salary
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildTag(job.workSystem, Icons.location_city_rounded, isDark),
              if (job.salaryExpectation.isNotEmpty)
                _buildTag(job.salaryExpectation, Icons.payments_rounded, isDark),
              if (job.cvVersion.isNotEmpty)
                _buildTag(job.cvVersion, Icons.description_rounded, isDark),
            ],
          ),

          // Follow-up alert if present
          if (job.followUpDate != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppleColors.systemOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppleColors.systemOrange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    size: 14,
                    color: AppleColors.systemOrange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tindak lanjut: ${dateFormat.format(job.followUpDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppleColors.systemOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Notes
          if (job.notes != null && job.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                job.notes!,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppleColors.label(isDark),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Footer: Applied date + Actions
          Row(
            children: [
              Text(
                'Dilamar: ${dateFormat.format(job.appliedDate)}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppleColors.secondaryLabel(isDark),
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 28,
                onPressed: () => _openAddJobSheet(context, existing: job),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.pencil, size: 14, color: AppleColors.systemBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(fontSize: 12, color: AppleColors.systemBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 28,
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Hapus Lamaran?'),
                      content: Text('Hapus catatan lamaran di ${job.company}? Tindakan ini tidak dapat dibatalkan.'),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(ctx);
                            state.deleteJobApplication(job.id);
                          },
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(CupertinoIcons.trash, size: 14, color: AppleColors.systemRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppleColors.secondaryLabel(isDark)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppleColors.label(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddJobModalSheet extends StatefulWidget {
  final DashboardState state;
  final JobApplication? existing;

  const _AddJobModalSheet({required this.state, this.existing});

  @override
  State<_AddJobModalSheet> createState() => _AddJobModalSheetState();
}

class _AddJobModalSheetState extends State<_AddJobModalSheet> {
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _salaryController;
  late TextEditingController _cvController;
  late TextEditingController _notesController;
  late TextEditingController _hrController;
  String _workSystem = 'Hybrid';
  JobStatus _status = JobStatus.applied;
  DateTime? _followUpDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _companyController = TextEditingController(text: e?.company ?? '');
    _positionController = TextEditingController(text: e?.position ?? '');
    _salaryController = TextEditingController(text: e?.salaryExpectation ?? '');
    _cvController = TextEditingController(text: e?.cvVersion ?? 'CV_Terbaru_Hasan.pdf');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _hrController = TextEditingController(text: e?.hrContact ?? '');
    _workSystem = e?.workSystem ?? 'Hybrid';
    _status = e?.status ?? JobStatus.applied;
    _followUpDate = e?.followUpDate;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _cvController.dispose();
    _notesController.dispose();
    _hrController.dispose();
    super.dispose();
  }

  void _save() {
    final company = _companyController.text.trim();
    final position = _positionController.text.trim();
    if (company.isEmpty || position.isEmpty) return;

    if (widget.existing != null) {
      widget.state.updateJobApplication(
        widget.existing!.copyWith(
          company: company,
          position: position,
          workSystem: _workSystem,
          salaryExpectation: _salaryController.text.trim(),
          cvVersion: _cvController.text.trim(),
          status: _status,
          followUpDate: _followUpDate,
          notes: _notesController.text.trim(),
          hrContact: _hrController.text.trim(),
        ),
      );
    } else {
      final newJob = JobApplication(
        id: 'job_${DateTime.now().millisecondsSinceEpoch}',
        company: company,
        position: position,
        workSystem: _workSystem,
        salaryExpectation: _salaryController.text.trim(),
        cvVersion: _cvController.text.trim(),
        status: _status,
        appliedDate: DateTime.now(),
        followUpDate: _followUpDate,
        notes: _notesController.text.trim(),
        hrContact: _hrController.text.trim(),
      );
      widget.state.addJobApplication(newJob);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                Text(
                  widget.existing != null ? 'Edit Lamaran' : 'Tambah Lamaran',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.label(isDark),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _save,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Company
                _buildFieldLabel('Nama Perusahaan *', isDark),
                CupertinoTextField(
                  controller: _companyController,
                  placeholder: 'Contoh: GoTo, Traveloka, Shopee, Mandiri',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                // Position
                _buildFieldLabel('Posisi yang Dilamar *', isDark),
                CupertinoTextField(
                  controller: _positionController,
                  placeholder: 'Contoh: Data Analyst / Backend Engineer',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                // Work System Segmented
                _buildFieldLabel('Sistem Kerja', isDark),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSegmentedControl<String>(
                    groupValue: _workSystem,
                    children: const {
                      'Remote': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Remote')),
                      'Hybrid': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Hybrid')),
                      'On-site': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('On-site')),
                    },
                    onValueChanged: (val) {
                      setState(() => _workSystem = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Salary Expectation
                _buildFieldLabel('Ekspektasi Gaji', isDark),
                CupertinoTextField(
                  controller: _salaryController,
                  placeholder: 'Contoh: Rp 8.000.000 - 10.000.000',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 16),

                // Initial Status
                _buildFieldLabel('Tahapan Saat Ini', isDark),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: _inputDecoration(isDark),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<JobStatus>(
                      value: _status,
                      dropdownColor: AppleColors.cardBg(isDark),
                      isExpanded: true,
                      items: JobStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.label,
                            style: TextStyle(
                              color: s.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                _buildFieldLabel('Catatan & Kontak HR', isDark),
                CupertinoTextField(
                  controller: _notesController,
                  placeholder: 'Jadwal interview, link Hackerrank, atau nama interviewer...',
                  maxLines: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: _inputDecoration(isDark),
                  style: TextStyle(color: AppleColors.label(isDark)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppleColors.secondaryLabel(isDark),
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppleColors.separator(isDark)),
    );
  }
}
