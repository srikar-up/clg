import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/life_provider.dart';
import '../logic/theme_provider.dart';
import '../data/models.dart';

const _softRed = Color(0xFFFEF2F2);
const _gold = Color(0xFFFBBF24);
const _silver = Color(0xFF94A3B8);
const _bronze = Color(0xFFD97706);
const _steel = Color(0xFF475569);

class LifeOsScreen extends StatefulWidget {
  const LifeOsScreen({super.key});

  @override
  State<LifeOsScreen> createState() => _LifeOsScreenState();
}

class _LifeOsScreenState extends State<LifeOsScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  
  // Floating XP animation
  final List<_FloatingXP> _floatingXps = [];
  
  void _gainXP(int amount, TapDownDetails details, BuildContext context) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    setState(() {
      _floatingXps.add(_FloatingXP(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        offset: details.globalPosition,
      ));
    });
    
    // Cleanup after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          if (_floatingXps.isNotEmpty) {
            _floatingXps.removeAt(0);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final provider = context.watch<LifeProvider>();

    return Scaffold(
      backgroundColor: config.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Container(
                  color: config.cardColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [config.gradStart, config.gradEnd],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(19),
                                    boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 5))
                                    ]
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('L${provider.currentLevel}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Commander', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: config.textMain, height: 1)),
                                    const SizedBox(height: 4),
                                    Text('Warrior Rank', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                                  ],
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('TOTAL XP', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted.withValues(alpha: 0.6), letterSpacing: 1)),
                                Text(provider.totalPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: config.textMain)),
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      // TABS
                      Container(
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: config.softBg))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTabItem(0, Icons.shield_outlined, "Quests"),
                            _buildTabItem(1, Icons.fitness_center, "Work"),
                            _buildTabItem(2, Icons.sticky_note_2_outlined, "Notes"),
                            _buildTabItem(3, Icons.calendar_month, "Events"),
                            _buildTabItem(4, Icons.pie_chart_outline, "Stats"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                // MAIN SCROLL AREA
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PERSISTENT STATS BAR
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [config.gradStart, config.gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -5, offset: Offset(0, 10))],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('NEXT LEVEL PROGRESS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.5)),
                                        const SizedBox(height: 2),
                                        Text('Level ${provider.currentLevel + 1}', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                                      ],
                                    ),
                                    Text('${provider.currentLevelProgressXp} / ${provider.nextLevelXp} XP', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 12,
                                  width: double.infinity,
                                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: provider.levelProgress.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // TAB CONTENT
                        _buildCurrentView(context, provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // FLOATING XP ANIMATIONS
          ..._floatingXps.map((fx) => _AnimatedXP(
             key: ValueKey(fx.id),
             amount: fx.amount,
             startOffset: fx.offset,
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFabMenu(context, provider),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [config.gradStart, config.gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: -2, offset: Offset(0, 8))]
          ),
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    bool isAct = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isAct ? config.primaryAccent : Colors.transparent, width: 3))
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: isAct ? config.primaryAccent : config.textMuted.withValues(alpha: 0.6)),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: isAct ? config.primaryAccent : config.textMuted.withValues(alpha: 0.6), letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView(BuildContext context, LifeProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    switch (_currentIndex) {
      case 0: return _QuestsView(provider: provider, onXP: _gainXP);
      case 1: return _WorkView(provider: provider, onXP: _gainXP);
      case 2: return _NotesView(provider: provider);
      case 3: return _EventsView(provider: provider);
      case 4: return _StatsView(provider: provider);
      default: return const SizedBox.shrink();
    }
  }

  void _showFabMenu(BuildContext context, LifeProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: config.cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 48, height: 6, decoration: BoxDecoration(color: config.textMuted.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  Text('Update Life OS', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: config.textMain)),
                  const SizedBox(height: 24),
                  
                  _FabBtn(icon: Icons.shield_outlined, label: 'ADD QUEST', onTap: () {
                    Navigator.pop(ctx);
                    _showCreateQuestDialog(context, provider);
                  }),
                  const SizedBox(height: 12),
                  _FabBtn(icon: Icons.fitness_center, label: 'ADD COUNTER', onTap: () {
                    Navigator.pop(ctx);
                    _showAddCounterDialog(context, provider);
                  }),
                  const SizedBox(height: 12),
                  _FabBtn(icon: Icons.calendar_today, label: 'SAVE EVENT', onTap: () {
                    Navigator.pop(ctx);
                    _showAddEventDialog(context, provider);
                  }),
                  const SizedBox(height: 12),
                  _FabBtn(icon: Icons.sticky_note_2_outlined, label: 'PIN NOTE', onTap: () {
                    Navigator.pop(ctx);
                    _showAddNoteDialog(context, provider);
                  }),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Text('CLOSE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: config.textMuted.withValues(alpha: 0.6), letterSpacing: 2)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Dialogs (reusing mostly but adjusting styling)
  void _showCreateQuestDialog(BuildContext context, LifeProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    final titleCtrl = TextEditingController();
    final penaltyCtrl = TextEditingController(text: '0');
    String selectedRank = 'gold';
    DateTime? deadline;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: config.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Quest', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "Quest Name"),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRank,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: config.softBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: [
                    DropdownMenuItem(value: 'gold', child: Text('🥇 Gold (+150 XP)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'silver', child: Text('🥈 Silver (+100 XP)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'bronze', child: Text('🥉 Bronze (+50 XP)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'steel', child: Text('🛡️ Steel (+20 XP)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                  ],
                  onChanged: (v) => selectedRank = v ?? 'gold',
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2050));
                    if(picked != null) setState(()=> deadline = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(24)),
                    child: Text(deadline == null ? 'Set Deadline (Optional)' : 'Deadline: ${deadline.toString().substring(0, 10)}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: deadline == null ? config.textMuted : config.primaryAccent)),
                  ),
                ),
                if (deadline != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                    child: TextField(
                      controller: penaltyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "XP Penalty if missed"),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (titleCtrl.text.isNotEmpty) {
                      provider.addQuest(
                        titleCtrl.text,
                        selectedRank,
                        'Repeating',
                        1,
                        null,
                        deadline: deadline,
                        xpPenalty: int.tryParse(penaltyCtrl.text) ?? 0,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: config.primaryAccent, borderRadius: BorderRadius.circular(32)),
                    alignment: Alignment.center,
                    child: Text('CREATE', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCounterDialog(BuildContext context, LifeProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    final titleCtrl = TextEditingController();
    final xpCtrl = TextEditingController(text: '10');
    String selectedIcon = 'bolt';
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: config.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Counter', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "Attribute (e.g. Pushups)"),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: xpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "XP base reward (e.g. 10)"),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedIcon,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: config.softBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: [
                    DropdownMenuItem(value: 'bolt', child: Text('⚡ Bolt', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'fitness_center', child: Text('🏋️ Fitness', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'water_drop', child: Text('💧 Water', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'book', child: Text('📚 Book', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold))),
                  ],
                  onChanged: (v) => selectedIcon = v ?? 'bolt',
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (titleCtrl.text.isNotEmpty) {
                      provider.addWorkCounter(
                        titleCtrl.text,
                        xpReward: int.tryParse(xpCtrl.text) ?? 10,
                        iconData: selectedIcon,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: config.primaryAccent, borderRadius: BorderRadius.circular(32)),
                    alignment: Alignment.center,
                    child: Text('ADD', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showAddEventDialog(BuildContext context, LifeProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    final titleCtrl = TextEditingController();
    final now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: config.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save Event', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "Event Name"),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                  GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                        context: ctx, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime(2050));
                    if (pickedDate != null) {
                      if (!ctx.mounted) return;
                      final pickedTime = await showTimePicker(
                          context: ctx, initialTime: TimeOfDay.fromDateTime(date));
                      if (pickedTime != null) {
                        setState(() {
                          date = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
                              pickedTime.hour, pickedTime.minute);
                        });
                      } else {
                        setState(() {
                          date = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, date.hour, date.minute);
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(24)),
                    child: Text(date.toString().substring(0, 16), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: config.primaryAccent)),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (titleCtrl.text.isNotEmpty) {
                      provider.addEvent(titleCtrl.text, 'other', date, false);
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: config.primaryAccent, borderRadius: BorderRadius.circular(32)),
                    alignment: Alignment.center,
                    child: Text('SAVE', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showAddNoteDialog(BuildContext context, LifeProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    final titleCtrl = TextEditingController();
    bool isTemp = false;
    DateTime? expiryDate;
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: config.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pin Note', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "Note Content..."),
                    maxLines: 3,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Self Destruct (Temporary)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  value: isTemp,
                  activeColor: config.primaryAccent,
                  onChanged: (v) {
                    setState(() {
                      isTemp = v ?? false;
                      if (isTemp && expiryDate == null) {
                        expiryDate = DateTime.now().add(const Duration(days: 1));
                      }
                    });
                  },
                ),
                if (isTemp) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(context: ctx, initialDate: expiryDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2050));
                      if (picked != null) setState(() => expiryDate = picked);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(24)),
                      child: Text(
                        'Expires: ${expiryDate?.toString().substring(0, 10)}',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: config.primaryAccent),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (titleCtrl.text.isNotEmpty) {
                      provider.addNote(titleCtrl.text, isTemp ? 'temporary' : 'permanent', isTemp ? expiryDate : null);
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: config.primaryAccent, borderRadius: BorderRadius.circular(32)),
                    alignment: Alignment.center,
                    child: Text('PIN', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FabBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FabBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: config.softBg,
          border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Icon(icon, color: config.primaryAccent, size: 20),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

// ====================== VIEWS =========================

class _QuestsView extends StatelessWidget {
  final LifeProvider provider;
  final Function(int, TapDownDetails, BuildContext) onXP;
  
  const _QuestsView({required this.provider, required this.onXP});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final quests = provider.quests.where((q) => !q.isCompleted).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('ACTIVE QUESTS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted, letterSpacing: 1.5)),
          ),
          if (quests.isEmpty)
             Padding(
               padding: const EdgeInsets.all(24),
               child: Center(child: Text("No quests yet.", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: config.textMuted.withValues(alpha: 0.6)))),
             )
          else
            ...quests.map((q) => _buildQuestCard(q, context)),
        ],
    
      ),
    );
  }

  Widget _buildQuestCard(Quest quest, BuildContext context) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    Color rankColor = _gold;
    String rEmoji = '🥇';
    int xp = 150;
    
    if (quest.rank == 'silver') { rankColor = _silver; rEmoji = '🥈'; xp = 100;}
    else if (quest.rank == 'bronze') { rankColor = _bronze; rEmoji = '🥉'; xp = 50;}
    else if (quest.rank == 'steel') { rankColor = _steel; rEmoji = '🛡️'; xp = 20;}
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      // "Cute Card" styling
      decoration: BoxDecoration(
        color: config.cardColor,
        borderRadius: BorderRadius.circular(40),
        border: Border(left: BorderSide(color: rankColor, width: 8)),
        boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.08), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: rankColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Icon(Icons.stars, color: rankColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest.title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: config.textMain, decoration: quest.isCompleted ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 2),
                Text('$rEmoji ${quest.rank.toUpperCase()} • +$xp XP', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: config.textMuted, letterSpacing: 1)),
                if (quest.deadline != null) ...[
                  const SizedBox(height: 4),
                  Text('⏰ ${quest.deadline!.toString().substring(0, 10)} ${quest.xpPenalty > 0 ? '(Penalty: -${quest.xpPenalty} XP)' : ''}', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: config.primaryAccent.withValues(alpha: 0.8))),
                ]
              ],
            ),
          ),
          GestureDetector(
            onTapDown: (details) {
              if(!quest.isCompleted) {
                 // Trigger the XP animation instantly
                 onXP(xp, details, context);
                 // Delay the actual state update so the item is redrawn as completed for a split second, then removed
                 Future.delayed(const Duration(milliseconds: 300), () {
                    provider.updateQuestProgress(quest, quest.targetProgress);
                 });
              } else {
                 provider.deleteQuest(quest);
              }
            },
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: quest.isCompleted ? Colors.transparent : config.textMuted.withValues(alpha: 0.4), width: 2),
                color: quest.isCompleted ? config.primaryAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(6)
              ),
              alignment: Alignment.center,
              child: quest.isCompleted ? Icon(Icons.check, size: 16, color: config.cardColor) : null,
            ),
          )
        ],
      ),
    );
  }
}

class _WorkView extends StatelessWidget {
  final LifeProvider provider;
  final Function(int, TapDownDetails, BuildContext) onXP;
  
  const _WorkView({required this.provider, required this.onXP});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final counters = provider.counters;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text('WORK ATTRIBUTES', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted, letterSpacing: 1.5)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: counters.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemBuilder: (ctx, idx) {
                final c = counters[idx];
                return GestureDetector(
                    onTapDown: (details) {
                     provider.incrementCounter(c);
                     onXP(c.xpReward, details, context);
                  },
                  onLongPress: () {
                     provider.deleteCounter(c);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: config.cardColor,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.08), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 10))],
                      border: Border.all(color: config.primaryAccent.withValues(alpha: 0.05)),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => provider.deleteCounter(c),
                            child: Icon(Icons.close, size: 16, color: config.textMuted.withValues(alpha: 0.6)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: double.infinity), // forces centering across width
                            Icon(c.iconData == 'fitness_center' ? Icons.fitness_center : c.iconData == 'water_drop' ? Icons.water_drop : c.iconData == 'book' ? Icons.book : Icons.bolt, color: config.primaryAccent.withValues(alpha: 0.8), size: 32),
                        const SizedBox(height: 12),
                        Text(c.title.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted.withValues(alpha: 0.6), letterSpacing: 1)),
                        const SizedBox(height: 8),
                            Text('${c.count}', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: config.textMain)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        )
    );
  }
}

class _NotesView extends StatelessWidget {
  final LifeProvider provider;
  const _NotesView({required this.provider});

  void _showNoteDetail(BuildContext context, dynamic n, ThemeProvider themeProv) {
    final config = themeProv.config;
    bool isTemp = n.noteType == 'temporary';
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: isTemp ? const Color(0xFFFFFACD) : config.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(isTemp ? Icons.emergency : Icons.push_pin, size: 24, color: isTemp ? Colors.red.shade700 : config.primaryAccent),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, size: 24, color: isTemp ? Colors.black54 : config.textMuted.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      n.content,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isTemp ? Colors.black87 : config.textMain,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                if(isTemp)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('EXP: ${n.expiresAt.toString().substring(0,10)}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black54, fontStyle: FontStyle.italic)),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final notes = provider.notes;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemBuilder: (ctx, idx) {
             final n = notes[idx];
             bool isTemp = n.noteType == 'temporary';
             return GestureDetector(
               onTap: () => _showNoteDetail(context, n, themeProv),
               onLongPress: () => provider.deleteNote(n),
               child: Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: isTemp ? const Color(0xFFFFFACD) : config.cardColor,
                   borderRadius: BorderRadius.circular(40),
                   border: Border(bottom: BorderSide(color: isTemp ? const Color(0xFFFDE68A) : Colors.transparent, width: 6)),
                   boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.08), blurRadius: 20, spreadRadius: -5, offset: Offset(0, 10))],
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Icon(isTemp ? Icons.emergency : Icons.push_pin, size: 14, color: isTemp ? Colors.red.shade700 : config.primaryAccent),
                         GestureDetector(
                           onTap: () => provider.deleteNote(n),
                           child: Icon(Icons.close, size: 16, color: isTemp ? Colors.black54 : config.textMuted.withValues(alpha: 0.6)),
                         ),
                       ],
                     ),
                     const SizedBox(height: 12),
                     Expanded(child: Text(n.content, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: isTemp ? Colors.black87 : config.textMuted, height: 1.5), overflow: TextOverflow.fade)),
                     if(isTemp)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('EXP: ${n.expiresAt.toString().substring(0,10)}', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black54, fontStyle: FontStyle.italic)),
                        )
                   ],
                 ),
               ),
             );
          },
        ),
    );
  }
}

class _EventsView extends StatelessWidget {
  final LifeProvider provider;
  const _EventsView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final events = List<LifeEvent>.from(provider.events)
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
             child: Text('EVENT MANAGER', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted, letterSpacing: 1.5)),
          ),
          ...events.map((e) {
             final days = e.daysUntil;
             String badgeText = days == 0 ? "TODAY!" : (days < 0 ? "PASSED" : "IN $days DAYS");
             return GestureDetector(
               onLongPress: () => provider.deleteEvent(e),
               child: Container(
                 margin: const EdgeInsets.only(bottom: 16),
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: config.cardColor,
                   borderRadius: BorderRadius.circular(32),
                   boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: -5, offset: Offset(0, 10))],
                 ),
                 child: Row(
                   children: [
                     Container(
                       width: 56, height: 56,
                       decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(24)),
                       alignment: Alignment.center,
                       child: Text(e.eventType == 'birthday' ? '🎂' : '📅', style: TextStyle(fontSize: 24)),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(e.name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: config.textMain)),
                           const SizedBox(height: 2),
                           Builder(builder: (ctx) {
                             String timeStr = (e.date.hour != 0 || e.date.minute != 0) ? " @ ${e.date.hour.toString().padLeft(2, '0')}:${e.date.minute.toString().padLeft(2, '0')}" : "";
                             return Text(e.eventType.toUpperCase() + timeStr, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: config.textMuted.withValues(alpha: 0.6)));
                           }),
                         ],
                       ),
                     ),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(color: _softRed, borderRadius: BorderRadius.circular(99)),
                       child: Text(badgeText, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent)),
                     ),
                     const SizedBox(width: 8),
                     GestureDetector(
                       onTap: () => provider.deleteEvent(e),
                       child: Icon(Icons.close, size: 18, color: config.textMuted.withValues(alpha: 0.6)),
                     ),
                   ],
                 ),
               ),
             );
          })
        ],
      )
    );
  }
}

class _StatsView extends StatefulWidget {
  final LifeProvider provider;
  const _StatsView({required this.provider});

  @override
  State<_StatsView> createState() => _StatsViewState();
}
class _StatsViewState extends State<_StatsView> {
  late Timer _t; String _s = "";
  @override
  void initState() {
     super.initState();
     _update();
     _t = Timer.periodic(const Duration(seconds: 1), (t)=> _update());
  }
  @override
  void dispose() { _t.cancel(); super.dispose(); }
  void _update() {
    final n = DateTime.now();
    setState(() {
      _s = '${n.hour.toString().padLeft(2,'0')}:${n.minute.toString().padLeft(2,'0')}:${n.second.toString().padLeft(2,'0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
             child: Text('COMMANDER PERFORMANCE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted, letterSpacing: 1.5)),
          ),
          GridView.count(
             crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
             crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5,
             children: [
               _statBox('Success Rate', '${widget.provider.successRate.toStringAsFixed(0)}%', Colors.green.shade500),
               _statBox('Quests Done', '${widget.provider.totalQuestsCompleted}', Colors.orange.shade500),
             ],
          ),
          const SizedBox(height: 24),
          Container(
             width: double.infinity,
             padding: const EdgeInsets.all(32),
             decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(40), boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.2), blurRadius: 20, offset: Offset(0,10))]),
             child: Column(
               children: [
                  Text('INTERNAL CLOCK (IST)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.softBg, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text(_s, style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
               ],
             ),
          ),
          const SizedBox(height: 24),
          _UpcomingEvents(provider: widget.provider),
        ],
      )
    );
  }
  Widget _statBox(String lbl, String val, Color c) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(color: config.cardColor, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: -5, offset: Offset(0, 10))]),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(lbl.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted.withValues(alpha: 0.6))),
           const SizedBox(height: 4),
           Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: c)),
         ],
       )
    );
  }
}

class _UpcomingEvents extends StatelessWidget {
  final LifeProvider provider;
  const _UpcomingEvents({required this.provider});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final activeEvents = provider.events.where((e) => e.daysUntil >= 0 && e.daysUntil <= 5).toList();
    activeEvents.sort((a,b) => a.daysUntil.compareTo(b.daysUntil));

    if(activeEvents.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text('UPCOMING EVENTS (< 5 DAYS)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted, letterSpacing: 1.5)),
         ),
         ...activeEvents.map((e) {
           return Container(
             margin: const EdgeInsets.only(bottom: 12),
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: config.cardColor,
               borderRadius: BorderRadius.circular(24),
               border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2))
             ),
             child: Row(
               children: [
                 Icon(e.eventType == 'birthday' ? Icons.cake : Icons.event, color: config.primaryAccent),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Text(e.name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: config.textMain)),
                 ),
                 Builder(builder: (ctx) {
                   String timeStr = (e.date.hour != 0 || e.date.minute != 0) ? " \n@ ${e.date.hour.toString().padLeft(2, '0')}:${e.date.minute.toString().padLeft(2, '0')}" : "";
                   return Text((e.daysUntil == 0 ? "TODAY" : "IN ${e.daysUntil} DAYS") + timeStr, textAlign: TextAlign.right, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: config.primaryAccent));
                 })
               ]
             )
           );
         })
      ],
    );
  }
}

// ====================== UTILS =========================

class _FloatingXP {
  final String id;
  final int amount;
  final Offset offset;
  _FloatingXP({required this.id, required this.amount, required this.offset});
}

class _AnimatedXP extends StatefulWidget {
  final int amount;
  final Offset startOffset;
  const _AnimatedXP({super.key, required this.amount, required this.startOffset});

  @override
  State<_AnimatedXP> createState() => _AnimatedXPState();
}

class _AnimatedXPState extends State<_AnimatedXP> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _op;
  late Animation<double> _dy;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _op = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _dy = Tween<double>(begin: 0.0, end: -60.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) {
        return Positioned(
          left: widget.startOffset.dx - 20,
          top: widget.startOffset.dy + _dy.value - 20,
          child: Opacity(
            opacity: _op.value,
            child: Text('+${widget.amount} XP', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: config.primaryAccent, shadows: [Shadow(color: config.cardColor, blurRadius: 4)])),
          ),
        );
      },
    );
  }
}