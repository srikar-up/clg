import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/expense_provider.dart';
import '../data/models.dart';

const _bgPrimary = Color(0xFFFEF2F2);
const _textPrimary = Color(0xFF111827);
const _gradStart = Color(0xFFEF4444);
const _gradEnd = Color(0xFF991B1B);
const _red600 = Color(0xFFDC2626);
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
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER & FILTERS
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Wallet', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: _textPrimary, height: 1)),
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
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.red.shade100)
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade100)),
                            child: const Icon(Icons.smart_toy, color: _red600),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('FINANCIAL AI', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1.5)),
                                 const SizedBox(height: 4),
                                 Text(provider.advisorMessage, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
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
                        gradient: const LinearGradient(colors: [_gradStart, _gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.3), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('NET CASH FLOW', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red.shade200, letterSpacing: 1.5)),
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
                                   Text('SAVINGS RATE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.red.shade200, letterSpacing: 1.5)),
                                   Text('${provider.savingsRate.toStringAsFixed(0)}%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                 ]
                               ),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.end,
                                 children: [
                                   Text('OUTSTANDING DEBT', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.red.shade200, letterSpacing: 1.5)),
                                   Text(_currencyFmt.format(provider.outstandingDebt), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orange.shade300)),
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
                         _buildMiniKpi('EXPENSE', provider.totalExpense, _red600),
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
                        Text('RECENT TRANSACTIONS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade800, letterSpacing: 1.5)),
                        Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20)
                      ]
                    )
                  ),
                  const SizedBox(height: 12),
                  
                  if (provider.filteredExpenses.isEmpty)
                     Padding(
                       padding: const EdgeInsets.all(40),
                       child: Center(
                         child: Text("No transactions for this period.", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
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
        backgroundColor: _red600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 14, color: _red600),
          isDense: true,
          onChanged: onChanged,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600)))).toList(),
        )
      ),
    );
  }

  Widget _buildMiniKpi(String label, double val, Color color, {bool isPct = false}) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: const [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 10, offset: Offset(0, 4))]
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
           const SizedBox(height: 2),
           Text(isPct ? '${val.toStringAsFixed(0)}%' : _currencyFmt.format(val), style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey.shade800)),
         ]
       ),
     );
  }

  Widget _buildTransactionCard(Expense tx, ExpenseProvider provider) {
     IconData icon = Icons.attach_money;
     Color color = Colors.grey;
     Color bg = Colors.grey.shade100;
     String sign = '-';

     if (tx.title == 'Savings') { icon = Icons.arrow_downward; color = _green; bg = Colors.green.shade50; sign = '+'; }
     else if (tx.title == 'Expense') { icon = Icons.shopping_cart; color = _red600; bg = Colors.red.shade50; }
     else if (tx.title == 'Investment') { icon = Icons.pie_chart; color = _purple; bg = Colors.purple.shade50; }
     else if (tx.title == 'Debt Taken') { icon = Icons.account_balance; color = _orange; bg = Colors.orange.shade50; sign = '+'; }
     else if (tx.title == 'Debt Repayment') { icon = Icons.money_off; color = Colors.blue; bg = Colors.blue.shade50; }

     return Container(
        margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(24),
           boxShadow: const [BoxShadow(color: Color.fromRGBO(0,0,0,0.02), blurRadius: 10, offset: Offset(0, 4))]
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
                   Text(tx.category, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey.shade800)),
                   Text('${tx.title} • ${DateFormat('MMM yyyy').format(tx.date)}', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1)),
                 ]
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$sign${_currencyFmt.format(tx.amount)}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: sign == '+' ? _green : Colors.grey.shade800)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => provider.deleteExpense(tx),
                  child: const Icon(Icons.delete, color: Colors.redAccent, size: 14)
                )
              ]
            )
          ]
        ),
     );
  }

  void _showAddFabMenu(BuildContext context, ExpenseProvider provider) {
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
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
      child: SingleChildScrollView(
         child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Transaction', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.grey.shade400)
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
                         icon: const Icon(Icons.keyboard_arrow_down, size: 16),
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
                         icon: const Icon(Icons.keyboard_arrow_down, size: 16),
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
                    child: Text(DateFormat('dd MMM yyyy').format(_date), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                )),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [
                      Text('₹', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey.shade400)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00'),
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
                      gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFF991B1B)]),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.3), blurRadius: 20, offset: Offset(0, 10))],
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
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.shade100)),
                          alignment: Alignment.center,
                          child: Text('EXPORT CSV', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red.shade600, letterSpacing: 1.5)),
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
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.shade100)),
                          alignment: Alignment.center,
                          child: Text('IMPORT JSON', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red.shade600, letterSpacing: 1.5)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
          child
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
     final ctrl = TextEditingController();
     showDialog(
       context: context,
       builder: (c) => AlertDialog(
         title: const Text("Import JSON"),
         content: TextField(
           controller: ctrl,
           maxLines: 5,
           decoration: const InputDecoration(hintText: '[{"type": "Savings", "category": "Salary", "amount": 1000}]'),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
           FilledButton(onPressed: () {
              widget.provider.importJson(ctrl.text);
              Navigator.pop(c);
              Navigator.pop(context); // close bottom sheet
           }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text("Import"))
         ],
       )
     );
  }
}