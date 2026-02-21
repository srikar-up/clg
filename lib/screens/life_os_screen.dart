import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/life_provider.dart';

class LifeOsScreen extends StatelessWidget {
  const LifeOsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LifeProvider>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Life OS')),
      body: Column(
        children: [
          // 1. GAMIFICATION HEADER
          _ScoreCard(provider: provider),

          // 2. GOALS LIST
          Expanded(
            child: provider.goals.isEmpty 
            ? const Center(child: Text("Set a goal to start earning XP!"))
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.goals.length,
              itemBuilder: (context, index) {
                final goal = provider.goals[index];
                return Card(
                  elevation: goal.isCompleted ? 0 : 2,
                  color: goal.isCompleted ? Colors.grey.shade200 : Colors.white,
                  child: ListTile(
                    leading: Checkbox(
                      value: goal.isCompleted,
                      onChanged: (val) => provider.toggleGoal(goal, val),
                      activeColor: Colors.green,
                    ),
                    title: Text(
                      goal.title,
                      style: TextStyle(
                        decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                        color: goal.isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text("+${goal.rewardPoints} XP"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => provider.deleteGoal(goal),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_task),
        label: const Text("New Goal"),
        onPressed: () => _showAddGoalDialog(context, provider),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, LifeProvider provider) {
    final titleCtrl = TextEditingController();
    final pointsCtrl = TextEditingController(text: "10");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set New Target"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Goal (e.g. Read 30 mins)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pointsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Reward Points (XP)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                provider.addGoal(titleCtrl.text, int.tryParse(pointsCtrl.text) ?? 10);
                Navigator.pop(ctx);
              }
            }, 
            child: const Text("Set Goal")
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final LifeProvider provider;
  const _ScoreCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.purple.shade400]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CURRENT LEVEL", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                  Text("${provider.currentLevel}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("TOTAL XP", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                  Text("${provider.totalPoints}", style: const TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.bold)),
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
            child: Text("${(provider.levelProgress * 100).toInt()}% to Level ${provider.currentLevel + 1}", style: const TextStyle(color: Colors.white70, fontSize: 10)),
          )
        ],
      ),
    );
  }
}