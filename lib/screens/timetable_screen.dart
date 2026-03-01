import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../logic/timetable_provider.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimetableProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        elevation: 0,
        actions: [
          // AI Import Button
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Auto-Import',
            onPressed: () => _showAiHelper(context, provider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.red.shade700,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          indicatorColor: Colors.redAccent,
          indicatorWeight: 2,
          physics: const BouncingScrollPhysics(),
          tabs: const [
            Tab(text: 'Mon'),
            Tab(text: 'Tue'),
            Tab(text: 'Wed'),
            Tab(text: 'Thu'),
            Tab(text: 'Fri'),
            Tab(text: 'Sat'),
            Tab(text: 'Sun'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(7, (index) {
          final day = index + 1; // 1 = Mon, 7 = Sun
          return _DayScheduleView(day: day, provider: provider);
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showManualAdd(context, provider),
        backgroundColor: Colors.red.shade600,
        child: const Icon(Icons.add),
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
      color: const Color(0xFFFBF8FF),
      child: isToday
        ? Column(
            children: [
              // Fixed Now & Upcoming section
              Container(
                color: const Color(0xFFFBF8FF),
                padding: const EdgeInsets.all(16),
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
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text('Upcoming', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: upcoming.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('No upcoming classes', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                          )
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                for (var item in upcoming)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                                    child: Dismissible(
                                                      key: ValueKey('upcoming-${item.id}'),
                                                      direction: DismissDirection.up,
                                                      background: Container(
                                                        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(12)),
                                                        alignment: Alignment.center,
                                                        child: const Icon(Icons.delete, color: Colors.white),
                                                      ),
                                                      confirmDismiss: (_) async {
                                                        final res = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                                                          title: const Text('Delete'),
                                                          content: const Text('Remove this class?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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

              // Fixed Today's Schedule header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Today's Schedule", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)
                ),
              ),
              const SizedBox(height: 12),

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
    final bgColor = isActive ? Colors.red.shade600 : Colors.white;
    final txtColor = isActive ? Colors.white : Colors.black87;
    
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive ? [BoxShadow(color: bgColor.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 6))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        border: isActive ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(title, style: TextStyle(color: txtColor.withValues(alpha: 0.95), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    item == null
                          ? Text(isActive ? "Free Time" : "Nothing later", key: const ValueKey('empty'), style: TextStyle(color: txtColor, fontSize: 14, fontWeight: FontWeight.w600))
                          : Column(
                              key: ValueKey(item!.id),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item!.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: txtColor, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${item!.location} • ${_fmt(item!.startHour, item!.startMinute)}",
                                  style: TextStyle(color: txtColor.withValues(alpha: 0.9), fontSize: 12),
                                ),
                              ],
                            ),
                  ]),
                ),
                if (isActive) const SizedBox(width: 8),
                if (isActive) Icon(Icons.circle, size: 12, color: Colors.white.withValues(alpha: 0.9)),
              ]),
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
    // All class tiles now have red stripe
    final Color stripeColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExam ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isExam ? Border.all(color: Colors.red.shade200) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Colored Stripe
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: stripeColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: isExam ? Colors.red.shade900 : Colors.black87
                          )
                        ),
                        if (isExam) 
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.location} • ${_fmt(item.startHour, item.startMinute)} - ${_fmt(item.endHour, item.endMinute)}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            // Attendance / Delete Buttons
            // Only show Attendance check if the class has passed or started
            if (_hasStarted(item))
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle, color: item.attended == true ? Colors.green : Colors.grey.shade300),
                    onPressed: () => provider.toggleAttendance(item, true),
                    tooltip: "Attended",
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: item.attended == false ? Colors.red : Colors.grey.shade300),
                    onPressed: () => provider.toggleAttendance(item, false),
                    tooltip: "Missed",
                  ),
                ],
              )
            else
               IconButton(
                 icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                 onPressed: () async {
                   final messenger = ScaffoldMessenger.of(context);
                   final res = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                     title: const Text('Delete item'),
                     content: const Text('Remove this item from timetable?'),
                     actions: [
                       TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                       FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                     ],
                   ));
                   if (res == true) {
                     provider.deleteItem(item);
                     messenger.showSnackBar(const SnackBar(content: Text('Item deleted')));
                   }
                 },
               ),
             const SizedBox(width: 4),
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
      width: 160,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (item.type == 'exam') Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Text(start, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
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