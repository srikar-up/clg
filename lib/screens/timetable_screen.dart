import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/timetable_provider.dart';
import '../data/models.dart';

const _bgPrimary = Color(0xFFFEF2F2);
const _textPrimary = Color(0xFF111827);
const _gradStart = Color(0xFFEF4444);
const _gradEnd = Color(0xFF991B1B);
const _red600 = Color(0xFFDC2626);

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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimetableProvider>();

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Floating Custom Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Life OS', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -0.5)),
                      Text('TIMETABLE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1.5)),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAiHelper(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.smart_toy, size: 12, color: _red600),
                              const SizedBox(width: 6),
                              Text('AI SYNC', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600)),
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
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                indicator: BoxDecoration(
                  color: _red600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.red.shade200, blurRadius: 8, offset: const Offset(0, 4))],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade500,
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
        onPressed: () => _showManualAdd(context, provider),
        backgroundColor: _red600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- DIALOGS ---

  void _showAiHelper(BuildContext context, TimetableProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("AI Auto-Import"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "1. Copy Prompt.\n2. Paste in ChatGPT with your timetable image.\n3. Paste the JSON result here.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(
                    text: "Convert this timetable image to a JSON array. Fields: title, location, day (e.g. Monday), startTime (HH:MM), endTime (HH:MM), type (class/exam/event)."));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prompt copied to clipboard!")));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text("Copy Prompt"),
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Paste JSON here"),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              final res = provider.importJson(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text("Import"),
          )
        ],
      ),
    );
  }

  void _showManualAdd(BuildContext context, TimetableProvider provider) {
    final titleCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    int selectedDay = DateTime.now().weekday;
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: TimeOfDay.now().minute);
    String type = 'class';

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
                  const Text("Add Class", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx2), icon: const Icon(Icons.close))
                ]),
                const SizedBox(height: 8),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Subject")),
                const SizedBox(height: 8),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: "Location")),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedDay,
                      decoration: const InputDecoration(labelText: 'Day'),
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
                      initialValue: type,
                      decoration: const InputDecoration(labelText: 'Type'),
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
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a subject')));
                          return;
                        }
                        provider.addItem(ScheduleItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          location: locCtrl.text.trim(),
                          weekday: selectedDay,
                          startHour: startTime.hour,
                          startMinute: startTime.minute,
                          endHour: endTime.hour,
                          endMinute: endTime.minute,
                          type: type,
                        ));
                        Navigator.pop(ctx2);
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
                      child: const Text('Save'),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.12), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('UPCOMING', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
                                    if (provider.getNowAndNext()['next'] != null)
                                      Text(provider.getTimeToNextClass(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: _red600)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: upcoming.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text('Free time ✨', style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold)),
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
                                                        decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(24)),
                                                        alignment: Alignment.center,
                                                        child: const Icon(Icons.delete, color: Colors.white),
                                                      ),
                                                      confirmDismiss: (_) async {
                                                        final res = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                                                          title: const Text('Delete'),
                                                          content: const Text('Remove this class?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                            FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: _red600), child: const Text('Delete')),
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
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5)
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
                              const Icon(Icons.restaurant, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("Lunch Break!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    Text("12 PM - 3 PM Gap detected.", style: TextStyle(color: Colors.black87, fontSize: 12)),
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
                                   decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
                                   child: const Icon(Icons.celebration_rounded, size: 48, color: _red600),
                                 ),
                                 const SizedBox(height: 20),
                                 Text("No classes today!", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey.shade800)),
                                 const SizedBox(height: 4),
                                 Text("Enjoy your free time.", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
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
                           Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
                           const SizedBox(height: 10),
                           const Text("No classes scheduled.", style: TextStyle(color: Colors.grey)),
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
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isActive ? null : Colors.white,
        gradient: isActive ? const LinearGradient(colors: [_gradStart, _gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isActive ? const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.3), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))] : const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.05), blurRadius: 20, spreadRadius: -10, offset: Offset(0, 10))],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 4),
            child: Text(title, style: GoogleFonts.plusJakartaSans(color: isActive ? Colors.white70 : Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
                            ? Text(isActive ? "Free Time" : "Nothing later", key: const ValueKey('empty'), style: GoogleFonts.plusJakartaSans(color: isActive ? Colors.white : Colors.grey.shade800, fontSize: 16, fontWeight: FontWeight.w900))
                            : Column(
                                key: ValueKey(item!.id),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item!.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(color: isActive ? Colors.white : Colors.grey.shade800, fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item!.location} • ${_fmt(item!.startHour, item!.startMinute)}",
                                    style: GoogleFonts.plusJakartaSans(color: isActive ? Colors.white70 : Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
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
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 16),
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
    final bool isExam = item.type == 'exam';
    final Color stripeColor = isExam ? Colors.orange : _red600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.08), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
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
                              color: Colors.grey.shade900
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
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text(item.type.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1.5)),
                          )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(item.location, style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_filled, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text("${_fmt(item.startHour, item.startMinute)} - ${_fmt(item.endHour, item.endMinute)}", style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold)),
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
                decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade100))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check_circle, size: 28, color: item.attended == true ? Colors.green : Colors.grey.shade200),
                      onPressed: () => provider.toggleAttendance(item, true),
                      tooltip: "Attended",
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel, size: 28, color: item.attended == false ? Colors.red : Colors.grey.shade200),
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
                   icon: const Icon(Icons.delete_outline, size: 24, color: _red600),
                   onPressed: () async {
                     final messenger = ScaffoldMessenger.of(context);
                     final res = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                       title: const Text('Delete item'),
                       content: const Text('Remove this item from timetable?'),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                         FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: _red600), child: const Text('Delete')),
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
    final start = _fmt(item.startHour, item.startMinute);
    return Container(
      width: 150,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
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
                  child: Text(item.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.grey.shade800), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (item.type == 'exam') Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade400, size: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Text(start, style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
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