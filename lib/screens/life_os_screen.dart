import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/life_provider.dart';
import '../data/models.dart';

class LifeOsScreen extends StatefulWidget {
  const LifeOsScreen({super.key});

  @override
  State<LifeOsScreen> createState() => _LifeOsScreenState();
}

class _LifeOsScreenState extends State<LifeOsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Filters
  String? selectedYear;
  String? selectedMonth;
  String? selectedRank = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life OS'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red.shade600,
          tabs: const [
            Tab(text: 'Quests', icon: Icon(Icons.shield_outlined)),
            Tab(text: 'Work', icon: Icon(Icons.fitness_center)),
            Tab(text: 'Notes', icon: Icon(Icons.sticky_note_2_outlined)),
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Quests Tab
          _QuestsView(provider: provider, onFilterChanged: () => setState(() {})),

          // Work Counters Tab
          _WorkCountersView(provider: provider),

          // Notes Tab
          _NotesView(provider: provider),

          // Stats Tab
          _StatsView(provider: provider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade600,
        onPressed: () => _showFabMenu(context, provider),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  void _showFabMenu(BuildContext context, LifeProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FabMenuItem(
              icon: Icons.shield_outlined,
              label: 'CREATE QUEST',
              onTap: () {
                Navigator.pop(ctx);
                _showCreateQuestDialog(context, provider);
              },
            ),
            const SizedBox(height: 12),
            _FabMenuItem(
              icon: Icons.fitness_center,
              label: 'ADD WORK COUNTER',
              onTap: () {
                Navigator.pop(ctx);
                _showAddCounterDialog(context, provider);
              },
            ),
            const SizedBox(height: 12),
            _FabMenuItem(
              icon: Icons.sticky_note_2_outlined,
              label: 'PIN NOTE',
              onTap: () {
                Navigator.pop(ctx);
                _showAddNoteDialog(context, provider);
              },
            ),
            const SizedBox(height: 12),
            _FabMenuItem(
              icon: Icons.calendar_today,
              label: 'SAVE EVENT',
              onTap: () {
                Navigator.pop(ctx);
                _showAddEventDialog(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateQuestDialog(BuildContext context, LifeProvider provider) {
    final titleCtrl = TextEditingController();
    final rewardCtrl = TextEditingController();
    String selectedRank = 'gold';
    String selectedType = 'repeating';
    int targetProgress = 1;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚔️ Create Quest'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Quest Title',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRank,
                decoration: InputDecoration(
                  labelText: 'Rank',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'gold', child: Text('🥇 Gold (+150 XP)')),
                  DropdownMenuItem(value: 'silver', child: Text('🥈 Silver (+100 XP)')),
                  DropdownMenuItem(value: 'bronze', child: Text('🥉 Bronze (+50 XP)')),
                  DropdownMenuItem(value: 'steel', child: Text('🛡️ Steel (+20 XP)')),
                ],
                onChanged: (val) => selectedRank = val ?? 'gold',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'repeating', child: Text('Repeating')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'reminder', child: Text('Reminder')),
                ],
                onChanged: (val) => selectedType = val ?? 'repeating',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rewardCtrl,
                decoration: InputDecoration(
                  labelText: 'Reward (e.g., Ice Cream)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                provider.addQuest(titleCtrl.text, selectedRank, selectedType, targetProgress, rewardCtrl.text.trim().isEmpty ? null : rewardCtrl.text);
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddCounterDialog(BuildContext context, LifeProvider provider) {
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📈 Add Work Counter'),
        content: TextField(
          controller: titleCtrl,
          decoration: InputDecoration(
            labelText: 'Activity (e.g., Pushups)',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                provider.addWorkCounter(titleCtrl.text);
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, LifeProvider provider) {
    final contentCtrl = TextEditingController();
    String noteType = 'permanent';
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('📝 Pin Note'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentCtrl,
                    decoration: InputDecoration(
                      labelText: 'Note Content',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: noteType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'permanent', child: Text('Permanent')),
                      DropdownMenuItem(value: 'temporary', child: Text('Temporary')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        noteType = val ?? 'permanent';
                      });
                    },
                  ),
                  if (noteType == 'temporary') ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: expiryDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            expiryDate = picked;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        expiryDate == null ? 'Set Expiry Date' : 'Expires: ${expiryDate.toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
              FilledButton(
                onPressed: () {
                  if (contentCtrl.text.trim().isNotEmpty) {
                    provider.addNote(contentCtrl.text, noteType, expiryDate);
                    Navigator.pop(ctx);
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, LifeProvider provider) {
    final nameCtrl = TextEditingController();
    String eventType = 'birthday';
    bool isRecurring = false;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📅 Save Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: eventType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'birthday', child: Text('🎂 Birthday')),
                  DropdownMenuItem(value: 'other', child: Text('📅 Other Event')),
                ],
                onChanged: (val) => eventType = val ?? 'birthday',
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate = picked;
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Date: ${selectedDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                provider.addEvent(nameCtrl.text, eventType, selectedDate, isRecurring);
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ============= QUESTS VIEW =============
class _QuestsView extends StatefulWidget {
  final LifeProvider provider;
  final VoidCallback onFilterChanged;

  const _QuestsView({required this.provider, required this.onFilterChanged});

  @override
  State<_QuestsView> createState() => _QuestsViewState();
}

class _QuestsViewState extends State<_QuestsView> {
  String? selectedYear;
  String? selectedMonth;
  String? selectedRank = 'All';

  @override
  Widget build(BuildContext context) {
    final quests = context.watch<LifeProvider>().quests;

    // Apply filters
    var filtered = quests;
    if (selectedRank != 'All') {
      filtered = filtered.where((q) => q.rank == selectedRank?.toLowerCase()).toList();
    }

    return ListView(
      children: [
        // Filter Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedRank ?? 'All',
                      decoration: InputDecoration(
                        labelText: 'Rank',
                        isDense: true,
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Gold', child: Text('🥇 Gold')),
                        DropdownMenuItem(value: 'Silver', child: Text('🥈 Silver')),
                        DropdownMenuItem(value: 'Bronze', child: Text('🥉 Bronze')),
                        DropdownMenuItem(value: 'Steel', child: Text('🛡️ Steel')),
                      ],
                      onChanged: (val) {
                        setState(() => selectedRank = val);
                        widget.onFilterChanged();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Quests List
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No quests. Create one to start!')),
          )
        else
          ...filtered.map((quest) => _QuestTile(quest: quest, provider: widget.provider)),
      ],
    );
  }
}

class _QuestTile extends StatelessWidget {
  final Quest quest;
  final LifeProvider provider;

  const _QuestTile({required this.quest, required this.provider});

  String _getRankEmoji() {
    switch (quest.rank) {
      case 'gold': return '🥇';
      case 'silver': return '🥈';
      case 'bronze': return '🥉';
      case 'steel': return '🛡️';
      default: return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = quest.targetProgress > 0 ? (quest.currentProgress / quest.targetProgress) : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: quest.isCompleted,
                  fillColor: MaterialStateProperty.all(Colors.red.shade600),
                  onChanged: (val) {
                    if (val == true) {
                      provider.updateQuestProgress(quest, quest.targetProgress);
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getRankEmoji()} ${quest.title}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quest.type} • +${quest.xpReward} XP',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (quest.reward != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '🎁 ${quest.reward}',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => provider.deleteQuest(quest),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.red.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${quest.currentProgress}/${quest.targetProgress}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= WORK COUNTERS VIEW =============
class _WorkCountersView extends StatelessWidget {
  final LifeProvider provider;

  const _WorkCountersView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final counters = context.watch<LifeProvider>().counters;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: counters.length,
      itemBuilder: (ctx, index) {
        final counter = counters[index];
        return _CounterCard(counter: counter, provider: provider);
      },
    );
  }
}

class _CounterCard extends StatelessWidget {
  final WorkCounter counter;
  final LifeProvider provider;

  const _CounterCard({required this.counter, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    counter.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => provider.deleteCounter(counter),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Text(
              '${counter.count}',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red.shade600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.small(
                  heroTag: 'dec-${counter.id}',
                  onPressed: () => provider.decrementCounter(counter),
                  backgroundColor: Colors.red.shade600,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                FloatingActionButton.small(
                  heroTag: 'inc-${counter.id}',
                  onPressed: () => provider.incrementCounter(counter),
                  backgroundColor: Colors.red.shade600,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============= NOTES VIEW =============
class _NotesView extends StatelessWidget {
  final LifeProvider provider;

  const _NotesView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<LifeProvider>().notes;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: notes.length,
      itemBuilder: (ctx, index) {
        final note = notes[index];
        return _NoteCard(note: note, provider: provider);
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final LifeProvider provider;

  const _NoteCard({required this.note, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFACD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note.noteType == 'temporary')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Expires: ${note.expiresAt?.toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 10, color: Colors.orange),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => provider.deleteNote(note),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============= STATS VIEW =============
class _StatsView extends StatelessWidget {
  final LifeProvider provider;

  const _StatsView({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Level Card
        _LevelCard(provider: provider),
        const SizedBox(height: 20),

        // Highlight Cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _HighlightCard(
              label: 'Total XP',
              value: '${provider.totalPoints}',
              color: Colors.amber,
              icon: Icons.stars,
            ),
            _HighlightCard(
              label: 'Quests Done',
              value: '${provider.totalQuestsCompleted}',
              color: Colors.green,
              icon: Icons.check_circle,
            ),
            _HighlightCard(
              label: 'Success Rate',
              value: '${provider.successRate.toStringAsFixed(1)}%',
              color: Colors.blue,
              icon: Icons.trending_up,
            ),
            _HighlightCard(
              label: 'Current Level',
              value: '${provider.currentLevel}',
              color: Colors.purple,
              icon: Icons.shield,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Upcoming Events
        if (provider.upcomingEvents.isNotEmpty) ...[
          const Text('📅 Upcoming Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...provider.upcomingEvents.map((event) => _EventTile(event: event)),
          const SizedBox(height: 20),
        ],

        // IST Clock
        _ISTClock(),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LifeProvider provider;

  const _LevelCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.purple.shade400]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT LEVEL', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                  Text('${provider.currentLevel}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('TOTAL XP', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                  Text('${provider.totalPoints}', style: const TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.levelProgress,
              minHeight: 10,
              backgroundColor: Colors.black26,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${(provider.levelProgress * 100).toInt()}% to Level ${provider.currentLevel + 1}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          )
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _HighlightCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final LifeEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final emoji = event.eventType == 'birthday' ? '🎂' : '📅';
    final daysLeft = event.daysUntil;
    final dateStr = event.daysUntil == 0 ? 'Today!' : '$daysLeft day${daysLeft != 1 ? 's' : ''} away';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(event.name),
        subtitle: Text(dateStr),
      ),
    );
  }
}

class _ISTClock extends StatefulWidget {
  const _ISTClock();

  @override
  State<_ISTClock> createState() => _ISTClockState();
}

class _ISTClockState extends State<_ISTClock> {
  late String _time;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _updateTime());
        _startTimer();
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    _time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _updateTime());
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('IST Clock', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              _time,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 4),
            const Text('24-hour Format', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ============= FAB MENU ITEM =============
class _FabMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red.shade600),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700)),
          ],
        ),
      ),
    );
  }
}