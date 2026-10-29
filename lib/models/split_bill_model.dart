class SplitBillParticipant {
  final String id;
  final String name;
  final bool isPaid;
  final bool isMe;

  const SplitBillParticipant({
    required this.id,
    required this.name,
    this.isPaid = false,
    this.isMe = false,
  });

  SplitBillParticipant copyWith({
    String? id,
    String? name,
    bool? isPaid,
    bool? isMe,
  }) {
    return SplitBillParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      isPaid: isPaid ?? this.isPaid,
      isMe: isMe ?? this.isMe,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isPaid': isPaid,
        'isMe': isMe,
      };

  factory SplitBillParticipant.fromJson(Map<String, dynamic> json) {
    return SplitBillParticipant(
      id: json['id'] as String,
      name: json['name'] as String,
      isPaid: json['isPaid'] as bool? ?? false,
      isMe: json['isMe'] as bool? ?? false,
    );
  }
}

class SplitBillItem {
  final String id;
  final String name;
  final double qty;
  final double unitPrice;
  final double totalPrice;
  final List<String> assignedParticipantIds;

  const SplitBillItem({
    required this.id,
    required this.name,
    this.qty = 1.0,
    required this.unitPrice,
    required this.totalPrice,
    this.assignedParticipantIds = const [],
  });

  SplitBillItem copyWith({
    String? id,
    String? name,
    double? qty,
    double? unitPrice,
    double? totalPrice,
    List<String>? assignedParticipantIds,
  }) {
    return SplitBillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      assignedParticipantIds: assignedParticipantIds ?? this.assignedParticipantIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'qty': qty,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'assignedParticipantIds': assignedParticipantIds,
      };

  factory SplitBillItem.fromJson(Map<String, dynamic> json) {
    return SplitBillItem(
      id: json['id'] as String,
      name: json['name'] as String,
      qty: (json['qty'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      assignedParticipantIds: (json['assignedParticipantIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class ParticipantItemShare {
  final SplitBillItem item;
  final double shareAmount;
  final int totalSharers;

  const ParticipantItemShare({
    required this.item,
    required this.shareAmount,
    required this.totalSharers,
  });
}

class ParticipantBreakdown {
  final SplitBillParticipant participant;
  final List<ParticipantItemShare> itemShares;
  final double rawSubtotal;
  final double taxAndService;
  final double discount;
  int finalTotal;
  final bool isPaid;

  ParticipantBreakdown({
    required this.participant,
    required this.itemShares,
    required this.rawSubtotal,
    required this.taxAndService,
    required this.discount,
    required this.finalTotal,
    required this.isPaid,
  });
}

class SplitBillSession {
  final String id;
  final String merchantName;
  final DateTime createdAt;
  final List<SplitBillItem> items;
  final List<SplitBillParticipant> participants;
  final double subtotal;
  final double taxAmount;
  final double serviceAmount;
  final double discountAmount;
  final double grandTotal;
  final bool isEqualSplit;

  const SplitBillSession({
    required this.id,
    required this.merchantName,
    required this.createdAt,
    this.items = const [],
    this.participants = const [],
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.serviceAmount = 0.0,
    this.discountAmount = 0.0,
    this.grandTotal = 0.0,
    this.isEqualSplit = false,
  });

  double get computedItemsSubtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isFormulaBalanced {
    final expectedTotal = (subtotal + taxAmount + serviceAmount - discountAmount).round();
    return expectedTotal == grandTotal.round();
  }

  int get paidCount => participants.where((p) => p.isPaid).length;

  SplitBillSession copyWith({
    String? id,
    String? merchantName,
    DateTime? createdAt,
    List<SplitBillItem>? items,
    List<SplitBillParticipant>? participants,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? discountAmount,
    double? grandTotal,
    bool? isEqualSplit,
  }) {
    return SplitBillSession(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      participants: participants ?? this.participants,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      isEqualSplit: isEqualSplit ?? this.isEqualSplit,
    );
  }

  List<ParticipantBreakdown> calculateBreakdowns() {
    if (participants.isEmpty) return [];

    final result = <ParticipantBreakdown>[];

    if (isEqualSplit) {
      final n = participants.length;
      final splitGrandTotal = (grandTotal / n).round();
      final splitSubtotal = subtotal / n;
      final splitTaxService = (taxAmount + serviceAmount) / n;
      final splitDiscount = discountAmount / n;

      for (final p in participants) {
        result.add(
          ParticipantBreakdown(
            participant: p,
            itemShares: const [],
            rawSubtotal: splitSubtotal,
            taxAndService: splitTaxService,
            discount: splitDiscount,
            finalTotal: splitGrandTotal,
            isPaid: p.isPaid,
          ),
        );
      }

      // Penny Gap adjustment
      final sumAll = result.fold(0, (sum, b) => sum + b.finalTotal);
      final gap = grandTotal.round() - sumAll;
      if (gap != 0 && result.isNotEmpty) {
        final meIdx = result.indexWhere((b) => b.participant.isMe);
        final targetIdx = meIdx != -1 ? meIdx : 0;
        result[targetIdx].finalTotal += gap;
      }
      return result;
    }

    // --- Mode: Split by Item ---
    // 1. Calculate assigned subtotal per participant
    final Map<String, List<ParticipantItemShare>> userShares = {
      for (final p in participants) p.id: [],
    };
    final Map<String, double> userRawSubtotals = {
      for (final p in participants) p.id: 0.0,
    };

    for (final item in items) {
      final assignees = item.assignedParticipantIds;
      if (assignees.isNotEmpty) {
        final sharePrice = item.totalPrice / assignees.length;
        for (final pId in assignees) {
          if (userShares.containsKey(pId)) {
            userShares[pId]!.add(
              ParticipantItemShare(
                item: item,
                shareAmount: sharePrice,
                totalSharers: assignees.length,
              ),
            );
            userRawSubtotals[pId] = (userRawSubtotals[pId] ?? 0.0) + sharePrice;
          }
        }
      }
    }

    final totalAssignedSubtotal = userRawSubtotals.values.fold(0.0, (a, b) => a + b);

    for (final p in participants) {
      final uSub = userRawSubtotals[p.id] ?? 0.0;
      final ratio = totalAssignedSubtotal > 0
          ? (uSub / totalAssignedSubtotal)
          : (1.0 / participants.length);

      final uTaxAndService = ratio * (taxAmount + serviceAmount);
      final uDiscount = ratio * discountAmount;
      final uTotalBeforeRound = (uSub + uTaxAndService - uDiscount);

      result.add(
        ParticipantBreakdown(
          participant: p,
          itemShares: userShares[p.id] ?? [],
          rawSubtotal: uSub,
          taxAndService: uTaxAndService,
          discount: uDiscount,
          finalTotal: uTotalBeforeRound.round(),
          isPaid: p.isPaid,
        ),
      );
    }

    // Penny Gap adjustment (Requirement C.3)
    final sumAll = result.fold(0, (sum, b) => sum + b.finalTotal);
    final gap = grandTotal.round() - sumAll;
    if (gap != 0 && result.isNotEmpty) {
      final meIdx = result.indexWhere((b) => b.participant.isMe);
      final targetIdx = meIdx != -1 ? meIdx : 0;
      result[targetIdx].finalTotal += gap;
    }

    return result;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchantName': merchantName,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'participants': participants.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'taxAmount': taxAmount,
        'serviceAmount': serviceAmount,
        'discountAmount': discountAmount,
        'grandTotal': grandTotal,
        'isEqualSplit': isEqualSplit,
      };

  factory SplitBillSession.fromJson(Map<String, dynamic> json) {
    return SplitBillSession(
      id: json['id'] as String,
      merchantName: json['merchantName'] as String? ?? 'Struk Belanja',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SplitBillItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => SplitBillParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      serviceAmount: (json['serviceAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      isEqualSplit: json['isEqualSplit'] as bool? ?? false,
    );
  }
}

