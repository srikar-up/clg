import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/expense_provider.dart';
import '../logic/theme_provider.dart';
import '../data/models.dart';

const _green = Color(0xFF10B981);
const _purple = Color(0xFF8B5CF6);
const _orange = Color(0xFFF97316);

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {

  final NumberFormat _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: config.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER & FILTERS
            Container(
              color: config.cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Wallet', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: config.textMain, height: 1)),
                       const SizedBox(height: 4),
                       Text('LIVE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _green, letterSpacing: 1.5)),
                     ],
                   ),
                   Row(
                     children: [
                       _buildDropdown(provider.filterYear, ['All', '2024', '2025', '2026'], (v) {
                         provider.setFilter(v!, provider.filterMonth);
                       }),
                       const SizedBox(width: 8),
                       _buildDropdown(provider.filterMonth, ['All', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'], (v) {
                         provider.setFilter(provider.filterYear, v!);
                       }),
                     ],
                   )
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  // ADVISOR BANNER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: config.softBg,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2))
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: config.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2))),
                            child: Icon(Icons.smart_toy, color: config.primaryAccent),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('FINANCIAL AI', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                                 const SizedBox(height: 4),
                                 Text(provider.advisorMessage, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: config.textMain)),
                               ]
                             )
                          )
                        ],
                      ),
                    ),
                  ),

                  // PRIMARY KPI
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [config.gradStart, config.gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [BoxShadow(color: config.gradStart.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('NET CASH FLOW', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.5)),
                           const SizedBox(height: 4),
                           Text(_currencyFmt.format(provider.netCashFlow), style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                           const SizedBox(height: 24),
                           Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                           const SizedBox(height: 16),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('SAVINGS RATE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.5)),
                                   Text('${provider.savingsRate.toStringAsFixed(0)}%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                 ]
                               ),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.end,
                                 children: [
                                   Text('OUTSTANDING DEBT', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.5)),
                                   Text(_currencyFmt.format(provider.outstandingDebt), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                 ]
                               )
                             ],
                           )
                        ],
                      ),
                    ),
                  ),

                  // SECONDARY KPIS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                       crossAxisCount: 2,
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       mainAxisSpacing: 16,
                       crossAxisSpacing: 16,
                       childAspectRatio: 1.8,
                       children: [
                         _buildMiniKpi('INCOME', provider.totalIncome, _green),
                         _buildMiniKpi('EXPENSE', provider.totalExpense, config.primaryAccent),
                         _buildMiniKpi('INVESTED', provider.totalInvestment, _purple),
                         _buildMiniKpi('INVEST %', provider.investRate, Colors.blue, isPct: true),
                       ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TRANSACTIONS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('RECENT TRANSACTIONS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMain, letterSpacing: 1.5)),
                        Icon(Icons.more_horiz, color: config.textMuted.withValues(alpha: 0.6), size: 20)
                      ]
                    )
                  ),
                  const SizedBox(height: 12),
                  
                  if (provider.filteredExpenses.isEmpty)
                     Padding(
                       padding: const EdgeInsets.all(40),
                       child: Center(
                         child: Text("No transactions for this period.", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: config.textMuted.withValues(alpha: 0.6))),
                       ),
                     ),

                  ...provider.filteredExpenses.map<Widget>((tx) => _buildTransactionCard(tx, provider)),

                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFabMenu(context, provider),
        backgroundColor: config.primaryAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Icon(Icons.add, color: config.cardColor),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent)),
          icon: Icon(Icons.keyboard_arrow_down, size: 14, color: config.primaryAccent),
          isDense: true,
          onChanged: onChanged,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent)))).toList(),
        )
      ),
    );
  }

  Widget _buildMiniKpi(String label, double val, Color color, {bool isPct = false}) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       decoration: BoxDecoration(
          color: config.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 10, offset: Offset(0, 4))]
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: config.textMuted.withValues(alpha: 0.6), letterSpacing: 1.5)),
           const SizedBox(height: 2),
           Text(isPct ? '${val.toStringAsFixed(0)}%' : _currencyFmt.format(val), style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: config.textMain)),
         ]
       ),
     );
  }

  Widget _buildTransactionCard(Expense tx, ExpenseProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
     IconData icon = Icons.attach_money;
     Color color = config.textMuted;
     Color bg = config.softBg;
     String sign = '-';

     if (tx.title == 'Savings') { icon = Icons.arrow_downward; color = _green; bg = Colors.green.shade50; sign = '+'; }
     else if (tx.title == 'Expense') { icon = Icons.shopping_cart; color = config.primaryAccent; bg = config.softBg; }
     else if (tx.title == 'Investment') { icon = Icons.pie_chart; color = _purple; bg = Colors.purple.shade50; }
     else if (tx.title == 'Debt Taken') { icon = Icons.account_balance; color = _orange; bg = Colors.orange.shade50; sign = '+'; }
     else if (tx.title == 'Debt Repayment') { icon = Icons.money_off; color = Colors.blue; bg = Colors.blue.shade50; }

     return Container(
        margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: config.cardColor,
           borderRadius: BorderRadius.circular(24),
           boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.02), blurRadius: 10, offset: Offset(0, 4))]
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(tx.category, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: config.textMain)),
                   Text('${tx.title} • ${DateFormat('MMM yyyy').format(tx.date)}', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: config.textMuted.withValues(alpha: 0.6), letterSpacing: 1)),
                 ]
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$sign${_currencyFmt.format(tx.amount)}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: sign == '+' ? _green : config.textMain)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => provider.deleteExpense(tx),
                  child: Icon(Icons.delete, color: config.primaryAccent, size: 14)
                )
              ]
            )
          ]
        ),
     );
  }

  void _showAddFabMenu(BuildContext context, ExpenseProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddTransactionModal(provider: provider)
    );
  }
}

class _AddTransactionModal extends StatefulWidget {
  final ExpenseProvider provider;
  const _AddTransactionModal({required this.provider});

  @override
  State<_AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<_AddTransactionModal> {
  final _amountCtrl = TextEditingController();
  String _type = 'Expense';
  String _category = 'Food';
  DateTime _date = DateTime.now();

  List<String> get _categories {
     if (_type == 'Expense') return ['Rent/EMI', 'Food', 'Groceries', 'Travel', 'Shopping', 'Bills'];
     if (_type == 'Debt Taken' || _type == 'Debt Repayment') return ['Personal Loan', 'Credit Card', 'Borrowed from Friend'];
     if (_type == 'Investment') return ['Stocks', 'SIP', 'Crypto', 'FD'];
     return ['Salary', 'Bonus', 'Freelance'];
  }

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: config.cardColor, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
      child: SingleChildScrollView(
         child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: config.textMuted.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Transaction', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: config.textMain)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: config.textMuted.withValues(alpha: 0.6))
                    )
                  ]
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputCard('TYPE', DropdownButton<String>(
                         value: _type,
                         isExpanded: true,
                         underline: const SizedBox(),
                         icon: Icon(Icons.keyboard_arrow_down, size: 16),
                         items: ['Savings', 'Expense', 'Investment', 'Debt Taken', 'Debt Repayment']
                             .map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
                         onChanged: (v) {
                           setState(() {
                             _type = v!;
                             _category = _categories.first;
                           });
                         },
                      ))
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputCard('CATEGORY', DropdownButton<String>(
                         value: _categories.contains(_category) ? _category : null,
                         isExpanded: true,
                         underline: const SizedBox(),
                         icon: Icon(Icons.keyboard_arrow_down, size: 16),
                         items: _categories.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
                         onChanged: (v) => setState(() => _category = v!),
                      ))
                    ),
                  ]
                ),

                const SizedBox(height: 16),

                _buildInputCard('DATE (Tap to change)', GestureDetector(
                  onTap: () async {
                     final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                     if (d != null) setState(() => _date = d);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(DateFormat('dd MMM yyyy').format(_date), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: config.textMain)),
                  ),
                )),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [
                      Text('₹', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: config.textMuted.withValues(alpha: 0.6))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: config.textMain),
                          decoration: InputDecoration(border: InputBorder.none, hintText: '0.00'),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    final amt = double.tryParse(_amountCtrl.text) ?? 0;
                    if (amt > 0) {
                      widget.provider.addTx(_type, _category, amt, _date);
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [config.gradStart, config.gradEnd]),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: config.gradStart.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10))],
                    ),
                    alignment: Alignment.center,
                    child: Text('SAVE ENTRY', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                           widget.provider.exportToCsv();
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV Copied to Clipboard!')));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2))),
                          alignment: Alignment.center,
                          child: Text('EXPORT CSV', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showImportDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2))),
                          alignment: Alignment.center,
                          child: Text('IMPORT JSON', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                        ),
                      ),
                    ),
                  ]
                )
              ],
            )
         )
      ),
    );
  }

  Widget _buildInputCard(String label, Widget child) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: config.textMuted.withValues(alpha: 0.6), letterSpacing: 1.5)),
          child
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
     final ctrl = TextEditingController();
     showDialog(
       context: context,
       builder: (c) => AlertDialog(
         title: Text("Import JSON"),
         content: TextField(
           controller: ctrl,
           maxLines: 5,
           decoration: InputDecoration(hintText: '[{"type": "Savings", "category": "Salary", "amount": 1000}]'),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
           FilledButton(onPressed: () {
              widget.provider.importJson(ctrl.text);
              Navigator.pop(c);
              Navigator.pop(context); // close bottom sheet
           }, style: FilledButton.styleFrom(backgroundColor: config.primaryAccent), child: Text("Import"))
         ],
       )
     );
  }
}