import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../logic/life_provider.dart';
import '../logic/expense_provider.dart';
import '../logic/timetable_provider.dart';
import '../logic/syllabus_provider.dart';

const _bgPrimary = Color(0xFFFEF2F2);
const _textDark = Color(0xFF1F2937);
const _gradStart = Color(0xFFEF4444);
const _gradEnd = Color(0xFF991B1B);
const _red600 = Color(0xFFDC2626);
const _green = Color(0xFF10B981);
const _purple = Color(0xFF8B5CF6);
const _orange = Color(0xFFF97316);
const _blue = Color(0xFF3B82F6);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lifeProv = context.watch<LifeProvider>();
    final expProv = context.watch<ExpenseProvider>();
    final timeProv = context.watch<TimetableProvider>();
    final sylProv = context.watch<SyllabusProvider>();

    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Command Center', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: _textDark, height: 1)),
                       const SizedBox(height: 4),
                       Text('STATISTICS SUITE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1.5)),
                     ],
                   ),
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.red.shade50,
                       borderRadius: BorderRadius.circular(16)
                     ),
                     child: const Icon(Icons.analytics, color: _red600, size: 24),
                   ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20).copyWith(bottom: 100),
                children: [
                  
                  // MAIN HERO METRIC (Life OS Level & XP)
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_gradStart, _gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.3), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text('LIFE OS RANK', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red.shade200, letterSpacing: 1.5)),
                             Icon(Icons.stars, color: Colors.red.shade200, size: 16),
                           ],
                         ),
                         const SizedBox(height: 12),
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: [
                              Text('Level ${lifeProv.currentLevel}', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('(${lifeProv.totalPoints} Total XP)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                              ),
                           ],
                         ),
                         const SizedBox(height: 24),
                         Container(
                           height: 8,
                           width: double.infinity,
                           decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                           child: FractionallySizedBox(
                             alignment: Alignment.centerLeft,
                             widthFactor: lifeProv.levelProgress.clamp(0.0, 1.0),
                             child: Container(
                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                             ),
                           ),
                         ),
                         const SizedBox(height: 8),
                         Text('${lifeProv.currentLevelProgressXp} / ${lifeProv.nextLevelXp} XP to Next Level', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red.shade100, letterSpacing: 1)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // HORIZONTAL METRICS LIST (Scrollable Cards)
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildInfoCard(
                           title: 'NET CASH FLOW',
                           value: currencyFmt.format(expProv.netCashFlow),
                           subtitle: 'Wallet Balance',
                           icon: Icons.account_balance_wallet,
                           color: _green,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                           title: 'QUEST SUCCESS',
                           value: '${lifeProv.successRate.toStringAsFixed(0)}%',
                           subtitle: '${lifeProv.totalQuestsCompleted} Completed',
                           icon: Icons.shield,
                           color: _orange,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                           title: 'TODAY\'S CLASSES',
                           value: '${timeProv.getItemsForDay(DateTime.now().weekday).length}',
                           subtitle: 'Scheduled items',
                           icon: Icons.calendar_today,
                           color: _blue,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ACADEMICS WIDGET (Syllabus)
                  Text('ACADEMICS PROGRESS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 10, offset: Offset(0, 4))],
                      border: Border.all(color: Colors.grey.shade100)
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('EXPECTED SGPA', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1)),
                                Text(sylProv.predictSGPA().toStringAsFixed(2), style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: _purple)),
                              ],
                            ),
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: _purple.withValues(alpha:0.1), borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.school, color: _purple, size: 28),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('Total Subjects', '${sylProv.subjects.length}', Colors.grey.shade800),
                            Container(width: 1, height: 30, color: Colors.grey.shade200),
                            _buildStatColumn('Total Credits', '${sylProv.subjects.fold<int>(0, (prev, s) => prev + s.credits)}', Colors.grey.shade800),
                            Container(width: 1, height: 30, color: Colors.grey.shade200),
                            _buildStatColumn('Current Sem', '${sylProv.activeSemesterName}', _purple),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // WEALTH WIDGET (Finance)
                  Text('FINANCIAL SNAPSHOT', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildFinanceCard('Earned', expProv.totalIncome, _green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFinanceCard('Spent', expProv.totalExpense, _red600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildFinanceCard('Investing', expProv.totalInvestment, _purple, subtitle: '${expProv.investRate.toStringAsFixed(1)}% Rate')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFinanceCard('Debt', expProv.outstandingDebt, _orange, isDebt: true)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // TIMETABLE QUICK ACTION
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.red.shade100)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('UPCOMING CLASSES', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1.5)),
                             const SizedBox(height: 4),
                             Text('${timeProv.getItemsForDay(DateTime.now().weekday).where((e) {
                               final now = TimeOfDay.now();
                               return (e.startHour * 60 + e.startMinute) > (now.hour * 60 + now.minute);
                             }).length} Remaining Today', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                          ],
                        ),
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade100)),
                          child: const Icon(Icons.arrow_forward, color: _red600),
                        )
                      ],
                    ),
                  )

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required String subtitle, required IconData icon, required Color color}) {
    return Container(
       width: 180,
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(32),
         boxShadow: const [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 10, offset: Offset(0, 4))],
         border: Border(top: BorderSide(color: color, width: 6)),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Icon(icon, color: color, size: 24),
               Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
             ],
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.grey.shade800, height: 1)),
               const SizedBox(height: 4),
               Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
             ],
           )
         ],
       ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: valColor)),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildFinanceCard(String label, double amount, Color color, {String? subtitle, bool isDebt = false}) {
     final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         border: Border(left: BorderSide(color: color, width: 4)),
         boxShadow: const [BoxShadow(color: Color.fromRGBO(0,0,0,0.02), blurRadius: 10, offset: Offset(0, 4))]
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
           const SizedBox(height: 4),
           Text(fmt.format(amount), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey.shade800)),
           if (subtitle != null) ...[
             const SizedBox(height: 2),
             Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
           ] else if (isDebt && amount > 0) ...[
             const SizedBox(height: 2),
             Text('To be paid', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
           ]
         ],
       ),
     );
  }
}
