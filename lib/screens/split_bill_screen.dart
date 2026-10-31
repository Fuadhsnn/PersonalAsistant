import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/finance_item.dart';
import '../models/split_bill_model.dart';
import '../services/gemini_receipt_service.dart';
import '../state/dashboard_state.dart';
import '../theme/apple_colors.dart';
import '../theme/apple_theme.dart';

class SplitBillScreen extends StatefulWidget {
  final DashboardState state;
  final SplitBillSession? initialSession;

  const SplitBillScreen({
    super.key,
    required this.state,
    this.initialSession,
  });

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final GeminiReceiptService _geminiService = GeminiReceiptService();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0; // 0: Review Struk, 1: Partisipan & Assign, 2: Ringkasan
  bool _isScanning = false;
  String _scanStatusText = '';
  Uint8List? _previewImageBytes;

  // Struk form controllers
  late TextEditingController _merchantController;
  late TextEditingController _subtotalController;
  late TextEditingController _taxController;
  late TextEditingController _serviceController;
  late TextEditingController _discountController;
  late TextEditingController _grandTotalController;

  // Items & Participants
  List<SplitBillItem> _items = [];
  List<SplitBillParticipant> _participants = [];
  bool _isEqualSplit = false;
  String _sessionId = '';
  DateTime _createdAt = DateTime.now();

  // Participant adding controller
  final TextEditingController _newParticipantController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSession != null) {
      final s = widget.initialSession!;
      _sessionId = s.id;
      _createdAt = s.createdAt;
      _merchantController = TextEditingController(text: s.merchantName);
      _subtotalController = TextEditingController(text: s.subtotal.toStringAsFixed(0));
      _taxController = TextEditingController(text: s.taxAmount.toStringAsFixed(0));
      _serviceController = TextEditingController(text: s.serviceAmount.toStringAsFixed(0));
      _discountController = TextEditingController(text: s.discountAmount.toStringAsFixed(0));
      _grandTotalController = TextEditingController(text: s.grandTotal.toStringAsFixed(0));
      _items = List.from(s.items);
      _participants = List.from(s.participants);
      _isEqualSplit = s.isEqualSplit;
      _currentStep = 2; // Jump directly to summary for existing session
    } else {
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _merchantController = TextEditingController(text: 'Restoran / Kafe');
      _subtotalController = TextEditingController(text: '0');
      _taxController = TextEditingController(text: '0');
      _serviceController = TextEditingController(text: '0');
      _discountController = TextEditingController(text: '0');
      _grandTotalController = TextEditingController(text: '0');
      _participants = [
        SplitBillParticipant(
          id: 'me_${DateTime.now().millisecondsSinceEpoch}',
          name: '${widget.state.userName} (Saya)',
          isMe: true,
          isPaid: false,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _subtotalController.dispose();
    _taxController.dispose();
    _serviceController.dispose();
    _discountController.dispose();
    _grandTotalController.dispose();
    _newParticipantController.dispose();
    super.dispose();
  }

  SplitBillSession _buildCurrentSession() {
    final sub = double.tryParse(_subtotalController.text.replaceAll('.', '')) ?? 0.0;
    final tax = double.tryParse(_taxController.text.replaceAll('.', '')) ?? 0.0;
    final srv = double.tryParse(_serviceController.text.replaceAll('.', '')) ?? 0.0;
    final disc = double.tryParse(_discountController.text.replaceAll('.', '')) ?? 0.0;
    final grand = double.tryParse(_grandTotalController.text.replaceAll('.', '')) ?? 0.0;

    return SplitBillSession(
      id: _sessionId,
      merchantName: _merchantController.text.trim().isEmpty
          ? 'Struk Belanja'
          : _merchantController.text.trim(),
      createdAt: _createdAt,
      items: _items,
      participants: _participants,
      subtotal: sub,
      taxAmount: tax,
      serviceAmount: srv,
      discountAmount: disc,
      grandTotal: grand,
      isEqualSplit: _isEqualSplit,
    );
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _previewImageBytes = bytes;
      });

      await _executeGeminiScan(bytes);
    } catch (e) {
      _showErrorAlert('Gagal mengambil gambar: $e');
    }
  }

  Future<void> _executeGeminiScan(Uint8List bytes) async {
    String apiKey = widget.state.geminiApiKey;
    if (apiKey.isEmpty) {
      final enteredKey = await _showApiKeyInputDialog();
      if (enteredKey == null || enteredKey.isEmpty) return;
      apiKey = enteredKey;
    }

    setState(() {
      _isScanning = true;
      _scanStatusText = 'Membaca struk dengan Gemini Vision AI...';
    });

    try {
      final result = await _geminiService.parseReceiptImage(
        imageBytes: bytes,
        apiKey: apiKey,
      );

      final merchant = result['merchant_name']?.toString() ?? 'Restoran / Toko';
      final rawItems = result['items'] as List<dynamic>? ?? [];
      final subtotal = (result['subtotal'] as num?)?.toDouble() ?? 0.0;
      final tax = (result['tax_amount'] as num?)?.toDouble() ?? 0.0;
      final service = (result['service_amount'] as num?)?.toDouble() ?? 0.0;
      final discount = (result['discount_amount'] as num?)?.toDouble() ?? 0.0;
      final grandTotal = (result['grand_total'] as num?)?.toDouble() ?? 0.0;

      final newItems = <SplitBillItem>[];
      for (int i = 0; i < rawItems.length; i++) {
        final itemMap = rawItems[i] as Map<String, dynamic>;
        final name = itemMap['name']?.toString() ?? 'Item ${i + 1}';
        final qty = (itemMap['qty'] as num?)?.toDouble() ?? 1.0;
        final unitPrice = (itemMap['unit_price'] as num?)?.toDouble() ?? 0.0;
        final total = (itemMap['total_price'] as num?)?.toDouble() ?? (qty * unitPrice);

        newItems.add(
          SplitBillItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}_$i',
            name: name,
            qty: qty,
            unitPrice: unitPrice > 0 ? unitPrice : (qty > 0 ? total / qty : total),
            totalPrice: total,
            assignedParticipantIds: _participants.map((p) => p.id).toList(), // default assign to all
          ),
        );
      }

      setState(() {
        _merchantController.text = merchant;
        _items = newItems;
        _subtotalController.text = subtotal.toStringAsFixed(0);
        _taxController.text = tax.toStringAsFixed(0);
        _serviceController.text = service.toStringAsFixed(0);
        _discountController.text = discount.toStringAsFixed(0);
        _grandTotalController.text = grandTotal.toStringAsFixed(0);

        // If subtotal is 0 but items have prices, compute it
        if (subtotal == 0 && newItems.isNotEmpty) {
          final computedSub = newItems.fold(0.0, (s, it) => s + it.totalPrice);
          _subtotalController.text = computedSub.toStringAsFixed(0);
        }
        // If grandTotal is 0, compute expected
        if (grandTotal == 0) {
          final sub = double.tryParse(_subtotalController.text) ?? 0.0;
          final calc = sub + tax + service - discount;
          _grandTotalController.text = calc.toStringAsFixed(0);
        }
      });
    } catch (e) {
      _showErrorAlert('Gagal mengekstrak struk: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<String?> _showApiKeyInputDialog() async {
    final controller = TextEditingController(text: widget.state.geminiApiKey);
    return showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Masukkan Gemini API Key'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              const Text(
                'Gemini Vision AI membutuhkan API Key untuk mengekstrak foto struk secara akurat. Dapatkan gratis di aistudio.google.com',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: controller,
                placeholder: 'AIzaSy...',
                obscureText: true,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx, null),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Simpan & Lanjut'),
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                await widget.state.setGeminiApiKey(key);
                if (ctx.mounted) {
                  Navigator.pop(ctx, key);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showErrorAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Pemberitahuan'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message, style: const TextStyle(fontSize: 13)),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _openAddItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Tambah Item Pesanan'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              CupertinoTextField(
                controller: nameCtrl,
                placeholder: 'Nama menu / barang',
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: CupertinoTextField(
                      controller: qtyCtrl,
                      placeholder: 'Qty',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CupertinoTextField(
                      controller: priceCtrl,
                      placeholder: 'Total Harga (Rp)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Tambah'),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = double.tryParse(qtyCtrl.text.replaceAll('.', '')) ?? 1.0;
              final price = double.tryParse(priceCtrl.text.replaceAll('.', '')) ?? 0.0;

              if (name.isNotEmpty && price >= 0) {
                setState(() {
                  _items.add(
                    SplitBillItem(
                      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      qty: qty,
                      unitPrice: qty > 0 ? price / qty : price,
                      totalPrice: price,
                      assignedParticipantIds: _participants.map((p) => p.id).toList(),
                    ),
                  );
                  _recalculateSubtotalAndGrandTotal();
                });
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _recalculateSubtotalAndGrandTotal() {
    final computedSub = _items.fold(0.0, (sum, it) => sum + it.totalPrice);
    _subtotalController.text = computedSub.toStringAsFixed(0);

    final tax = double.tryParse(_taxController.text.replaceAll('.', '')) ?? 0.0;
    final srv = double.tryParse(_serviceController.text.replaceAll('.', '')) ?? 0.0;
    final disc = double.tryParse(_discountController.text.replaceAll('.', '')) ?? 0.0;

    final grand = computedSub + tax + srv - disc;
    _grandTotalController.text = (grand > 0 ? grand : 0).toStringAsFixed(0);
  }

  void _addParticipant() {
    final name = _newParticipantController.text.trim();
    if (name.isEmpty) return;

    final newP = SplitBillParticipant(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      isMe: false,
      isPaid: false,
    );

    setState(() {
      _participants.add(newP);
      _newParticipantController.clear();
      // Auto-assign new participant to all items if wanted, or leave to manual
    });
  }

  void _removeParticipant(String id) {
    setState(() {
      _participants.removeWhere((p) => p.id == id);
      // Remove from assigned items
      for (int i = 0; i < _items.length; i++) {
        final currentAssignees = List<String>.from(_items[i].assignedParticipantIds);
        currentAssignees.remove(id);
        _items[i] = _items[i].copyWith(assignedParticipantIds: currentAssignees);
      }
    });
  }

  void _toggleItemParticipant(SplitBillItem item, String participantId) {
    setState(() {
      final idx = _items.indexWhere((it) => it.id == item.id);
      if (idx == -1) return;

      final current = List<String>.from(_items[idx].assignedParticipantIds);
      if (current.contains(participantId)) {
        current.remove(participantId);
      } else {
        current.add(participantId);
      }
      _items[idx] = _items[idx].copyWith(assignedParticipantIds: current);
    });
  }

  void _toggleAllItemParticipants(SplitBillItem item) {
    setState(() {
      final idx = _items.indexWhere((it) => it.id == item.id);
      if (idx == -1) return;

      final isAllSelected = _items[idx].assignedParticipantIds.length == _participants.length;
      final updated = isAllSelected ? <String>[] : _participants.map((p) => p.id).toList();
      _items[idx] = _items[idx].copyWith(assignedParticipantIds: updated);
    });
  }

  void _copyWhatsAppSummary(SplitBillSession session, List<ParticipantBreakdown> breakdowns) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    buffer.writeln('🧾 *SPLIT BILL: ${session.merchantName}*');
    buffer.writeln('📅 ${dateFormat.format(session.createdAt)}');
    buffer.writeln('💰 Total Tagihan: ${_currencyFormat.format(session.grandTotal)}');
    buffer.writeln('────────────────────────');

    for (final b in breakdowns) {
      final pName = b.participant.name;
      final status = b.isPaid ? '✅ (LUNAS)' : '⏳ (Belum Bayar)';
      buffer.writeln('\n👤 *$pName* $status');

      if (!session.isEqualSplit && b.itemShares.isNotEmpty) {
        for (final share in b.itemShares) {
          final prefix = share.totalSharers > 1 ? '(1/${share.totalSharers} porsi) ' : '';
          buffer.writeln('   • ${share.item.name} $prefix- ${_currencyFormat.format(share.shareAmount)}');
        }
        if (b.taxAndService > 0) {
          buffer.writeln('   • Pajak & Service: +${_currencyFormat.format(b.taxAndService)}');
        }
        if (b.discount > 0) {
          buffer.writeln('   • Diskon: -${_currencyFormat.format(b.discount)}');
        }
      } else if (session.isEqualSplit) {
        buffer.writeln('   • Porsi Bagi Rata: ${_currencyFormat.format(b.finalTotal)}');
      }

      buffer.writeln('   👉 *TOTAL: ${_currencyFormat.format(b.finalTotal)}*');
    }

    buffer.writeln('\n────────────────────────');
    buffer.writeln('Rekap otomatis dibuat dengan Personal Assistant OS 📱✨');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Berhasil Disalin!'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Format rincian split bill telah disalin ke clipboard. Anda dapat langsung menempelkannya (paste) ke grup WhatsApp.',
            style: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _saveMyShareToFinance(ParticipantBreakdown myBreakdown, SplitBillSession session) {
    final myAmount = myBreakdown.finalTotal.toDouble();
    if (myAmount <= 0) return;

    final transaction = FinanceTransaction(
      id: 'tx_split_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Split Bill: ${session.merchantName}',
      amount: myAmount,
      isExpense: true,
      category: 'Makan & Kopi',
      date: DateTime.now(),
    );

    widget.state.addFinanceTransaction(transaction);

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Tercatat di Keuangan!'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Porsi Anda sebesar ${_currencyFormat.format(myAmount)} telah dicatat sebagai pengeluaran "Makan & Kopi" di dompet Anda.',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Selesai'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

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
            navigationBar: CupertinoNavigationBar(
              backgroundColor: AppleColors.card(isDark).withValues(alpha: 0.85),
              border: Border(bottom: BorderSide(color: AppleColors.separator(isDark))),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              widget.state.setFeature(AppFeature.finance);
            }
                  } else {
                    widget.state.setFeature(AppFeature.finance);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.chevron_back, color: AppleColors.systemBlue, size: 22),
                    const Text('Kembali', style: TextStyle(color: AppleColors.systemBlue, fontSize: 16)),
                  ],
                ),
              ),
              middle: Text(
                'Split Bill ala GoPay',
                style: TextStyle(
                  color: AppleColors.textPrimary(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              trailing: _currentStep == 2
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final session = _buildCurrentSession();
                        await widget.state.saveSplitBillSession(session);
                        if (!mounted) return;
                        nav.pop();
                      },
                    )
                  : null,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Stepper Navigation
                  _buildStepperHeader(isDark),

                  // Step Content
                  Expanded(
                    child: _buildCurrentStepContent(isDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppleColors.card(isDark),
        border: Border(bottom: BorderSide(color: AppleColors.separator(isDark))),
      ),
      child: Row(
        children: [
          _buildStepItem(0, '1. Struk & Item', isDark),
          _buildStepSeparator(isDark),
          _buildStepItem(1, '2. Partisipan', isDark),
          _buildStepSeparator(isDark),
          _buildStepItem(2, '3. Ringkasan', isDark),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepIndex, String title, bool isDark) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentStep = stepIndex;
          });
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppleColors.systemBlue
                    : (isDone
                        ? AppleColors.systemGreen.withValues(alpha: 0.2)
                        : AppleColors.separator(isDark)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDone)
                    const Icon(CupertinoIcons.checkmark, size: 12, color: AppleColors.systemGreen)
                  else
                    Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? CupertinoColors.white
                            : AppleColors.textSecondary(isDark),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      stepIndex == 0 ? 'Struk' : (stepIndex == 1 ? 'Bagi' : 'Tagihan'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? CupertinoColors.white
                            : (isDone
                                ? AppleColors.systemGreen
                                : AppleColors.textSecondary(isDark)),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepSeparator(bool isDark) {
    return Container(
      width: 16,
      height: 1,
      color: AppleColors.separator(isDark),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep1ReviewStruk(isDark);
      case 1:
        return _buildStep2AssignParticipants(isDark);
      case 2:
      default:
        return _buildStep3Summary(isDark);
    }
  }

  // ==========================================
  // STEP 1: REVIEW STRUK
  // ==========================================
  Widget _buildStep1ReviewStruk(bool isDark) {
    final sub = double.tryParse(_subtotalController.text.replaceAll('.', '')) ?? 0.0;
    final tax = double.tryParse(_taxController.text.replaceAll('.', '')) ?? 0.0;
    final srv = double.tryParse(_serviceController.text.replaceAll('.', '')) ?? 0.0;
    final disc = double.tryParse(_discountController.text.replaceAll('.', '')) ?? 0.0;
    final grand = double.tryParse(_grandTotalController.text.replaceAll('.', '')) ?? 0.0;

    final expectedGrand = (sub + tax + srv - disc).round();
    final hasFormulaMismatch = expectedGrand != grand.round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // AI Scan Action Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E2638), const Color(0xFF151821)]
                  : [const Color(0xFFEBF5FF), const Color(0xFFF3F4F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppleColors.systemBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppleColors.systemBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.camera_viewfinder,
                        color: AppleColors.systemBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pindai Struk dengan Gemini AI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppleColors.textPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Foto atau upload struk, AI mengekstrak semua menu & pajak.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppleColors.textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_isScanning) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CupertinoActivityIndicator(radius: 12),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _scanStatusText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.systemBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: AppleColors.systemBlue,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () => _pickAndScanImage(ImageSource.camera),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.camera, size: 18, color: CupertinoColors.white),
                            SizedBox(width: 6),
                            Text('Kamera',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: AppleColors.cardSecondary(isDark),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () => _pickAndScanImage(ImageSource.gallery),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.photo, size: 18, color: AppleColors.systemBlue),
                            const SizedBox(width: 6),
                            Text(
                              'Galeri',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppleColors.textPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (_previewImageBytes != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _previewImageBytes!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Merchant Name Input
        Text(
          'NAMA RESTORAN / MERCHANT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppleColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: _merchantController,
          placeholder: 'Contoh: Solaria / Kopi Kenangan',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          style: TextStyle(fontSize: 15, color: AppleColors.textPrimary(isDark)),
          decoration: BoxDecoration(
            color: AppleColors.card(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppleColors.separator(isDark)),
          ),
        ),

        const SizedBox(height: 20),

        // Section: Items List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DAFTAR ITEM PESANAN (${_items.length})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppleColors.textSecondary(isDark),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _openAddItemDialog,
              child: const Row(
                children: [
                  Icon(CupertinoIcons.plus_circle_fill, size: 16, color: AppleColors.systemBlue),
                  SizedBox(width: 4),
                  Text('Tambah Item',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.systemBlue)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppleColors.card(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppleColors.separator(isDark)),
            ),
            child: Column(
              children: [
                Icon(CupertinoIcons.doc_text, size: 36, color: AppleColors.textTertiary(isDark)),
                const SizedBox(height: 8),
                Text(
                  'Belum ada item pesanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppleColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Foto struk Anda di atas atau sentuh Tambah Item manual.',
                  style: TextStyle(fontSize: 12, color: AppleColors.textTertiary(isDark)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppleColors.card(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppleColors.separator(isDark)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (ctx, i) => Divider(
                height: 1,
                indent: 14,
                endIndent: 14,
                color: AppleColors.separator(isDark),
              ),
              itemBuilder: (ctx, i) {
                final item = _items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppleColors.cardSecondary(isDark),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 1)}x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppleColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppleColors.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Text(
                        _currencyFormat.format(item.totalPrice),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppleColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 24,
                        onPressed: () {
                          setState(() {
                            _items.removeAt(i);
                            _recalculateSubtotalAndGrandTotal();
                          });
                        },
                        child: const Icon(CupertinoIcons.trash,
                            size: 16, color: AppleColors.systemRed),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 24),

        // Section: Tax, Service & Totals
        Text(
          'RINCIAN SUBTOTAL & BIAYA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppleColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppleColors.card(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppleColors.separator(isDark)),
          ),
          child: Column(
            children: [
              _buildCostInputRow('Subtotal Item', _subtotalController, isDark, onValChanged: () {
                setState(() {});
              }),
              const SizedBox(height: 8),
              _buildCostInputRow('Pajak (PB1 / PPN)', _taxController, isDark, onValChanged: () {
                setState(() {});
              }),
              const SizedBox(height: 8),
              _buildCostInputRow('Biaya Layanan (Service)', _serviceController, isDark, onValChanged: () {
                setState(() {});
              }),
              const SizedBox(height: 8),
              _buildCostInputRow('Potongan Diskon / Promo', _discountController, isDark, onValChanged: () {
                setState(() {});
              }),
              Divider(height: 16, color: AppleColors.separator(isDark)),
              _buildCostInputRow(
                'Grand Total',
                _grandTotalController,
                isDark,
                isBold: true,
                onValChanged: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ),

        // Validation Warning Banner
        if (hasFormulaMismatch) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppleColors.systemOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppleColors.systemOrange.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle_fill,
                    color: AppleColors.systemOrange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Perhatian: Subtotal + Pajak + Service - Diskon (${_currencyFormat.format(expectedGrand)}) berbeda dengan Grand Total (${_currencyFormat.format(grand)}). Anda dapat menyesuaikan angkanya.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppleColors.systemOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),

        // Bottom CTA
        CupertinoButton(
          color: AppleColors.systemBlue,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(vertical: 14),
          onPressed: () {
            if (_items.isEmpty) {
              _showErrorAlert('Tambahkan minimal 1 item pesanan terlebih dahulu.');
              return;
            }
            setState(() {
              _currentStep = 1;
            });
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lanjut: Atur Partisipan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white)),
              SizedBox(width: 8),
              Icon(CupertinoIcons.arrow_right, size: 18, color: CupertinoColors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostInputRow(
    String label,
    TextEditingController controller,
    bool isDark, {
    bool isBold = false,
    VoidCallback? onValChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppleColors.textPrimary(isDark),
          ),
        ),
        SizedBox(
          width: 130,
          child: CupertinoTextField(
            controller: controller,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? AppleColors.systemBlue : AppleColors.textPrimary(isDark),
            ),
            decoration: BoxDecoration(
              color: AppleColors.cardSecondary(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            onChanged: (_) => onValChanged?.call(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: ASSIGN PARTICIPANTS & ITEMS
  // ==========================================
  Widget _buildStep2AssignParticipants(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Mode Selector: Split by Item vs Equal Split
        Container(
          decoration: BoxDecoration(
            color: AppleColors.cardSecondary(isDark),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEqualSplit = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isEqualSplit ? AppleColors.card(isDark) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: !_isEqualSplit
                          ? [
                              BoxShadow(
                                color: CupertinoColors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Pilih per Item (Detail)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !_isEqualSplit ? FontWeight.w700 : FontWeight.w500,
                        color: !_isEqualSplit
                            ? AppleColors.systemBlue
                            : AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEqualSplit = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isEqualSplit ? AppleColors.card(isDark) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _isEqualSplit
                          ? [
                              BoxShadow(
                                color: CupertinoColors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Bagi Rata (Equal)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isEqualSplit ? FontWeight.w700 : FontWeight.w500,
                        color: _isEqualSplit
                            ? AppleColors.systemBlue
                            : AppleColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section: Participants Management
        Text(
          'ANGGOTA PATUNGAN (${_participants.length})',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppleColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 8),

        // Input Add Participant
        Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _newParticipantController,
                placeholder: 'Ketik nama teman (misal: Budi)...',
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                style: TextStyle(fontSize: 14, color: AppleColors.textPrimary(isDark)),
                decoration: BoxDecoration(
                  color: AppleColors.card(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppleColors.separator(isDark)),
                ),
                onSubmitted: (_) => _addParticipant(),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppleColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              onPressed: _addParticipant,
              child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Participant Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _participants.map((p) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: p.isMe
                    ? AppleColors.systemBlue.withValues(alpha: 0.15)
                    : AppleColors.cardSecondary(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: p.isMe
                      ? AppleColors.systemBlue.withValues(alpha: 0.4)
                      : AppleColors.separator(isDark),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    p.isMe ? Icons.account_circle : Icons.person_outline,
                    size: 16,
                    color: p.isMe ? AppleColors.systemBlue : AppleColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: p.isMe ? FontWeight.w700 : FontWeight.w500,
                      color: p.isMe ? AppleColors.systemBlue : AppleColors.textPrimary(isDark),
                    ),
                  ),
                  if (!p.isMe) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeParticipant(p.id),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 16,
                        color: AppleColors.textTertiary(isDark),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        if (_isEqualSplit) ...[
          // Equal Split Info Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppleColors.card(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppleColors.separator(isDark)),
            ),
            child: Column(
              children: [
                const Icon(CupertinoIcons.equal_circle_fill,
                    size: 40, color: AppleColors.systemGreen),
                const SizedBox(height: 10),
                Text(
                  'Mode Bagi Rata Aktif',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seluruh total tagihan struk akan dibagi rata ke ${_participants.length} orang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppleColors.textSecondary(isDark)),
                ),
              ],
            ),
          ),
        ] else ...[
          // Item Assignment Section
          Text(
            'CENTANG SIAPA YANG MEMESAN / PATUNGAN ITEM',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppleColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = _items[i];
              final assignees = item.assignedParticipantIds;
              final numSharers = assignees.length;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppleColors.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: numSharers == 0
                        ? AppleColors.systemOrange.withValues(alpha: 0.6)
                        : AppleColors.separator(isDark),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Title & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 1)}x ${item.name}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppleColors.textPrimary(isDark),
                            ),
                          ),
                        ),
                        Text(
                          _currencyFormat.format(item.totalPrice),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppleColors.textPrimary(isDark),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Price per person badge
                    if (numSharers == 0)
                      Text(
                        '⚠️ Belum ada yang dipilih (pilih minimal 1 orang)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.systemOrange,
                        ),
                      )
                    else if (numSharers == 1)
                      Text(
                        'Khusus 1 orang: ${_currencyFormat.format(item.totalPrice)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppleColors.textSecondary(isDark),
                        ),
                      )
                    else
                      Text(
                        'Patungan $numSharers orang (${_currencyFormat.format(item.totalPrice / numSharers)} / orang)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.systemGreen,
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Choice chips per participant
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _participants.map((p) {
                        final isSelected = assignees.contains(p.id);
                        return GestureDetector(
                          onTap: () => _toggleItemParticipant(item, p.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppleColors.systemBlue
                                  : AppleColors.cardSecondary(isDark),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppleColors.systemBlue
                                    : AppleColors.separator(isDark),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(CupertinoIcons.checkmark,
                                      size: 12, color: CupertinoColors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : AppleColors.textPrimary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),

                    // Quick Toggle All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 20,
                          onPressed: () => _toggleAllItemParticipants(item),
                          child: Text(
                            numSharers == _participants.length
                                ? 'Kosongkan'
                                : 'Pilih Semua Teman (Shared)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppleColors.systemBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],

        const SizedBox(height: 28),

        // Bottom CTA
        CupertinoButton(
          color: AppleColors.systemBlue,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(vertical: 14),
          onPressed: () {
            setState(() {
              _currentStep = 2;
            });
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lihat Ringkasan & Tagihan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white)),
              SizedBox(width: 8),
              Icon(CupertinoIcons.arrow_right, size: 18, color: CupertinoColors.white),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 3: SUMMARY & SETTLEMENT
  // ==========================================
  Widget _buildStep3Summary(bool isDark) {
    final session = _buildCurrentSession();
    final breakdowns = session.calculateBreakdowns();
    final paidCount = breakdowns.where((b) => b.isPaid).length;

    ParticipantBreakdown? myBreakdown;
    try {
      myBreakdown = breakdowns.firstWhere((b) => b.participant.isMe);
    } catch (_) {}

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Summary Card Top
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E2430), const Color(0xFF10131A)]
                  : [const Color(0xFFF0F7FF), const Color(0xFFE2E8F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppleColors.separator(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.merchantName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppleColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: paidCount == breakdowns.length
                          ? AppleColors.systemGreen.withValues(alpha: 0.2)
                          : AppleColors.systemOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$paidCount/${breakdowns.length} Lunas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: paidCount == breakdowns.length
                            ? AppleColors.systemGreen
                            : AppleColors.systemOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Total Struk: ${_currencyFormat.format(session.grandTotal)} (${session.isEqualSplit ? 'Bagi Rata' : 'Per Item'})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppleColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section: Tagihan Per Orang
        Text(
          'TAGIHAN MASING-MASING ORANG',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppleColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 10),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: breakdowns.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final b = breakdowns[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppleColors.card(isDark),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: b.isPaid
                      ? AppleColors.systemGreen.withValues(alpha: 0.4)
                      : AppleColors.separator(isDark),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Person Name & Lunas Toggle Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            b.participant.isMe ? Icons.account_circle : Icons.person_rounded,
                            size: 22,
                            color: b.participant.isMe
                                ? AppleColors.systemBlue
                                : AppleColors.textSecondary(isDark),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            b.participant.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppleColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 28,
                        onPressed: () {
                          setState(() {
                            final idx = _participants.indexWhere((p) => p.id == b.participant.id);
                            if (idx != -1) {
                              _participants[idx] = _participants[idx].copyWith(
                                isPaid: !_participants[idx].isPaid,
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: b.isPaid
                                ? AppleColors.systemGreen
                                : AppleColors.cardSecondary(isDark),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: b.isPaid
                                  ? AppleColors.systemGreen
                                  : AppleColors.separator(isDark),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                b.isPaid
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons.circle,
                                size: 14,
                                color: b.isPaid
                                    ? CupertinoColors.white
                                    : AppleColors.textSecondary(isDark),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                b.isPaid ? 'Lunas' : 'Belum Lunas',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: b.isPaid
                                      ? CupertinoColors.white
                                      : AppleColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Items breakdown
                  if (!session.isEqualSplit && b.itemShares.isNotEmpty) ...[
                    ...b.itemShares.map((s) {
                      final shareNote = s.totalSharers > 1 ? '(1/${s.totalSharers} porsi)' : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${s.item.name} $shareNote',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppleColors.textSecondary(isDark),
                                ),
                              ),
                            ),
                            Text(
                              _currencyFormat.format(s.shareAmount),
                              style: TextStyle(
                                fontSize: 13,
                                color: AppleColors.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (b.taxAndService > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Porsi Pajak & Service',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppleColors.textSecondary(isDark),
                              ),
                            ),
                            Text(
                              '+ ${_currencyFormat.format(b.taxAndService)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppleColors.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (b.discount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Potongan Diskon',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppleColors.systemGreen,
                              ),
                            ),
                            Text(
                              '- ${_currencyFormat.format(b.discount)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppleColors.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Divider(height: 16, color: AppleColors.separator(isDark)),
                  ],

                  // Grand total for this person
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bayar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppleColors.textPrimary(isDark),
                        ),
                      ),
                      Text(
                        _currencyFormat.format(b.finalTotal),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppleColors.systemBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Action Buttons
        // 1. Copy WhatsApp Button
        CupertinoButton(
          color: const Color(0xFF25D366), // WhatsApp Green
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(vertical: 14),
          onPressed: () => _copyWhatsAppSummary(session, breakdowns),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.share, size: 20, color: CupertinoColors.white),
              SizedBox(width: 8),
              Text(
                'Salin Ringkasan WhatsApp',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 2. Add My Share to Finance Transaction
        if (myBreakdown != null)
          CupertinoButton(
            color: AppleColors.cardSecondary(isDark),
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(vertical: 14),
            onPressed: () => _saveMyShareToFinance(myBreakdown!, session),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.creditcard, size: 20, color: AppleColors.systemBlue),
                const SizedBox(width: 8),
                Text(
                  'Catat Bagian Saya (${_currencyFormat.format(myBreakdown.finalTotal)}) ke Keuangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 10),

        // 3. Save Session & Done
        CupertinoButton(
          color: AppleColors.systemBlue,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(vertical: 14),
          onPressed: () async {
            await widget.state.saveSplitBillSession(session);
            if (!mounted) return;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              widget.state.setFeature(AppFeature.finance);
            }
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.checkmark_alt, size: 20, color: CupertinoColors.white),
              SizedBox(width: 8),
              Text(
                'Simpan & Selesai',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
