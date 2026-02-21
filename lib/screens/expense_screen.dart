import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/expense_provider.dart';
import '../data/models.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses & Debt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Export to Excel (CSV)",
            onPressed: () {
              final msg = provider.exportToCsv();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. DASHBOARD
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _SummaryCard(label: "Spent", amount: provider.totalSpent, color: Colors.red)),
                const SizedBox(width: 15),
                Expanded(child: _SummaryCard(label: "Debt", amount: provider.totalDebt, color: Colors.orange)),
              ],
            ),
          ),
          
          // 2. LIST
          Expanded(
            child: ListView.builder(
              itemCount: provider.expenses.length,
              itemBuilder: (ctx, i) {
                final item = provider.expenses[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.isDebt ? Colors.orange.shade100 : Colors.blue.shade100,
                    child: Icon(item.isDebt ? Icons.handshake : Icons.attach_money, color: Colors.black54),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${DateFormat('MMM d').format(item.date)} • ${item.category}"),
                  trailing: Text(
                    "\$${item.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: item.isDebt ? Colors.orange : Colors.red,
                    ),
                  ),
                  onLongPress: () => provider.deleteExpense(item),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, ExpenseProvider provider) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = "Food";
    bool isDebt = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: ["Food", "Transport", "Bills", "Shopping", "Other"].map((String val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              SwitchListTile(
                title: const Text("Is this a Debt?"),
                value: isDebt,
                onChanged: (val) => setState(() => isDebt = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            FilledButton(onPressed: () {
              if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                provider.addExpense(titleCtrl.text, double.parse(amountCtrl.text), category, isDebt);
                Navigator.pop(ctx);
              }
            }, child: const Text("Add")),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _SummaryCard({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("\$${amount.toStringAsFixed(0)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}