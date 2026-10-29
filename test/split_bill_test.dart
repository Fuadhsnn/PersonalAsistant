import 'package:flutter_test/flutter_test.dart';
import 'package:personal_assistant/models/split_bill_model.dart';

void main() {
  group('SplitBillSession Calculation Tests', () {
    test('Split by Item with shared item, tax, and penny gap', () {
      final participants = [
        const SplitBillParticipant(id: 'me', name: 'Hasan (Saya)', isMe: true),
        const SplitBillParticipant(id: 'p1', name: 'Budi'),
        const SplitBillParticipant(id: 'p2', name: 'Siti'),
      ];

      // Items:
      // 1. Hasan only: Nasi Goreng (25.000)
      // 2. Budi only: Mie Goreng (20.000)
      // 3. Shared by Hasan, Budi, Siti: Pizza (60.000 -> 20.000 each)
      final items = [
        const SplitBillItem(
          id: 'i1',
          name: 'Nasi Goreng',
          unitPrice: 25000,
          totalPrice: 25000,
          assignedParticipantIds: ['me'],
        ),
        const SplitBillItem(
          id: 'i2',
          name: 'Mie Goreng',
          unitPrice: 20000,
          totalPrice: 20000,
          assignedParticipantIds: ['p1'],
        ),
        const SplitBillItem(
          id: 'i3',
          name: 'Pizza',
          unitPrice: 60000,
          totalPrice: 60000,
          assignedParticipantIds: ['me', 'p1', 'p2'],
        ),
      ];

      // Subtotal = 25.000 + 20.000 + 60.000 = 105.000
      // Tax (10%) = 10.500
      // Service (5%) = 5.250
      // Discount = 5.000
      // Grand Total = 105.000 + 10.500 + 5.250 - 5.000 = 115.750
      final session = SplitBillSession(
        id: 's1',
        merchantName: 'Restoran Enak',
        createdAt: DateTime.now(),
        items: items,
        participants: participants,
        subtotal: 105000,
        taxAmount: 10500,
        serviceAmount: 5250,
        discountAmount: 5000,
        grandTotal: 115750,
        isEqualSplit: false,
      );

      final breakdowns = session.calculateBreakdowns();
      expect(breakdowns.length, 3);

      final hasan = breakdowns.firstWhere((b) => b.participant.id == 'me');
      final budi = breakdowns.firstWhere((b) => b.participant.id == 'p1');
      final siti = breakdowns.firstWhere((b) => b.participant.id == 'p2');

      // Hasan rawSubtotal: 25.000 + (60.000/3) = 45.000
      expect(hasan.rawSubtotal, 45000);
      // Budi rawSubtotal: 20.000 + (60.000/3) = 40.000
      expect(budi.rawSubtotal, 40000);
      // Siti rawSubtotal: (60.000/3) = 20.000
      expect(siti.rawSubtotal, 20000);

      // Verify Penny Gap: Sum of final totals must exactly equal Grand Total (115.750)
      final sumTotals = breakdowns.fold(0, (sum, b) => sum + b.finalTotal);
      expect(sumTotals, 115750);
    });

    test('Equal Split divides grand total with penny gap resolution', () {
      final participants = [
        const SplitBillParticipant(id: 'me', name: 'Hasan', isMe: true),
        const SplitBillParticipant(id: 'p1', name: 'Budi'),
        const SplitBillParticipant(id: 'p2', name: 'Siti'),
      ];

      // 100.000 divided by 3 = 33.333,33 each.
      // 33.333 * 3 = 99.999. Penny gap = 1!
      // Gap should be absorbed by 'me' -> Hasan gets 33.334, others 33.333.
      final session = SplitBillSession(
        id: 's2',
        merchantName: 'Kafe Kopi',
        createdAt: DateTime.now(),
        participants: participants,
        subtotal: 100000,
        taxAmount: 0,
        serviceAmount: 0,
        discountAmount: 0,
        grandTotal: 100000,
        isEqualSplit: true,
      );

      final breakdowns = session.calculateBreakdowns();
      expect(breakdowns.length, 3);

      final hasan = breakdowns.firstWhere((b) => b.participant.id == 'me');
      final budi = breakdowns.firstWhere((b) => b.participant.id == 'p1');
      final siti = breakdowns.firstWhere((b) => b.participant.id == 'p2');

      expect(hasan.finalTotal, 33334);
      expect(budi.finalTotal, 33333);
      expect(siti.finalTotal, 33333);

      final sumTotals = breakdowns.fold(0, (sum, b) => sum + b.finalTotal);
      expect(sumTotals, 100000);
    });
  });
}

