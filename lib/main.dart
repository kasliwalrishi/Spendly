import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _navy = Color(0xFF14213D),
    _mint = Color(0xFF3DDC97),
    _ink = Color(0xFF1D2939),
    _canvas = Color(0xFFF7F9FC);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = Store();
  await store.load();
  runApp(SpendlyApp(store));
}

class Expense {
  const Expense(
    this.id,
    this.title,
    this.amount,
    this.category,
    this.date, [
    this.note = '',
  ]);
  final String id, title, category, note;
  final double amount;
  final DateTime date;
  Map<String, dynamic> get json => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'note': note,
  };
  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    j['id'] as String,
    j['title'] as String,
    (j['amount'] as num).toDouble(),
    j['category'] as String,
    DateTime.parse(j['date'] as String),
    j['note'] as String? ?? '',
  );
}

class Store extends ChangeNotifier {
  final List<Expense> _items = [];
  double budget = 0;
  List<Expense> get items =>
      List.of(_items)..sort((a, b) => b.date.compareTo(a.date));
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('expenses_v1');
    if (raw != null) {
      _items.addAll(
        (jsonDecode(raw) as List).map(
          (x) => Expense.fromJson(x as Map<String, dynamic>),
        ),
      );
    }
    budget = p.getDouble('budget_v1') ?? 0;
  }

  Future<void> _save() async => (await SharedPreferences.getInstance())
      .setString('expenses_v1', jsonEncode(_items.map((x) => x.json).toList()));
  Future<void> add(Expense e) async {
    _items.add(e);
    await _save();
    notifyListeners();
  }

  Future<void> update(Expense e) async {
    final i = _items.indexWhere((x) => x.id == e.id);
    if (i >= 0) _items[i] = e;
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((x) => x.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> setBudget(double value) async {
    budget = value;
    await (await SharedPreferences.getInstance()).setDouble('budget_v1', value);
    notifyListeners();
  }
}

class SpendlyApp extends StatelessWidget {
  const SpendlyApp(this.store, {super.key});
  final Store store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Spendly',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _mint,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _canvas,
      useMaterial3: true,
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'sans-serif',
        bodyColor: _ink,
        displayColor: _ink,
      ),
    ),
    home: Home(store),
  );
}

class Home extends StatefulWidget {
  const Home(this.store, {super.key});
  final Store store;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      Overview(widget.store),
      History(widget.store),
      Budget(widget.store),
    ];
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.store,
          builder: (_, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(.035, 0), end: Offset.zero)
                    .animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            ),
            child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      bottomNavigationBar: NavigationBar(
        height: 74,
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'Budget',
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, [Expense? old]) async {
    final result = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Editor(old),
    );
    if (result != null) {
      await (old == null
          ? widget.store.add(result)
          : widget.store.update(result));
    }
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final String title, subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium!
                    .copyWith(fontWeight: FontWeight.w800, letterSpacing: -.8),
              ),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(color: Colors.blueGrey.shade500)),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class Overview extends StatelessWidget {
  const Overview(this.store, {super.key});
  final Store store;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = store.items
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    final spent = month.fold(0.0, (sum, e) => sum + e.amount);
    final progress = store.budget == 0
        ? 0.0
        : (spent / store.budget).clamp(0.0, 1.0);
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        PageHeader(
          title: 'Spendly',
          subtitle: DateFormat('EEEE, d MMMM').format(now),
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: spent),
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_navy, Color(0xFF243B63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3314213D),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MONTHLY SPENDING',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    money(value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(_mint),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        store.budget == 0
                            ? 'No budget'
                            : '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    store.budget == 0
                        ? 'Set a budget to see your progress'
                        : money((store.budget - spent).abs()) +
                              ((store.budget - spent) >= 0
                                  ? ' left to spend'
                                  : ' over budget'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Spending insights',
            style: Theme.of(context).textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _Surface(child: SizedBox(height: 210, child: Chart(month))),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        if (store.items.isEmpty)
          const Empty()
        else
          ...store.items
              .take(5)
              .toList()
              .asMap()
              .entries
              .map(
                (entry) => AnimatedTransaction(
                  expense: entry.value,
                  delay: entry.key * 55,
                ),
              ),
      ],
    );
  }
}

class History extends StatelessWidget {
  const History(this.store, {super.key});
  final Store store;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 100),
    children: [
      const PageHeader(title: 'History', subtitle: 'Everything you have spent'),
      if (store.items.isEmpty)
        const Empty(
          text: 'No transactions yet. Your spending story starts here.',
        )
      else
        ...store.items.toList().asMap().entries.map(
          (entry) => Dismissible(
            key: ValueKey(entry.value.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              padding: const EdgeInsets.only(right: 22),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: const Color(0xFFF04438),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) => store.remove(entry.value.id),
            child: AnimatedTransaction(
              expense: entry.value,
              delay: entry.key * 35,
              onTap: () async {
                final changed = await showModalBottomSheet<Expense>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => Editor(entry.value),
                );
                if (changed != null) await store.update(changed);
              },
            ),
          ),
        ),
    ],
  );
}

class Budget extends StatelessWidget {
  const Budget(this.store, {super.key});
  final Store store;
  @override
  Widget build(BuildContext context) {
    final spent = store.items
        .where((e) {
          final d = DateTime.now();
          return e.date.year == d.year && e.date.month == d.month;
        })
        .fold(0.0, (sum, e) => sum + e.amount);
    final categoryRows = totals(store.items).entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: _Surface(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 3,
                ),
                leading: CircleAvatar(
                  backgroundColor: colorFor(entry.key).withValues(alpha: .12),
                  child: Icon(icon(entry.key), color: colorFor(entry.key)),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: Text(
                  money(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const PageHeader(
          title: 'Budget',
          subtitle: 'Plan each month with confidence',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This month',
                  style: Theme.of(context).textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        label: 'Budget',
                        value: money(store.budget),
                        color: _navy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Metric(
                        label: 'Spent',
                        value: money(spent),
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () => _budgetDialog(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(
                    store.budget == 0
                        ? 'Set monthly budget'
                        : 'Adjust monthly budget',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'By category',
            style: Theme.of(context).textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        ...categoryRows,
        if (store.items.isEmpty)
          const Empty(text: 'Category totals appear after your first expense.'),
      ],
    );
  }

  Future<void> _budgetDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: store.budget == 0 ? '' : store.budget.toStringAsFixed(0),
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly budget'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '₹ ',
            hintText: '0',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await store.setBudget(double.tryParse(controller.text) ?? 0);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ],
    ),
  );
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D101828),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class Chart extends StatelessWidget {
  const Chart(this.items, {super.key});
  final List<Expense> items;
  @override
  Widget build(BuildContext context) {
    final grouped = totals(items);
    if (grouped.isEmpty) {
      return const Empty(text: 'Your chart will appear here.');
    }
    final entries = grouped.entries.toList();
    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            // A non-zero initial value keeps fl_chart's pie data valid on the
            // first animation frame while preserving the existing reveal effect.
            tween: Tween(begin: .001, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (_, value, _) => PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 4,
                sections: List.generate(
                  entries.length,
                  (i) => PieChartSectionData(
                    value: entries[i].value * value,
                    color: colorFor(entries[i].key),
                    radius: 48,
                    showTitle: false,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: colorFor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            entry.key,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          money(entry.value),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class AnimatedTransaction extends StatelessWidget {
  const AnimatedTransaction({
    super.key,
    required this.expense,
    required this.delay,
    this.onTap,
  });
  final Expense expense;
  final int delay;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 350 + delay),
    curve: Curves.easeOutCubic,
    builder: (_, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - value)),
        child: child,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: _Surface(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: colorFor(expense.category)
                    .withValues(alpha: .12),
                child: Icon(
                  icon(expense.category),
                  color: colorFor(expense.category),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${expense.category} • ${DateFormat('d MMM').format(expense.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                money(expense.amount),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class Editor extends StatefulWidget {
  const Editor(this.old, {super.key});
  final Expense? old;
  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  static const categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Health',
    'Other',
  ];
  late final title = TextEditingController(text: widget.old?.title ?? '');
  late final amount = TextEditingController(
    text: widget.old?.amount.toString() ?? '',
  );
  late final note = TextEditingController(text: widget.old?.note ?? '');
  late String category = widget.old?.category ?? categories.first;
  late DateTime date = widget.old?.date ?? DateTime.now();
  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      4,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.old == null ? 'New expense' : 'Edit expense',
            style: Theme.of(context).textTheme.headlineSmall!
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: title,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'What was it for?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories
                .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                .toList(),
            onChanged: (x) => setState(() => category = x!),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat.yMMMd().format(date)),
            trailing: const Icon(Icons.calendar_month_outlined),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => date = picked);
            },
          ),
          TextField(
            controller: note,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _navy,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _submit,
            child: Text(widget.old == null ? 'Add expense' : 'Save changes'),
          ),
        ],
      ),
    ),
  );
  void _submit() {
    final value = double.tryParse(amount.text);
    if (title.text.trim().isEmpty || value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a description and a valid amount.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      Expense(
        widget.old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title.text.trim(),
        value,
        category,
        date,
        note.text.trim(),
      ),
    );
  }
}

Map<String, double> totals(Iterable<Expense> items) {
  final result = <String, double>{};
  for (final item in items) {
    result.update(
      item.category,
      (v) => v + item.amount,
      ifAbsent: () => item.amount,
    );
  }
  return result;
}

String money(double value) =>
    NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(value);
Color colorFor(String category) => switch (category) {
  'Food' => const Color(0xFFFF8A65),
  'Travel' => const Color(0xFF4FC3F7),
  'Shopping' => const Color(0xFFAB7CFF),
  'Bills' => const Color(0xFFFFC857),
  'Health' => const Color(0xFF4ECCA3),
  _ => const Color(0xFF94A3B8),
};
IconData icon(String category) => switch (category) {
  'Food' => Icons.restaurant_rounded,
  'Travel' => Icons.directions_car_rounded,
  'Shopping' => Icons.shopping_bag_rounded,
  'Bills' => Icons.receipt_long_rounded,
  'Health' => Icons.favorite_rounded,
  _ => Icons.category_rounded,
};

class Empty extends StatelessWidget {
  const Empty({
    super.key,
    this.text = 'No expenses yet. Tap Add expense to get started.',
  });
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blueGrey.shade500),
      ),
    ),
  );
}
