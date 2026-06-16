import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SplitMeApp());
}

class SplitMeApp extends StatelessWidget {
  const SplitMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EFF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainShell(),
    );
  }
}

// ─── Main Shell with Bottom Nav ───────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF6B4EFF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────
class BillRecord {
  final String title;
  final double amount;
  final String payer;
  final List<String> people;
  final double share;
  final List<Map<String, dynamic>> owes;
  final String date;

  BillRecord({
    required this.title,
    required this.amount,
    required this.payer,
    required this.people,
    required this.share,
    required this.owes,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'payer': payer,
    'people': people,
    'share': share,
    'owes': owes,
    'date': date,
  };

  factory BillRecord.fromJson(Map<String, dynamic> json) => BillRecord(
    title: json['title'],
    amount: json['amount'],
    payer: json['payer'],
    people: List<String>.from(json['people']),
    share: json['share'],
    owes: List<Map<String, dynamic>>.from(json['owes']),
    date: json['date'],
  );
}

// ─── Storage Helper ───────────────────────────────────────────
List<BillRecord> billHistory = [];

Future<void> saveToStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final data = billHistory.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList('bill_history', data);
}

Future<void> loadFromStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('bill_history') ?? [];
  billHistory = data.map((s) => BillRecord.fromJson(jsonDecode(s))).toList();
}

// ─── Home Screen ──────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    loadFromStorage().then((_) => setState(() {}));
  }

  void _showSplitOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose split type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('How would you like to split?', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            // Quick Split button
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitScreen()));
                setState(() {});
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Text('💰', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 16),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Quick Split', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Enter total & divide equally', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Receipt Split button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt scanner coming soon! 📸')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6B4EFF)),
                ),
                child: const Row(
                  children: [
                    Text('📸', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 16),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Receipt Split', style: TextStyle(color: Color(0xFF6B4EFF), fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Scan receipt — coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    final unpaidBills = billHistory.where((r) =>
      r.owes.any((o) => o['paid'] == false)
    ).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.notifications, color: Color(0xFF6B4EFF)),
                const SizedBox(width: 8),
                const Text('Unpaid bills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: unpaidBills.isEmpty ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${unpaidBills.length} pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: unpaidBills.isEmpty ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              if (unpaidBills.isEmpty)
                const Expanded(
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_outline, size: 56, color: Colors.green),
                    SizedBox(height: 12),
                    Text('All bills are settled!', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ])),
                )
              else
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: unpaidBills.map((r) {
                      final unpaidOwes = r.owes.where((o) => o['paid'] == false).toList();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.receipt_outlined, size: 16, color: Colors.red),
                              const SizedBox(width: 6),
                              Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const Spacer(),
                              Text(r.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ]),
                            const SizedBox(height: 8),
                            ...unpaidOwes.map((o) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.red.shade100,
                                  child: Text(
                                    (o['name'] as String)[0].toUpperCase(),
                                    style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(o['name'] as String, style: const TextStyle(fontSize: 13)),
                                const Spacer(),
                                Text(
                                  'owes \$${(o['amount'] as double).toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 13, color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                ),
                              ]),
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = billHistory.take(2).toList();
    final unpaidCount = billHistory.where((r) => r.owes.any((o) => o['paid'] == false)).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Text('💸', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    const Text('SplitMe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B4EFF))),
                  ]),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6B4EFF), size: 26),
                        onPressed: _showNotifications,
                      ),
                      if (unpaidCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B4EFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero illustration
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Try to load image, fall back to placeholder
                      Image.asset(
                        'assets/illustration.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, size: 56, color: Color(0xFF6B4EFF)),
                            SizedBox(height: 8),
                            Text('Add illustration.png\nto assets folder', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B4EFF), fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tagline
              const Text(
                'Split bills fairly,\nstress-free',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track shared expenses in seconds.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 28),

              // Start New Split button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showSplitOptions,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Start New Split', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // View History button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreenWithBack()));
                    setState(() {});
                  },
                  icon: const Icon(Icons.history, color: Color(0xFF6B4EFF)),
                  label: const Text('View History', style: TextStyle(fontSize: 16, color: Color(0xFF6B4EFF), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF6B4EFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Recent splits
              if (recent.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent splits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton(
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreenWithBack()));
                              setState(() {});
                            },
                            child: const Text('See all', style: TextStyle(color: Color(0xFF6B4EFF))),
                          ),
                        ],
                      ),
                      const Divider(height: 8),
                      ...recent.asMap().entries.map((entry) {
                        final i = entry.key;
                        final r = entry.value;
                        final unpaid = r.owes.where((o) => o['paid'] == false).length;
                        final settled = unpaid == 0;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE9FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.receipt_outlined, color: Color(0xFF6B4EFF), size: 22),
                              ),
                              title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('${r.people.length} people  •  ${r.date}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('\$${r.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: settled ? Colors.green.shade50 : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text(
                                        settled ? 'Settled' : 'Owing',
                                        style: TextStyle(fontSize: 11, color: settled ? Colors.green.shade700 : Colors.blue.shade700, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(settled ? Icons.check_circle : Icons.circle, size: 10, color: settled ? Colors.green.shade700 : Colors.blue.shade700),
                                    ]),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recordIndex: billHistory.indexOf(r))));
                                setState(() {});
                              },
                            ),
                            if (i < recent.length - 1) Divider(height: 1, color: Colors.grey.shade100),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Split Screen ─────────────────────────────────────────────
class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final personController = TextEditingController();
  List<String> people = [];
  String? selectedPayer;

  void addPerson() {
    final name = personController.text.trim();
    if (name.isEmpty || people.contains(name)) return;
    setState(() {
      people.add(name);
      if (people.length == 1) selectedPayer = name;
      personController.clear();
    });
  }

  void removePerson(String name) {
    setState(() {
      people.remove(name);
      if (selectedPayer == name) selectedPayer = people.isNotEmpty ? people.first : null;
    });
  }

  void calculate() {
    final title = titleController.text.trim().isEmpty ? 'Untitled' : titleController.text.trim();
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    if (people.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least 2 people')));
      return;
    }
    if (selectedPayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select who paid')));
      return;
    }
    final share = amount / people.length;
    final owes = people
        .where((p) => p != selectedPayer)
        .map((p) => {'name': p, 'amount': share, 'paid': false})
        .toList();

    final record = BillRecord(
      title: title,
      amount: amount,
      payer: selectedPayer!,
      people: List.from(people),
      share: share,
      owes: owes,
      date: DateTime.now().toString().substring(0, 10),
    );

    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(record: record)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('Quick Split', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B4EFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard('Bill Details', [
              TextField(controller: titleController, decoration: _inputDeco('Bill title (e.g. Dinner, Groceries)')),
              const SizedBox(height: 12),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: _inputDeco('Total amount (\$)')),
            ]),
            const SizedBox(height: 12),
            _sectionCard('Add People', [
              Row(children: [
                Expanded(child: TextField(controller: personController, decoration: _inputDeco('Name'), onSubmitted: (_) => addPerson())),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addPerson,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4EFF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Add'),
                ),
              ]),
              if (people.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: people.map((p) => Chip(
                    label: Text(p),
                    onDeleted: () => removePerson(p),
                    backgroundColor: const Color(0xFFEDE9FF),
                    labelStyle: const TextStyle(color: Color(0xFF6B4EFF)),
                    deleteIconColor: const Color(0xFF6B4EFF),
                  )).toList(),
                ),
              ],
            ]),
            if (people.length >= 2) ...[
              const SizedBox(height: 12),
              _sectionCard('Who paid?', [
                DropdownButtonFormField<String>(
                  value: selectedPayer,
                  decoration: _inputDeco('Select payer'),
                  items: people.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => selectedPayer = v),
                ),
              ]),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Calculate Split', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6B4EFF))),
    filled: true,
    fillColor: const Color(0xFFF5F3FF),
  );
}

// ─── Result Screen ────────────────────────────────────────────
class ResultScreen extends StatelessWidget {
  final BillRecord record;
  const ResultScreen({super.key, required this.record});

  Future<void> save(BuildContext context) async {
    billHistory.insert(0, record);
    await saveToStorage();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B4EFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text('\$${record.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Each person', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text('\$${record.share.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B4EFF))),
                  ]),
                ]),
                const Divider(height: 24),
                Row(children: [
                  const Text('Paid by  ', style: TextStyle(color: Colors.grey)),
                  CircleAvatar(radius: 14, backgroundColor: const Color(0xFF6B4EFF), child: Text(record.payer[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12))),
                  const SizedBox(width: 8),
                  Text(record.payer, style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Who owes who', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...record.owes.map((o) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        CircleAvatar(radius: 18, backgroundColor: const Color(0xFFEDE9FF), child: Text((o['name'] as String)[0].toUpperCase(), style: const TextStyle(color: Color(0xFF6B4EFF), fontWeight: FontWeight.bold))),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(o['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('owes ${record.payer}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ]),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEDE9FF), borderRadius: BorderRadius.circular(10)),
                        child: Text('\$${(o['amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B4EFF))),
                      ),
                    ]),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Record', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── History Screen (bottom nav) ──────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    loadFromStorage().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B4EFF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    if (billHistory.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('No records yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
        SizedBox(height: 8),
        Text('Start a new split to see it here', style: TextStyle(color: Colors.grey, fontSize: 13)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: billHistory.length,
      itemBuilder: (context, i) => _buildItem(context, i),
    );
  }

  Widget _buildItem(BuildContext context, int i) {
    final r = billHistory[i];
    final unpaid = r.owes.where((o) => o['paid'] == false).length;
    final settled = unpaid == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFFEDE9FF), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.receipt_outlined, color: Color(0xFF6B4EFF), size: 22),
        ),
        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${r.date} · Paid by ${r.payer} · ${r.people.length} people', style: const TextStyle(fontSize: 12)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('\$${r.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: settled ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
            child: Text(settled ? 'Settled' : '$unpaid unpaid', style: TextStyle(fontSize: 11, color: settled ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w500)),
          ),
        ]),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recordIndex: i)));
          setState(() {});
        },
      ),
    );
  }
}

// ─── History Screen With Back Button ──────────────────────────
class HistoryScreenWithBack extends StatefulWidget {
  const HistoryScreenWithBack({super.key});

  @override
  State<HistoryScreenWithBack> createState() => _HistoryScreenWithBackState();
}

class _HistoryScreenWithBackState extends State<HistoryScreenWithBack> {
  @override
  void initState() {
    super.initState();
    loadFromStorage().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B4EFF),
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: billHistory.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No records yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
              SizedBox(height: 8),
              Text('Start a new split to see it here', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: billHistory.length,
              itemBuilder: (context, i) {
                final r = billHistory[i];
                final unpaid = r.owes.where((o) => o['paid'] == false).length;
                final settled = unpaid == 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: const Color(0xFFEDE9FF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.receipt_outlined, color: Color(0xFF6B4EFF), size: 22),
                    ),
                    title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${r.date} · Paid by ${r.payer} · ${r.people.length} people', style: const TextStyle(fontSize: 12)),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('\$${r.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: settled ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
                        child: Text(settled ? 'Settled' : '$unpaid unpaid', style: TextStyle(fontSize: 11, color: settled ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w500)),
                      ),
                    ]),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recordIndex: i)));
                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ─── Detail Screen ────────────────────────────────────────────
class DetailScreen extends StatefulWidget {
  final int recordIndex;
  const DetailScreen({super.key, required this.recordIndex});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late BillRecord record;

  @override
  void initState() {
    super.initState();
    record = billHistory[widget.recordIndex];
  }

  void togglePaid(int i) {
    setState(() => record.owes[i]['paid'] = !record.owes[i]['paid']);
    saveToStorage();
  }

  void deleteRecord() {
    billHistory.removeAt(widget.recordIndex);
    saveToStorage();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B4EFF),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Delete record?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(onPressed: () { Navigator.pop(context); deleteRecord(); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ));
        })],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('\$${record.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Each person', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('\$${record.share.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B4EFF))),
                ]),
              ]),
              const Divider(height: 24),
              Row(children: [
                const Text('Paid by  ', style: TextStyle(color: Colors.grey)),
                CircleAvatar(radius: 14, backgroundColor: const Color(0xFF6B4EFF), child: Text(record.payer[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12))),
                const SizedBox(width: 8),
                Text(record.payer, style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...record.owes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final o = entry.value;
                  final paid = o['paid'] as bool;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        CircleAvatar(radius: 18, backgroundColor: const Color(0xFFEDE9FF), child: Text((o['name'] as String)[0].toUpperCase(), style: const TextStyle(color: Color(0xFF6B4EFF), fontWeight: FontWeight.bold))),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(o['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${(o['amount'] as double).toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ]),
                      ]),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: paid ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                          child: Text(paid ? 'Paid' : 'Unpaid', style: TextStyle(fontSize: 11, color: paid ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => togglePaid(i),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            side: BorderSide(color: paid ? Colors.grey.shade400 : const Color(0xFF6B4EFF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(paid ? 'Undo' : 'Mark paid', style: TextStyle(fontSize: 12, color: paid ? Colors.grey : const Color(0xFF6B4EFF))),
                        ),
                      ]),
                    ]),
                  );
                }),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Settings Screen ──────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6B4EFF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(children: [
              ListTile(leading: const Icon(Icons.color_lens_outlined, color: Color(0xFF6B4EFF)), title: const Text('Theme'), trailing: const Text('Purple', style: TextStyle(color: Colors.grey))),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(leading: const Icon(Icons.attach_money, color: Color(0xFF6B4EFF)), title: const Text('Currency'), trailing: const Text('USD (\$)', style: TextStyle(color: Colors.grey))),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                title: const Text('Clear all history', style: TextStyle(color: Colors.red)),
                onTap: () {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: const Text('Clear all history?'),
                    content: const Text('This will delete all saved records permanently.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(onPressed: () async {
                        billHistory.clear();
                        await saveToStorage();
                        if (context.mounted) Navigator.pop(context);
                      }, child: const Text('Clear all', style: TextStyle(color: Colors.red))),
                    ],
                  ));
                },
              ),
            ]),
          ),
          const SizedBox(height: 24),
          const Center(child: Text('SplitMe v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 13))),
        ],
      ),
    );
  }
}