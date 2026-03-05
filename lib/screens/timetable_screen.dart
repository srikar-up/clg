import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/timetable_provider.dart';
import '../logic/theme_provider.dart';
import '../data/models.dart';


class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Start on the current day (Monday = 0, so weekday - 1)
    _tabController = TabController(length: 7, vsync: this, initialIndex: DateTime.now().weekday - 1);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TimetableProvider>(context, listen: false);
      if (provider.checkWeeklyResetNeeded()) {
        _showWeeklyResetDialog(provider);
      }
    });
  }

  void _showWeeklyResetDialog(TimetableProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("New Week Started!"),
        content: Text("A new week has begun. Do you want to keep last week's timetable or clear it and start fresh?"),
        actions: [
          TextButton(
            onPressed: () {
              provider.confirmWeeklyReset(false); // Keep items, clear attendance
              Navigator.pop(ctx);
            },
            child: Text("Keep Previous"),
          ),
          FilledButton(
            onPressed: () {
              provider.confirmWeeklyReset(true); // Clear items
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: config.primaryAccent),
            child: Text("Clear Timetable"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final provider = context.watch<TimetableProvider>();

    return Scaffold(
      backgroundColor: config.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Floating Custom Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: config.cardColor,
                border: Border(bottom: BorderSide(color: config.softBg)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Life OS', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: config.textMain, letterSpacing: -0.5)),
                      Text('TIMETABLE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAiHelper(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: config.softBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: config.primaryAccent.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.smart_toy, size: 12, color: config.primaryAccent),
                              const SizedBox(width: 6),
                              Text('AI SYNC', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.primaryAccent)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              color: config.cardColor,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                indicator: BoxDecoration(
                  color: config.primaryAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: config.primaryAccent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: config.cardColor,
                unselectedLabelColor: config.textMuted,
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                physics: const BouncingScrollPhysics(),
                tabs: const [
                  Tab(height: 36, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('MON'))),
                  Tab(height: 36, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('TUE'))),
                  Tab(height: 36, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('WED'))),
                  Tab(height: 36, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('THU'))),
                  Tab(height: 36, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('FRI'))),
                  Tab(height: 36, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('SAT'))),
                  Tab(height: 36, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('SUN'))),
                ],
              ),
            ),

            // Timetable Content Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(7, (index) {
                  final day = index + 1; // 1 = Mon, 7 = Sun
                  return _DayScheduleView(day: day, provider: provider);
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditClassSheet(context, provider),
        backgroundColor: config.primaryAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 8,
        child: Icon(Icons.add, color: config.cardColor),
      ),
    );
  }

  // --- DIALOGS ---

  void _showAiHelper(BuildContext context, TimetableProvider provider) {
    final config = Provider.of<ThemeProvider>(context, listen: false).config;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("AI Auto-Import"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "1. Copy Prompt.\n2. Paste in ChatGPT with your timetable image.\n3. Paste the JSON result here.",
              style: TextStyle(fontSize: 12, color: config.textMuted),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(
                    text: "Convert this timetable image to a JSON array. Fields: title, location, day (e.g. Monday), startTime (HH:MM), endTime (HH:MM), type (class/exam/event)."));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prompt copied to clipboard!")));
              },
              icon: Icon(Icons.copy, size: 16),
              label: Text("Copy Prompt"),
              style: FilledButton.styleFrom(backgroundColor: config.primaryAccent),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Paste JSON here"),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          FilledButton(
            onPressed: () {
              final res = provider.importJson(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
            },
            style: FilledButton.styleFrom(backgroundColor: config.primaryAccent),
            child: Text("Import"),
          )
        ],
      ),
    );
  }

}

void showAddEditClassSheet(BuildContext context, TimetableProvider provider, {ScheduleItem? editItem}) {
  final config = Provider.of<ThemeProvider>(context, listen: false).config;
  final titleCtrl = TextEditingController(text: editItem?.title ?? '');
  final locCtrl = TextEditingController(text: editItem?.location ?? '');
  int selectedDay = editItem?.weekday ?? DateTime.now().weekday;
  TimeOfDay startTime = editItem != null ? TimeOfDay(hour: editItem.startHour, minute: editItem.startMinute) : TimeOfDay.now();
  TimeOfDay endTime = editItem != null ? TimeOfDay(hour: editItem.endHour, minute: editItem.endMinute) : TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: TimeOfDay.now().minute);
  String type = editItem?.type ?? 'class';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx2, setState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(editItem == null ? "Add Class" : "Edit Class", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(ctx2), icon: Icon(Icons.close))
              ]),
              const SizedBox(height: 8),
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: "Subject")),
              const SizedBox(height: 8),
              TextField(controller: locCtrl, decoration: InputDecoration(labelText: "Location")),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedDay,
                    decoration: InputDecoration(labelText: 'Day'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Mon')),
                      DropdownMenuItem(value: 2, child: Text('Tue')),
                      DropdownMenuItem(value: 3, child: Text('Wed')),
                      DropdownMenuItem(value: 4, child: Text('Thu')),
                      DropdownMenuItem(value: 5, child: Text('Fri')),
                      DropdownMenuItem(value: 6, child: Text('Sat')),
                      DropdownMenuItem(value: 7, child: Text('Sun')),
                    ],
                    onChanged: (v) { if (v != null) setState(() => selectedDay = v); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: type,
                    decoration: InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'class', child: Text('Class')),
                      DropdownMenuItem(value: 'exam', child: Text('Exam')),
                      DropdownMenuItem(value: 'event', child: Text('Event')),
                    ],
                    onChanged: (v) { if (v != null) setState(() => type = v); },
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(context: ctx2, initialTime: startTime);
                      if (t != null) setState(() => startTime = t);
                    },
                    child: Text('Start: ${startTime.format(ctx2)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(context: ctx2, initialTime: endTime);
                      if (t != null) setState(() => endTime = t);
                    },
                    child: Text('End: ${endTime.format(ctx2)}'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                if (editItem != null) ...[
                  IconButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                        title: Text('Delete Class'),
                        content: Text('Remove this class from timetable?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: config.primaryAccent), child: Text('Delete')),
                        ],
                      ));
                      if (confirmed == true) {
                        provider.deleteItem(editItem);
                        if (context.mounted) Navigator.pop(ctx2);
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a subject')));
                        return;
                      }
                      
                      final updatedItem = ScheduleItem(
                        id: editItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleCtrl.text.trim(),
                        location: locCtrl.text.trim(),
                        weekday: selectedDay,
                        startHour: startTime.hour,
                        startMinute: startTime.minute,
                        endHour: endTime.hour,
                        endMinute: endTime.minute,
                        type: type,
                        attended: editItem?.attended,
                      );

                      if (editItem != null) {
                        provider.editItem(editItem, updatedItem);
                      } else {
                        provider.addItem(updatedItem);
                      }
                      Navigator.pop(ctx2);
                    },
                    style: FilledButton.styleFrom(backgroundColor: config.primaryAccent),
                    child: Text(editItem == null ? 'Save' : 'Update'),
                  ),
                ),
              ])
            ]),
          );
        }),
      );
    }
  );
}

class _DayScheduleView extends StatefulWidget {
  final int day;
  final TimetableProvider provider;

  const _DayScheduleView({required this.day, required this.provider});

  @override
  State<_DayScheduleView> createState() => _DayScheduleViewState();
}

class _DayScheduleViewState extends State<_DayScheduleView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final day = widget.day;
    final provider = widget.provider;
    final bool isToday = day == DateTime.now().weekday;
    final items = provider.getItemsForDay(day);

    // Dashboard Data (Only calculated if today)
    final status = isToday ? provider.getNowAndNext() : null;
    final isLunch = isToday ? provider.isLunchGap() : false;

    return Container(
      color: Colors.transparent,
      child: isToday
        ? Column(
            children: [
              // Fixed Now & Upcoming section
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(builder: (ctx, constraints) {
                  final now = TimeOfDay.now();
                  final nowMin = now.hour * 60 + now.minute;
                  final todayItems = items;
                  final upcoming = todayItems.where((i) => (i.startHour * 60 + i.startMinute) > nowMin).toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NOW card (left)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.48),
                        child: _StatusCard(key: ValueKey(status?['current']?.id ?? 'now'), title: 'NOW', item: status?['current'], isActive: true),
                      ),
                      const SizedBox(width: 12),

                      // Upcoming list (right)
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: config.cardColor,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: config.cardColor, width: 2),
                            boxShadow: [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.12), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('UPCOMING', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted.withValues(alpha: 0.6), letterSpacing: 1.5)),
                                    if (provider.getNowAndNext()['next'] != null)
                                      Text(provider.getTimeToNextClass(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: config.primaryAccent)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: upcoming.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text('Free time ✨', style: GoogleFonts.plusJakartaSans(color: config.textMuted.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold)),
                                          )
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Row(
                                              children: [
                                                for (var item in upcoming)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    child: Dismissible(
                                                      key: ValueKey('upcoming-${item.id}'),
                                                      direction: DismissDirection.up,
                                                      background: Container(
                                                        decoration: BoxDecoration(color: config.primaryAccent, borderRadius: BorderRadius.circular(24)),
                                                        alignment: Alignment.center,
                                                        child: Icon(Icons.delete, color: config.cardColor),
                                                      ),
                                                      confirmDismiss: (_) async {
                                                        final res = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                                                          title: Text('Delete'),
                                                          content: Text('Remove this class?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                                            FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: config.primaryAccent), child: Text('Delete')),
                                                          ],
                                                        ));
                                                        return res ?? false;
                                                      },
                                                      onDismissed: (_) {
                                                        provider.deleteItem(item);
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                                                      },
                                                      child: _UpcomingTile(item: item, provider: provider),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // Daily Progress Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TODAY'S SCHEDULE", 
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: config.textMuted, letterSpacing: 1.5)
                    ),
                    if (items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          "${(provider.calculateDailyProgress(day) * 100).toInt()}% Done",
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green.shade700)
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Scrollable schedule content
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  interactive: true,
                  radius: const Radius.circular(8),
                  child: ListView(
                    controller: _scrollController,
                    primary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Lunch Alert
                      if (isLunch)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.restaurant, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Lunch Break!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    Text("12 PM - 3 PM Gap detected.", style: TextStyle(color: config.textMain.withValues(alpha: 0.87), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // --- TIMETABLE LIST SECTION ---
                      if (items.isEmpty) 
                         Padding(
                           padding: const EdgeInsets.only(top: 60),
                           child: Center(
                             child: Column(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(24),
                                   decoration: BoxDecoration(color: config.cardColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: config.textMain.withValues(alpha: 0.05), blurRadius: 20)]),
                                   child: Icon(Icons.celebration_rounded, size: 48, color: config.primaryAccent),
                                 ),
                                 const SizedBox(height: 20),
                                 Text("No classes today!", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: config.textMain)),
                                 const SizedBox(height: 4),
                                 Text("Enjoy your free time.", style: GoogleFonts.plusJakartaSans(color: config.textMuted, fontWeight: FontWeight.w600)),
                               ],
                             ),
                           ),
                         )
                      else
                        for (var item in items) _ClassTile(key: ValueKey(item.id), item: item, provider: provider),
                      
                      // Extra padding at bottom for FAB
                      const SizedBox(height: 80), 
                    ],
                  ),
                ),
              ),
            ],
          )
        : Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            radius: const Radius.circular(8),
            child: ListView(
              controller: _scrollController,
              primary: false,
              padding: const EdgeInsets.all(16),
              children: [
                // --- TIMETABLE LIST SECTION ---
                if (items.isEmpty) 
                   Padding(
                     padding: const EdgeInsets.only(top: 40),
                     child: Center(
                       child: Column(
                         children: [
                           Icon(Icons.event_busy, size: 48, color: config.textMuted.withValues(alpha: 0.4)),
                           const SizedBox(height: 10),
                           Text("No classes scheduled.", style: TextStyle(color: config.textMuted)),
                         ],
                       ),
                     ),
                   )
                else
                  for (var item in items) _ClassTile(key: ValueKey(item.id), item: item, provider: provider),
                
                // Extra padding at bottom for FAB
                const SizedBox(height: 80), 
              ],
            ),
          ),
    );
  }
}

// --- WIDGETS ---

class _StatusCard extends StatelessWidget {
  final String title;
  final ScheduleItem? item;
  final bool isActive;

  const _StatusCard({super.key, required this.title, required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isActive ? null : config.cardColor,
        gradient: isActive ? LinearGradient(colors: [config.gradStart, config.gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isActive ? [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.3), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))] : [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.05), blurRadius: 20, spreadRadius: -10, offset: Offset(0, 10))],
        border: Border.all(color: config.cardColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 4),
            child: Text(title, style: GoogleFonts.plusJakartaSans(color: isActive ? config.cardColor.withValues(alpha: 0.70) : config.textMuted.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        item == null
                            ? Text(isActive ? "Free Time" : "Nothing later", key: const ValueKey('empty'), style: GoogleFonts.plusJakartaSans(color: isActive ? config.cardColor : config.textMain, fontSize: 16, fontWeight: FontWeight.w900))
                            : Column(
                                key: ValueKey(item!.id),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item!.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(color: isActive ? config.cardColor : config.textMain, fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item!.location} • ${_fmt(item!.startHour, item!.startMinute)}",
                                    style: GoogleFonts.plusJakartaSans(color: isActive ? config.cardColor.withValues(alpha: 0.70) : config.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  if (isActive) const SizedBox(width: 8),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: config.cardColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Icon(Icons.bolt, color: config.cardColor, size: 16),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _fmt(int h, int m) => "${h == 0 ? 12 : (h > 12 ? h - 12 : h)}:${m.toString().padLeft(2, '0')}";
}

class _ClassTile extends StatelessWidget {
  final ScheduleItem item;
  final TimetableProvider provider;

  const _ClassTile({super.key, required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final bool isExam = item.type == 'exam';
    final Color stripeColor = isExam ? Colors.orange : config.primaryAccent;

    return GestureDetector(
      onTap: () => showAddEditClassSheet(context, provider, editItem: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: config.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: config.cardColor, width: 2),
          boxShadow: [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.08), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored Stripe
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: stripeColor,
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title, 
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900, 
                                fontSize: 18,
                                color: config.textMain
                              )
                            ),
                          ),
                          if (isExam) 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Text('EXAM', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.orange.shade800, letterSpacing: 1.5)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: config.softBg, borderRadius: BorderRadius.circular(8)),
                              child: Text(item.type.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: config.primaryAccent, letterSpacing: 1.5)),
                            )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: config.textMuted.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(item.location, style: GoogleFonts.plusJakartaSans(color: config.textMuted, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time_filled, size: 14, color: config.textMuted.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text("${_fmt(item.startHour, item.startMinute)} - ${_fmt(item.endHour, item.endMinute)}", style: GoogleFonts.plusJakartaSans(color: config.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Attendance / Delete Buttons
              // Only show Attendance check if the class has passed or started
              if (_hasStarted(item))
                Container(
                  decoration: BoxDecoration(border: Border(left: BorderSide(color: config.softBg))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, size: 28, color: item.attended == true ? Colors.green : config.textMuted.withValues(alpha: 0.2)),
                        onPressed: () => provider.toggleAttendance(item, true),
                        tooltip: "Attended",
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, size: 28, color: item.attended == false ? config.primaryAccent : config.textMuted.withValues(alpha: 0.2)),
                        onPressed: () => provider.toggleAttendance(item, false),
                        tooltip: "Missed",
                      ),
                    ],
                  ),
                )
              else
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: IconButton(
                     icon: Icon(Icons.delete_outline, size: 24, color: config.primaryAccent),
                     onPressed: () async {
                       final messenger = ScaffoldMessenger.of(context);
                       final res = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                         title: Text('Delete item'),
                         content: Text('Remove this item from timetable?'),
                         actions: [
                           TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                           FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: config.primaryAccent), child: Text('Delete')),
                         ],
                       ));
                       if (res == true) {
                         provider.deleteItem(item);
                         messenger.showSnackBar(const SnackBar(content: Text('Item deleted')));
                       }
                     },
                   ),
                 ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasStarted(ScheduleItem item) {
    // Check if current time > start time (on Today) OR if day is in past
    final now = DateTime.now();
    if (item.weekday < now.weekday) return true;
    if (item.weekday > now.weekday) return false;
    // Same day logic
    final nowMin = now.hour * 60 + now.minute;
    final startMin = item.startHour * 60 + item.startMinute;
    return nowMin >= startMin;
  }

  String _fmt(int h, int m) {
    final suffix = h >= 12 ? "PM" : "AM";
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return "$hour12:${m.toString().padLeft(2, '0')} $suffix";
  }
}

// Compact tile for upcoming list
class _UpcomingTile extends StatelessWidget {
  final ScheduleItem item;
  final TimetableProvider provider;

  const _UpcomingTile({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final config = themeProv.config;
    final start = _fmt(item.startHour, item.startMinute);
    return Container(
      width: 150,
      height: 72,
      decoration: BoxDecoration(
        color: config.softBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: config.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (item.type == 'exam') Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade400, size: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Text(start, style: GoogleFonts.plusJakartaSans(color: config.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  String _fmt(int h, int m) {
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:${m.toString().padLeft(2, '0')} $suffix';
  }
}