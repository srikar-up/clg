import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../logic/life_provider.dart';
import '../logic/expense_provider.dart';
import '../logic/timetable_provider.dart';
import '../logic/syllabus_provider.dart';
import '../logic/theme_provider.dart';
import '../logic/backup_service.dart';

const _green = Color(0xFF10B981);
const _purple = Color(0xFF8B5CF6);
const _orange = Color(0xFFF97316);
const _blue = Color(0xFF3B82F6);

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToTimetable;

  const DashboardScreen({super.key, this.onNavigateToTimetable});

  @override
  Widget build(BuildContext context) {
    final lifeProv = context.watch<LifeProvider>();
    final expProv = context.watch<ExpenseProvider>();
    final timeProv = context.watch<TimetableProvider>();
    final sylProv = context.watch<SyllabusProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;

    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final now = DateTime.now();
    // Syllabus Line Chart Data (Last 7 Days - Interpolated since completion dates aren't natively stored)
    final totalProgressPercent = sylProv.subjects.isEmpty ? 0.0 : 
      (sylProv.subjects.fold(0.0, (sum, s) => sum + s.masterProgress) / sylProv.subjects.length) * 100;
    
    List<FlSpot> syllabusSpots = [
      FlSpot(0, (totalProgressPercent * 0.3).clamp(0, 100)),
      FlSpot(1, (totalProgressPercent * 0.5).clamp(0, 100)),
      FlSpot(2, (totalProgressPercent * 0.6).clamp(0, 100)),
      FlSpot(3, (totalProgressPercent * 0.75).clamp(0, 100)),
      FlSpot(4, (totalProgressPercent * 0.85).clamp(0, 100)),
      FlSpot(5, (totalProgressPercent * 0.95).clamp(0, 100)),
      FlSpot(6, totalProgressPercent),
    ];
    List<String> dayLabels = List.generate(7, (index) => DateFormat('d MMM').format(now.subtract(Duration(days: 6 - index))));

    // Finance Bar Chart Data (Last 6 Months)
    List<BarChartGroupData> expenseBarGroups = [];
    List<String> monthLabels = [];
    double maxBarValue = 0;
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final nextMonthDate = DateTime(now.year, now.month - i + 1, 1);
      
      final monthExpenses = expProv.allExpenses.where((e) => e.date.isAfter(monthDate.subtract(const Duration(days: 1))) && e.date.isBefore(nextMonthDate)).toList();
      
      final inflow = monthExpenses.where((e) => e.title == 'Savings' || e.title == 'Debt Taken').fold(0.0, (sum, e) => sum + e.amount);
      final outflow = monthExpenses.where((e) => e.title == 'Expense' || e.title == 'Investment' || e.title == 'Debt Repayment').fold(0.0, (sum, e) => sum + e.amount);
      
      if (inflow > maxBarValue) maxBarValue = inflow;
      if (outflow > maxBarValue) maxBarValue = outflow;

      expenseBarGroups.add(BarChartGroupData(
        x: 5 - i,
        barRods: [
          BarChartRodData(toY: inflow, color: _green, width: 8, borderRadius: BorderRadius.circular(2)),
          BarChartRodData(toY: outflow, color: config.primaryAccent, width: 8, borderRadius: BorderRadius.circular(2)),
        ],
      ));
      monthLabels.add(DateFormat('MMM').format(monthDate));
    }

    return Scaffold(
      backgroundColor: config.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: config.cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Command Center', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: config.textMain, height: 1)),
                       const SizedBox(height: 4),
                       Text('STATISTICS SUITE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                     ],
                   ),
                   Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: config.softBg,
                           borderRadius: BorderRadius.circular(16)
                         ),
                         child: Icon(Icons.analytics, color: config.primaryAccent, size: 24),
                       ),
                       const SizedBox(width: 8),
                       GestureDetector(
                         onTap: () {
                           showModalBottomSheet(
                             context: context,
                             backgroundColor: config.cardColor,
                             builder: (context) => _buildThemeSelector(context, themeProv, config),
                           );
                         },
                         child: Container(
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: config.softBg,
                             borderRadius: BorderRadius.circular(16)
                           ),
                           child: Icon(Icons.settings, color: config.primaryAccent, size: 24),
                         ),
                       ),
                     ],
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
                      gradient: LinearGradient(colors: [config.gradStart, config.gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [BoxShadow(color: config.gradStart.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: -10, offset: const Offset(0, 15))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text('LIFE OS RANK', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.5)),
                             Icon(Icons.stars, color: Colors.white.withValues(alpha: 0.7), size: 16),
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
                         Text('${lifeProv.currentLevelProgressXp} / ${lifeProv.nextLevelXp} XP to Next Level', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1)),
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
                           config: config,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                           title: 'QUEST SUCCESS',
                           value: '${lifeProv.successRate.toStringAsFixed(0)}%',
                           subtitle: '${lifeProv.totalQuestsCompleted} Completed',
                           icon: Icons.shield,
                           color: _orange,
                           config: config,
                        ),
                        const SizedBox(width: 16),
                        _buildInfoCard(
                           title: 'TODAY\'S CLASSES',
                           value: '${timeProv.getItemsForDay(DateTime.now().weekday).length}',
                           subtitle: 'Scheduled items',
                           icon: Icons.calendar_today,
                           color: _blue,
                           config: config,
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
                      color: config.cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 10, offset: Offset(0, 4))],
                      border: Border.all(color: config.textMain.withValues(alpha: 0.05))
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
                              child: Icon(Icons.school, color: _purple, size: 28),
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
                            _buildStatColumn('Current Sem', sylProv.activeSemesterName, _purple),
                          ],
                        ),
                        if (sylProv.subjects.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('COMPLETION TIMELINE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 22,
                                      getTitlesWidget: (value, meta) {
                                        int idx = value.toInt();
                                        if (idx >= 0 && idx < dayLabels.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(dayLabels[idx], style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: 100,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: syllabusSpots,
                                    isCurved: true,
                                    color: _purple,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: _purple.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // WEALTH WIDGET (Finance)
                  Text('FINANCIAL SNAPSHOT', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: config.cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 10, offset: Offset(0, 4))],
                      border: Border.all(color: config.textMain.withValues(alpha: 0.05))
                    ),
                    child: Column(
                      children: [
                        if (expenseBarGroups.isNotEmpty && maxBarValue > 0) ...[
                          Text('FLOW VS OUTFLOW (LAST 6 MONTHS)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxBarValue * 1.2,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        int idx = value.toInt();
                                        if (idx >= 0 && idx < monthLabels.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(monthLabels[idx], 
                                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true, 
                                  drawVerticalLine: false, 
                                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: expenseBarGroups,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildChartLegend(color: _green, label: 'Inflow'),
                              const SizedBox(width: 16),
                              _buildChartLegend(color: config.primaryAccent, label: 'Outflow'),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        Row(
                          children: [
                            Expanded(child: _buildFinanceCard('Earned', expProv.totalIncome, _green, config)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildFinanceCard('Spent', expProv.totalExpense, config.primaryAccent, config)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildFinanceCard('Investing', expProv.totalInvestment, _purple, config, subtitle: '${expProv.investRate.toStringAsFixed(1)}% Rate')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildFinanceCard('Debt', expProv.outstandingDebt, _orange, config, isDebt: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // TIMETABLE QUICK ACTION
                  GestureDetector(
                    onTap: onNavigateToTimetable,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: config.softBg,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text('UPCOMING CLASSES', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                               const SizedBox(height: 4),
                               Text('${timeProv.getItemsForDay(DateTime.now().weekday).where((e) {
                                 final now = TimeOfDay.now();
                                 return (e.startHour * 60 + e.startMinute) > (now.hour * 60 + now.minute);
                               }).length} Remaining Today', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                            ],
                          ),
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: config.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2))),
                            child: Icon(Icons.arrow_forward, color: config.primaryAccent),
                          )
                        ],
                      ),
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

  Widget _buildInfoCard({required String title, required String value, required String subtitle, required IconData icon, required Color color, required ThemeConfig config}) {
    return Container(
       width: 180,
       clipBehavior: Clip.antiAlias,
       decoration: BoxDecoration(
         color: config.cardColor,
         borderRadius: BorderRadius.circular(32),
         boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 10, offset: Offset(0, 4))],
       ),
       child: Container(
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
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

  Widget _buildChartLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildFinanceCard(String label, double amount, Color color, ThemeConfig config, {String? subtitle, bool isDebt = false}) {
     final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
     return Container(
       clipBehavior: Clip.antiAlias,
       decoration: BoxDecoration(
         color: config.cardColor,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.02), blurRadius: 10, offset: Offset(0, 4))]
       ),
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
         decoration: BoxDecoration(
           border: Border(left: BorderSide(color: color, width: 4)),
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
      ),
     );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProv, ThemeConfig config) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: config.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: config.textMain)),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.light_mode, color: themeProv.mode == AppThemeMode.light ? config.primaryAccent : config.textMuted),
            title: Text('Light Mode', style: TextStyle(color: config.textMain, fontWeight: themeProv.mode == AppThemeMode.light ? FontWeight.bold : FontWeight.normal)),
            trailing: themeProv.mode == AppThemeMode.light ? Icon(Icons.check, color: config.primaryAccent) : null,
            onTap: () {
              themeProv.setTheme(AppThemeMode.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode, color: themeProv.mode == AppThemeMode.dark ? config.primaryAccent : config.textMuted),
            title: Text('Dark Mode', style: TextStyle(color: config.textMain, fontWeight: themeProv.mode == AppThemeMode.dark ? FontWeight.bold : FontWeight.normal)),
            trailing: themeProv.mode == AppThemeMode.dark ? Icon(Icons.check, color: config.primaryAccent) : null,
            onTap: () {
              themeProv.setTheme(AppThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.water_drop, color: themeProv.mode == AppThemeMode.blue ? config.primaryAccent : config.textMuted),
            title: Text('Blue Mode', style: TextStyle(color: config.textMain, fontWeight: themeProv.mode == AppThemeMode.blue ? FontWeight.bold : FontWeight.normal)),
            trailing: themeProv.mode == AppThemeMode.blue ? Icon(Icons.check, color: config.primaryAccent) : null,
            onTap: () {
              themeProv.setTheme(AppThemeMode.blue);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.download, color: config.primaryAccent),
            title: Text('Export Backup (.okso)', style: TextStyle(color: config.textMain, fontWeight: FontWeight.bold)),
            onTap: () async {
              await BackupService.exportBackup(context);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.folder_shared, color: config.primaryAccent),
            title: Text('Import Backup (.okso)', style: TextStyle(color: config.textMain, fontWeight: FontWeight.bold)),
            onTap: () async {
              await BackupService.importBackup(context);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.help_outline, color: config.primaryAccent),
            title: Text('Help & Support', style: TextStyle(color: config.textMain, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context, config);
            },
          ),
          const SizedBox(height: 24),
        ],
       ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, ThemeConfig config) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: config.cardColor,
        title: Text("Help & Support", style: TextStyle(color: config.textMain, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Dashboard: View your overall progress and financial snapshot.", style: TextStyle(color: config.textMuted)),
              const SizedBox(height: 8),
              Text("• Timetable: Manage your daily classes and exams. Tap any class to edit or delete it.", style: TextStyle(color: config.textMuted)),
              const SizedBox(height: 8),
              Text("• Life OS: Track your goals, tasks, and quests to level up your Life OS Rank.", style: TextStyle(color: config.textMuted)),
              const SizedBox(height: 8),
              Text("• Expenses: Keep track of your spending, investments, and debts.", style: TextStyle(color: config.textMuted)),
              const SizedBox(height: 8),
              Text("• Syllabus: Monitor your academic progress and predict your SGPA.", style: TextStyle(color: config.textMuted)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Close", style: TextStyle(color: config.primaryAccent)),
          ),
        ],
      ),
    );
  }
}
