import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Clipboard
import '../logic/syllabus_provider.dart';
import '../data/syllabus_model.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyllabusProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => _showAiImport(context, provider),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        itemBuilder: (ctx, i) {
          final item = provider.items[i];
          return _SyllabusCard(item: item, provider: provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context, provider),
      ),
    );
  }

  void _showAddDialog(BuildContext context, SyllabusProvider provider) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Subject"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Subject Name")),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "Subject Code")),
          ],
        ),
        actions: [
          FilledButton(onPressed: () {
            provider.addItem(name: nameCtrl.text, code: codeCtrl.text);
            Navigator.pop(ctx);
          }, child: const Text("Add"))
        ],
      ),
    );
  }

  void _showAiImport(BuildContext context, SyllabusProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("AI Import"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: "Convert syllabus image to JSON array: subject, code, examDate (YYYY-MM-DD)."));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prompt Copied!")));
              },
              child: const Text("Copy Prompt"),
            ),
            const SizedBox(height: 10),
            TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Paste JSON here", border: OutlineInputBorder()), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () {
            provider.importJson(ctrl.text);
            Navigator.pop(context);
          }, child: const Text("Import"))
        ],
      ),
    );
  }
}

class _SyllabusCard extends StatelessWidget {
  final SyllabusItem item;
  final SyllabusProvider provider;
  const _SyllabusCard({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasExamPassed = item.examDate != null && item.examDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(item.code, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 5),
            if (item.examDate != null)
              Text("Exam: ${DateFormat('MMM d').format(item.examDate!)}", 
                  style: TextStyle(color: hasExamPassed ? Colors.red : Colors.blue)),
            
            const SizedBox(height: 15),
            
            // PROGRESS BAR
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: item.progress, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 10),
                Text("${(item.progress * 100).toInt()}%"),
              ],
            ),

            // CONTROLS
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Slider to set progress
                if (!hasExamPassed)
                  TextButton(
                    onPressed: () => _showProgressDialog(context, item, provider),
                    child: const Text("Update Progress"),
                  ),
                
                // If Exam Passed -> Ask for Marks
                if (hasExamPassed)
                  item.marksObtained == null 
                  ? OutlinedButton(
                      onPressed: () => _showMarksDialog(context, item, provider),
                      child: const Text("Enter Marks"),
                    )
                  : Text("Result: ${item.marksObtained}/${item.totalMarks}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  
                IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => provider.deleteItem(item)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context, SyllabusItem item, SyllabusProvider provider) {
    double val = item.progress;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Update Progress"),
          content: Slider(value: val, onChanged: (v) => setState(() => val = v)),
          actions: [
            TextButton(onPressed: () { provider.updateProgress(item, val); Navigator.pop(ctx); }, child: const Text("Save"))
          ],
        ),
      ),
    );
  }

  void _showMarksDialog(BuildContext context, SyllabusItem item, SyllabusProvider provider) {
    final mCtrl = TextEditingController();
    final tCtrl = TextEditingController(text: "100");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Results"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: mCtrl, decoration: const InputDecoration(labelText: "Marks Scored")),
          TextField(controller: tCtrl, decoration: const InputDecoration(labelText: "Total Marks")),
        ]),
        actions: [
          TextButton(onPressed: () {
            provider.updateMarks(item, double.parse(mCtrl.text), double.parse(tCtrl.text));
            Navigator.pop(ctx);
          }, child: const Text("Save"))
        ],
      ),
    );
  }
}