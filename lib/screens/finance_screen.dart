import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance_item.dart';
import '../models/split_bill_model.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../widgets/tactile_top_bar.dart';
import 'split_bill_screen.dart';

class FinanceScreen extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onOpenDrawer;
  final VoidCallback onBackToHome;

  const FinanceScreen({
    super.key,
    required this.state,
    required this.onOpenDrawer,
    required this.onBackToHome,
  });

  void _openEditWalletBalanceDialog(BuildContext context) {
    final controller = TextEditingController(
      text: state.walletStartingBalance > 0
          ? state.walletStartingBalance.toStringAsFixed(0)
          : '',
    );

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Atur Saldo Awal Wallet'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Masukkan saldo kas / tabungan awal Anda saat ini (Rupiah):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: 'Contoh: 10000000',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final val = double.tryParse(controller.text.replaceAll('.', ''));
              if (val != null && val >= 0) {
                state.setWalletStartingBalance(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _openAddTransactionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddTransactionModalSheet(state: state),
    );
  }

  void _openAddWishlistSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AddWishlistModalSheet(state: state),
    );
  }

  void _openSplitBill(BuildContext context, [SplitBillSession? session]) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => SplitBillScreen(
          state: state,
          initialSession: session,
        ),
      ),
    );
  }

  void _confirmDeleteSplitBill(BuildContext context, SplitBillSession session) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Hapus Sesi Split Bill?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Hapus riwayat patungan "${session.merchantName}"?'),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Hapus'),
            onPressed: () {
              state.deleteSplitBillSession(session.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _openAddSavingsSheet(BuildContext context, WishlistItem item) {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Tambah Tabungan: ${item.name}'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Masukkan nominal rupiah yang ingin dialokasikan:'),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: 'Contoh: 250000',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                state.updateWishlistSavings(item.id, val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final balance = state.currentNetBalance;
    final monthlyExpense = state.totalExpenseThisMonth;
    final runway = state.estimatedRunwayMonths;
    final transactions = state.finances;
    final wishlists = state.wishlists;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Navigation Bar (Option B: iOS Large Title Standard)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TactileTopBar(
              title: 'Keuangan & Runway',
              subtitle: 'Odometer dana darurat, runway job hunting, & alokasi wishlist',
              useLargeTitle: true,
              onOpenDrawer: onOpenDrawer,
              isDark: isDark,
              rightAction: TactileTopBar.actionButton(
                icon: const Icon(
                  CupertinoIcons.plus,
                  size: 20,
                  color: AppleColors.systemBlue,
                ),
                onPressed: () => _openAddTransactionSheet(context),
                isDark: isDark,
              ),
            ),
          ),
        ),

        // Apple Card Aesthetic Hero Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF232526), const Color(0xFF0F1011)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFE2E8F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? CupertinoColors.white.withOpacity(0.12)
                      : CupertinoColors.systemGrey4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(isDark ? 0.45 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Wallet',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppleColors.secondaryLabel(isDark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 22,
                            onPressed: () => _openEditWalletBalanceDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppleColors.systemBlue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.pencil, size: 11, color: AppleColors.systemBlue),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Ubah',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppleColors.systemBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppleColors.systemGreen.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppleColors.systemGreen.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, size: 14, color: AppleColors.systemGreen),
                            const SizedBox(width: 4),
                            Text(
                              'Runway: ${runway.toStringAsFixed(1)} Bulan',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppleColors.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openEditWalletBalanceDialog(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TOTAL KAS TERSEDIA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppleColors.secondaryLabel(isDark),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(CupertinoIcons.pencil_circle, size: 14, color: AppleColors.secondaryLabel(isDark)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(balance),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: AppleColors.label(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.userName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppleColors.label(isDark),
                        ),
                      ),
                      Text(
                        'Keluar Bln Ini: ${currencyFormat.format(monthlyExpense)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.secondaryLabel(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Section: Split Bill (ala GoPay)
        _buildSplitBillSection(context, isDark, currencyFormat),

        // Section: Wishlist & Savings Goals
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'TARGET WISHLIST & TABUNGAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 24,
                  onPressed: () => _openAddWishlistSheet(context),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.plus_circle_fill, size: 14, color: AppleColors.systemBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Tambah Target',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppleColors.systemBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = wishlists[index];
                return _buildWishlistCard(context, item, isDark, currencyFormat);
              },
              childCount: wishlists.length,
            ),
          ),
        ),

        // Section: Recent Transactions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Text(
                  'RIWAYAT TRANSAKSI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 24,
                  onPressed: () => _openAddTransactionSheet(context),
                  child: Text(
                    '+ Catat',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppleColors.systemBlue),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (transactions.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              child: Center(
                child: Text(
                  'Belum ada transaksi. Tap "+" untuk mencatat pengeluaran/pemasukan.',
                  style: TextStyle(fontSize: 13, color: AppleColors.secondaryLabel(isDark)),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final t = transactions[index];
                  return _buildTransactionTile(t, isDark, currencyFormat);
                },
                childCount: transactions.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  Widget _buildSplitBillSection(
    BuildContext context,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final splitBills = state.splitBills;
    final activeCount = splitBills.where((s) => s.paidCount < s.participants.length).length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: AppleColors.textPrimary(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Text(
                  'FITUR SPLIT BILL (ALA GOPAY)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
                if (activeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppleColors.systemOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$activeCount Belum Lunas',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppleColors.systemOrange,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 24,
                  onPressed: () => _openSplitBill(context),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.camera_viewfinder, size: 14, color: AppleColors.systemBlue),
                      const SizedBox(width: 4),
                      Text(
                        '+ Scan Struk',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppleColors.systemBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hero Card for Split Bill Feature
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openSplitBill(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E2433), const Color(0xFF131722)]
                        : [const Color(0xFFF1F6FE), const Color(0xFFE5EEFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? CupertinoColors.white.withValues(alpha: 0.1)
                        : AppleColors.systemBlue.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppleColors.systemBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        CupertinoIcons.doc_text_viewfinder,
                        color: AppleColors.systemBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Mulai Sesi Split Bill',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppleColors.textPrimary(isDark),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppleColors.systemPurple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Gemini AI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppleColors.systemPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Foto struk, pilih barang tiap orang, hitung pajak & salin ke WA.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppleColors.textSecondary(isDark),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      size: 18,
                      color: AppleColors.textTertiary(isDark),
                    ),
                  ],
                ),
              ),
            ),

            // If there are existing split bill sessions, show recent list
            if (splitBills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Column(
                children: splitBills.take(3).map((session) {
                  return _buildSplitBillSessionTile(context, session, isDark, currencyFormat);
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildSplitBillSessionTile(
    BuildContext context,
    SplitBillSession session,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final isAllPaid = session.paidCount == session.participants.length && session.participants.isNotEmpty;
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openSplitBill(context, session),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppleColors.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppleColors.separator(isDark)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isAllPaid ? AppleColors.systemGreen : AppleColors.systemOrange).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAllPaid ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.clock_fill,
                color: isAllPaid ? AppleColors.systemGreen : AppleColors.systemOrange,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.merchantName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppleColors.label(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dateFormat.format(session.createdAt)} • ${session.participants.length} orang',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppleColors.secondaryLabel(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(session.grandTotal),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppleColors.label(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isAllPaid ? AppleColors.systemGreen : AppleColors.systemOrange).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${session.paidCount}/${session.participants.length} Lunas',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isAllPaid ? AppleColors.systemGreen : AppleColors.systemOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 24,
              onPressed: () => _confirmDeleteSplitBill(context, session),
              child: Icon(
                CupertinoIcons.trash,
                size: 16,
                color: AppleColors.textTertiary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistCard(
    BuildContext context,
    WishlistItem item,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final progress = item.progress;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(18),
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
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.label(isDark),
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 24,
                onPressed: () => _openAddSavingsSheet(context, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppleColors.systemBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ Tabung',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppleColors.systemBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 24,
                onPressed: () => state.deleteWishlistItem(item.id),
                child: const Icon(CupertinoIcons.trash, size: 14, color: AppleColors.systemRed),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
              valueColor: AlwaysStoppedAnimation<Color>(
                item.isAchieved ? AppleColors.systemGreen : AppleColors.systemBlue,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terkumpul: ${currencyFormat.format(item.savedAmount)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppleColors.secondaryLabel(isDark),
                ),
              ),
              Text(
                'Target: ${currencyFormat.format(item.targetPrice)} (${(progress * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: item.isAchieved ? AppleColors.systemGreen : AppleColors.label(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
    FinanceTransaction t,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final dateFormat = DateFormat('d MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppleColors.cardBg(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppleColors.separator(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (t.isExpense ? AppleColors.systemRed : AppleColors.systemGreen).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              t.isExpense ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 16,
              color: t.isExpense ? AppleColors.systemRed : AppleColors.systemGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppleColors.label(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${t.category} • ${dateFormat.format(t.date)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppleColors.secondaryLabel(isDark),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${t.isExpense ? '-' : '+'}${currencyFormat.format(t.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: t.isExpense ? AppleColors.systemRed : AppleColors.systemGreen,
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 24,
            onPressed: () => state.deleteFinanceTransaction(t.id),
            child: const Icon(CupertinoIcons.trash, size: 14, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}

class _AddTransactionModalSheet extends StatefulWidget {
  final DashboardState state;

  const _AddTransactionModalSheet({required this.state});

  @override
  State<_AddTransactionModalSheet> createState() => _AddTransactionModalSheetState();
}

class _AddTransactionModalSheetState extends State<_AddTransactionModalSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;
  String _category = 'Makan & Kopi';

  final List<String> _categories = [
    'Makan & Kopi',
    'Transport',
    'Belanja',
    'Tagihan',
    'Pemasukan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll('.', ''));
    if (title.isEmpty || amount == null || amount <= 0) return;

    final transaction = FinanceTransaction(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      isExpense: _isExpense,
      category: _category,
      date: DateTime.now(),
    );

    widget.state.addFinanceTransaction(transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = (screenHeight * 0.82).clamp(280.0, screenHeight - viewInsets.bottom - 44);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: AppleColors.label(isDark),
            fontSize: 14,
          ),
          child: Container(
            height: targetHeight,
            decoration: BoxDecoration(
              color: AppleColors.cardBg(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
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
                      'Catat Transaksi',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                        color: AppleColors.label(isDark),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _save,
                      child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Expense vs Income
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<bool>(
                        groupValue: _isExpense,
                        backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
                        thumbColor: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white,
                        children: {
                          true: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Pengeluaran (-)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                          ),
                          false: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Pemasukan (+)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppleColors.label(isDark),
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _isExpense = val;
                              if (!_isExpense) _category = 'Pemasukan';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Deskripsi Transaksi *', isDark),
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Contoh: Kopi Susu Jago, Isi Bensin, Gaji Freelance',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: _inputDecoration(isDark),
                      style: TextStyle(color: AppleColors.label(isDark)),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Nominal Rupiah (Rp) *', isDark),
                    CupertinoTextField(
                      controller: _amountController,
                      placeholder: 'Contoh: 35000',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: _inputDecoration(isDark),
                      style: TextStyle(color: AppleColors.label(isDark)),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Kategori', isDark),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: _inputDecoration(isDark),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category,
                          dropdownColor: AppleColors.cardBg(isDark),
                          isExpanded: true,
                          items: _categories.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: AppleColors.label(isDark),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          decoration: TextDecoration.none,
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

class _AddWishlistModalSheet extends StatefulWidget {
  final DashboardState state;

  const _AddWishlistModalSheet({required this.state});

  @override
  State<_AddWishlistModalSheet> createState() => _AddWishlistModalSheetState();
}

class _AddWishlistModalSheetState extends State<_AddWishlistModalSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _savedController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll('.', ''));
    final saved = double.tryParse(_savedController.text.replaceAll('.', '')) ?? 0.0;
    if (name.isEmpty || price == null || price <= 0) return;

    final item = WishlistItem(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      targetPrice: price,
      savedAmount: saved,
    );

    widget.state.addWishlistItem(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = (screenHeight * 0.82).clamp(280.0, screenHeight - viewInsets.bottom - 44);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: AppleColors.label(isDark),
            fontSize: 14,
          ),
          child: Container(
            height: targetHeight,
            decoration: BoxDecoration(
              color: AppleColors.cardBg(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
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
                        'Tambah Target Wishlist',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                          color: AppleColors.label(isDark),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _save,
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFieldLabel('Nama Barang / Target *', isDark),
                    CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Contoh: Garmin Forerunner, Sepatu Race Day, Laptop Baru',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: _inputDecoration(isDark),
                      style: TextStyle(color: AppleColors.label(isDark)),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Target Harga (Rp) *', isDark),
                    CupertinoTextField(
                      controller: _priceController,
                      placeholder: 'Contoh: 3500000',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: _inputDecoration(isDark),
                      style: TextStyle(color: AppleColors.label(isDark)),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Dana Terkumpul Awal (Rp)', isDark),
                    CupertinoTextField(
                      controller: _savedController,
                      placeholder: 'Contoh: 500000',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: _inputDecoration(isDark),
                      style: TextStyle(color: AppleColors.label(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          decoration: TextDecoration.none,
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
