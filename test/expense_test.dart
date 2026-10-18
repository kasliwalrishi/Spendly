import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/main.dart';

void main() {
  test('expense serializes and restores its local fields', () {
    final expense = Expense(
      '1',
      'Lunch',
      250,
      'Food',
      DateTime(2026, 1, 2),
      'Team meal',
    );
    final restored = Expense.fromJson(expense.json);
    expect(restored.title, 'Lunch');
    expect(restored.amount, 250);
    expect(restored.category, 'Food');
    expect(restored.note, 'Team meal');
  });

  test('category totals combine local transactions', () {
    final items = [
      Expense('1', 'Coffee', 100, 'Food', DateTime(2026)),
      Expense('2', 'Lunch', 200, 'Food', DateTime(2026)),
    ];
    expect(totals(items)['Food'], 300);
  });

  testWidgets('spending insights renders a pie chart for expenses', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 210,
          child: Chart([
            Expense('1', 'Coffee', 100, 'Food', DateTime(2026, 1, 2)),
            Expense('2', 'Train', 200, 'Travel', DateTime(2026, 1, 3)),
          ]),
        ),
      ),
    );

    expect(find.byType(PieChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
