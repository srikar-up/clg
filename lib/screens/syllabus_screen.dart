import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../logic/syllabus_provider.dart';
import '../data/syllabus_model.dart';

const _bgPrimary = Color(0xFFFEF2F2);
const _textPrimary = Color(0xFF111827);
const _gradStart = Color(0xFFEF4444);
const _gradEnd = Color(0xFF991B1B);
const _red600 = Color(0xFFDC2626);

const String _promptTemplate = '''Act as a Pro Syllabus Converter.
Input: Syllabus PDF/Text.
Output: Valid JSON ONLY.
Structure:
[
  {
    "code": "MTH302",
    "name": "Maths",
    "credits": 4,
    "units": [
      {
         "id": 1, 
         "title": "UnitName", 
         "topics": ["TopicA", "TopicB"]
      }
    ]
  }
]''';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyllabusProvider>();
    final sgpa = provider.predictSGPA();

    int totalTopics = 0;
    int completedTopics = 0;
    for (var sub in provider.subjects) {
      totalTopics += sub.units.fold(0, (sum, u) => sum + u.topics.length);
      completedTopics += sub.units.fold(0, (sum, u) => sum + u.topics.where((t) => t.isCompleted).length);
    }
    int masterPct = totalTopics == 0 ? 0 : ((completedTopics / totalTopics) * 100).round();

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
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
                      Text('SYLLABUS TRACKER', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1.5)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showSemesterModal(context, provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.layers, size: 12, color: _red600),
                          const SizedBox(width: 6),
                          Text(provider.activeSemesterName.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // BODY
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  // Mastery Card
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CURRENT PROGRESS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.5)),
                                  const SizedBox(height: 4),
                                  Text('$masterPct%', style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                                  const SizedBox(height: 8),
                                  Text('Est. SGPA: ${sgpa.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (masterPct / 100.0).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showImportModal(context, provider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(32), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.file_upload, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text('IMPORT', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showPromptModal(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.red.shade100)),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.smart_toy, color: _red600, size: 16),
                                const SizedBox(width: 8),
                                Text('PROMPT', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subjects List
                  ...provider.subjects.map((sub) => _DashboardSubjectCard(subject: sub)),
                  
                  const SizedBox(height: 80),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _red600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        onPressed: () => _showImportModal(context, provider),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSemesterModal(BuildContext context, SyllabusProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Academic Year', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...provider.semesters.map<Widget>((semMap) {
                        final sem = semMap['id'] as int;
                        final semName = semMap['name'] as String;
                        final isAct = sem == provider.activeSemester;
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                provider.setActiveSemester(sem);
                                Navigator.pop(ctx);
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isAct ? _red600 : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(semName.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: isAct ? Colors.white : Colors.grey.shade400, letterSpacing: 1)),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 8,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _showAddSemesterDialog(context, provider, renameId: sem, currentName: semName);
                                },
                                child: Container(
                                  width: 48,
                                  color: Colors.transparent,
                                  child: Icon(Icons.edit, size: 16, color: isAct ? Colors.white70 : Colors.grey.shade400),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                           Navigator.pop(ctx);
                           _showAddSemesterDialog(context, provider);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100)
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 16, color: _red600),
                              const SizedBox(width: 8),
                              Text('ADD SEMESTER', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showAddSemesterDialog(BuildContext context, SyllabusProvider provider, {int? renameId, String? currentName}) {
    final ctrl = TextEditingController(text: currentName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(renameId != null ? 'Rename Semester' : 'New Semester', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: _textPrimary)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: ctrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "Semester Name..."),
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (ctrl.text.trim().isEmpty) return;
                  if (renameId != null) {
                    provider.renameSemester(renameId, ctrl.text.trim());
                  } else {
                    provider.addSemester(ctrl.text.trim());
                  }
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: Text('SAVE', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showImportModal(BuildContext context, SyllabusProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Import', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: _textPrimary)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: ctrl,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: "Paste AI JSON..."),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  final res = provider.importJson(ctrl.text);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: Text('IMPORT SUBJECT', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showPromptModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Prompt Builder', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: _textPrimary)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(24)),
                child: Text(_promptTemplate, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF991B1B))),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: _promptTemplate));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt Copied!')));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(32)),
                  alignment: Alignment.center,
                  child: Text('COPY PROMPT', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}

class _DashboardSubjectCard extends StatelessWidget {
  final SyllabusSubject subject;
  const _DashboardSubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final pct = subject.masterProgress;
    
    // Quick estimation logic locally just for display purposes
    double estScore = 0;
    if (subject.weightageGroups.isNotEmpty) {
      double totalW = 0;
      for (var wg in subject.weightageGroups) {
        final exams = subject.exams.where((e) => e.weightageGroupId == wg.id).toList();
        if (exams.isNotEmpty) {
           double sum = 0; int cnt = 0;
           for (var e in exams) { if (e.marksObtained != null) { sum += (e.marksObtained!/e.maxMarks); cnt++; } }
           if (cnt > 0) { estScore += (sum/cnt)*wg.percentage; }
        }
        totalW += wg.percentage;
      }
      if (totalW > 0) estScore = (estScore/totalW)*100;
    } else {
      estScore = pct * 100;
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.12), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(subject.code, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _red600, letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 8),
                      Text(subject.name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey.shade800)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('EST. GRADE', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade300)),
                    Text('${estScore.toStringAsFixed(0)}/100', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: _red600)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// SUBJECT DETAIL SCREEN (including Grading and Results modals)
// ---------------------------------------------------------

class SubjectDetailScreen extends StatefulWidget {
  final SyllabusSubject subject;
  const SubjectDetailScreen({super.key, required this.subject});
  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  String _activeExamId = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyllabusProvider>();
    
    // Find active scope
    List<String>? scope;
    SyllabusExam? activeExam;
    if (_activeExamId != 'all') {
      activeExam = widget.subject.exams.firstWhere((e) => e.id == _activeExamId);
      scope = [];
      for (var list in activeExam.scope.values) {
        for (var topic in list) { scope.add(topic.toString()); }
      }
    }

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: const Icon(Icons.arrow_back, color: _red600),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(widget.subject.code, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey.shade900, height: 1)),
                           Text('SYLLABUS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                             provider.deleteSubject(widget.subject);
                             Navigator.pop(context);
                          },
                          child: const Icon(Icons.delete_outline, color: _red600, size: 28),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _openGradingModal(context, provider),
                          child: const Icon(Icons.pie_chart, color: _red600, size: 28),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            
            // EXAM TABS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _ExamTab(title: 'MASTER', isActive: _activeExamId == 'all', onTap: () => setState(() => _activeExamId = 'all')),
                  ...widget.subject.exams.map((ex) => _ExamTab(title: ex.name, isActive: _activeExamId == ex.id, onTap: () => setState(() => _activeExamId = ex.id))),
                  GestureDetector(
                    onTap: () => _openExamCreator(context, provider),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.add, color: _red600, size: 16),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ACTIVE GOAL CARD (if specific exam)
            if (activeExam != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.red.shade50),
                    boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.12), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('TARGET', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  provider.deleteExam(widget.subject, activeExam!);
                                  setState(() => _activeExamId = 'all');
                                },
                                child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              ),
                            ]
                          ),
                          // Compute PCT manually
                          Builder(builder: (ctx) {
                            int t = 0; int d = 0;
                            for(var u in widget.subject.units){
                               for(var top in u.topics){
                                  if(scope!.contains(top.name)){
                                     t++;
                                     if(top.isCompleted) d++;
                                  }
                               }
                            }
                            int pct = t == 0 ? 0 : ((d/t)*100).round();
                            return Text('$pct%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: _red600));
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ... progress bar
                      Builder(builder: (ctx) {
                            int t = 0; int d = 0;
                            for(var u in widget.subject.units){
                               for(var top in u.topics){
                                  if(scope!.contains(top.name)){
                                     t++;
                                     if(top.isCompleted) d++;
                                  }
                               }
                            }
                            double pct = t == 0 ? 0 : (d/t);
                            return Container(
                              height: 12,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: pct.clamp(0.0, 1.0),
                                child: Container(decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(12))),
                              ),
                            );
                      }),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EXAM DATE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade300, letterSpacing: 1.5)),
                              Text(DateFormat('MMM dd, yyyy').format(activeExam.date), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade600)),
                            ],
                          ),
                          if (activeExam.marksObtained == null)
                            GestureDetector(
                              onTap: () => _openResultModal(context, provider, activeExam!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(color: Colors.green.shade500, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.green.shade100, blurRadius: 10, offset: const Offset(0, 4))]),
                                child: Text('ADD MARKS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                              ),
                            )
                          else
                            Text('${activeExam.marksObtained}/${activeExam.maxMarks}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.green)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

            // SYLLABUS LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  ...widget.subject.units.map((unit) {
                    bool hasTopics = false;
                    for(var t in unit.topics) {
                      if (scope == null || scope.contains(t.name)) { hasTopics = true; break;}
                    }
                    if (!hasTopics) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.12), blurRadius: 30, spreadRadius: -10, offset: Offset(0, 15))],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            color: Colors.red.shade50.withValues(alpha: 0.3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('UNIT ${unit.id}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red.shade300, letterSpacing: 1.5)),
                                Text(unit.title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.red.shade800)),
                              ],
                            ),
                          ),
                          ...unit.topics.map((t) {
                            if (scope != null && !scope.contains(t.name)) return const SizedBox.shrink();
                            return GestureDetector(
                              onTap: () => provider.toggleTopic(widget.subject, t),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.red.shade50))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(t.name, style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14, 
                                        fontWeight: t.isCompleted ? FontWeight.normal : FontWeight.bold,
                                        color: t.isCompleted ? Colors.grey.shade300 : Colors.grey.shade700,
                                        decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                        fontStyle: t.isCompleted ? FontStyle.italic : null
                                      )),
                                    ),
                                    Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: t.isCompleted ? _red600 : Colors.grey.shade100, width: 2),
                                        color: t.isCompleted ? _red600 : Colors.transparent
                                      ),
                                      child: t.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                                    )
                                  ],
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                    );
                  })
                ]
              ),
            )
            
          ],
        ),
      ),
    );
  }

  void _openGradingModal(BuildContext context, SyllabusProvider provider) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => _GradingModal(subject: widget.subject));
  }

  void _openExamCreator(BuildContext context, SyllabusProvider provider) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => _ExamCreatorModal(subject: widget.subject));
  }
  
  void _openResultModal(BuildContext context, SyllabusProvider provider, SyllabusExam exam) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(40),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 64, height: 4, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 32),
            Text('Exam Result', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 60, fontWeight: FontWeight.w900),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 24),
                Text('/', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey.shade200)),
                const SizedBox(width: 24),
                Text('${exam.maxMarks.toInt()}', style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                double marks = double.tryParse(ctrl.text) ?? 0;
                if (marks > exam.maxMarks) marks = exam.maxMarks;
                provider.updateExamMarks(widget.subject, exam, marks);
                Navigator.pop(ctx);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(color: Colors.green.shade500, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.green.shade100, blurRadius: 20, offset: const Offset(0, 10))]),
                alignment: Alignment.center,
                child: Text('LOG MARKS', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            )
          ],
        ),
      )
    );
  }
}

class _ExamTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  const _ExamTab({required this.title, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _red600 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isActive ? [BoxShadow(color: Colors.red.shade100, blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Text(title.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: isActive ? Colors.white : Colors.grey.shade400, letterSpacing: 1.5)),
      ),
    );
  }
}

// ---------------------------------------------------------
// EXAM CREATOR MODAL
// ---------------------------------------------------------
class _ExamCreatorModal extends StatefulWidget {
  final SyllabusSubject subject;
  const _ExamCreatorModal({required this.subject});
  @override
  State<_ExamCreatorModal> createState() => _ExamCreatorModalState();
}

class _ExamCreatorModalState extends State<_ExamCreatorModal> {
  final _nameCtrl = TextEditingController();
  final _marksCtrl = TextEditingController(text: '30');
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  
  final Map<String, List<String>> _scope = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SyllabusProvider>();
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 32, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Setup Exam', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey.shade900)),
              GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(32)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NAME', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g., CA-1'),
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                             final r = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(3000));
                             if(r!=null) setState(()=>_date = r);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(32)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DATE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
                                const SizedBox(height: 8),
                                Text(DateFormat('yyyy-MM-dd').format(_date), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(32)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL MARKS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5)),
                              TextField(
                                controller: _marksCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(top: 8)),
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // SCOPE SELECTION (ACCORDION)
                  ...widget.subject.units.map((u) {
                     return Container(
                       margin: const EdgeInsets.only(bottom: 16),
                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.red.shade50, width: 2)),
                       clipBehavior: Clip.antiAlias,
                       child: ExpansionTile(
                         shape: const Border(),
                         title: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('UNIT ${u.id}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400)),
                                 Text(u.title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey.shade800)),
                               ],
                             ),
                             Checkbox(
                               value: u.topics.every((t) => _scope[u.title]?.contains(t.name) == true) && u.topics.isNotEmpty,
                               onChanged: (v) {
                                 setState(() {
                                   if (v == true) {
                                     _scope[u.title] = u.topics.map((e) => e.name).toList();
                                   } else {
                                     _scope.remove(u.title);
                                   }
                                 });
                               },
                             ),
                           ],
                         ),
                         children: u.topics.map((t) {
                           bool sel = _scope[u.title]?.contains(t.name) ?? false;
                           return CheckboxListTile(
                             title: Text(t.name, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                             value: sel,
                             onChanged: (v) {
                               setState(() {
                                 _scope.putIfAbsent(u.title, () => []);
                                 if (v == true) { _scope[u.title]!.add(t.name); } else { _scope[u.title]!.remove(t.name); }
                               });
                             },
                           );
                         }).toList(),
                       ),
                     );
                  }),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          GestureDetector(
            onTap: () {
               provider.addExam(widget.subject, _nameCtrl.text, _date, double.tryParse(_marksCtrl.text) ?? 100, _scope);
               Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(40), boxShadow: const [BoxShadow(color: Color.fromRGBO(220, 38, 38, 0.3), blurRadius: 30, offset: Offset(0, 10))]),
              alignment: Alignment.center,
              child: Text('CREATE EXAM', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// GRADING MODAL
// ---------------------------------------------------------
class _GradingModal extends StatefulWidget {
  final SyllabusSubject subject;
  const _GradingModal({required this.subject});
  @override
  State<_GradingModal> createState() => _GradingModalState();
}

class _GradingModalState extends State<_GradingModal> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyllabusProvider>();
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 32, left: 24, right: 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grading Plan', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900)),
              GestureDetector(onTap: ()=>Navigator.pop(context), child: const Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SUBJECT CREDITS', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: _red600)),
                Container(
                  width: 64,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(text: widget.subject.credits.toString())..selection = TextSelection.collapsed(offset: widget.subject.credits.toString().length),
                    onChanged: (v) { widget.subject.credits = int.tryParse(v) ?? 0; widget.subject.save(); },
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: _red600),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.all(8)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                ...widget.subject.weightageGroups.map((wg) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(32)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(text: wg.name)..selection = TextSelection.collapsed(offset: wg.name.length),
                                  onChanged: (v) { wg.name = v; widget.subject.save(); },
                                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey.shade800),
                                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                                ),
                              ),
                              Row(
                                children: [
                                  Text('Weight:', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 48,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade100)),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: TextEditingController(text: wg.percentage.toString())..selection = TextSelection.collapsed(offset: wg.percentage.toString().length),
                                      onChanged: (v) { wg.percentage = double.tryParse(v) ?? 0; widget.subject.save(); setState((){}); },
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: _red600),
                                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.all(4)),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: widget.subject.exams.map((ex) {
                               bool sel = ex.weightageGroupId == wg.id;
                               return GestureDetector(
                                 onTap: () => setState((){ provider.assignExamToGroup(widget.subject, ex, sel ? null : wg.id); }),
                                 child: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? _red600 : Colors.grey.shade200)),
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       if (sel) const Icon(Icons.check, size: 12, color: _red600),
                                       if (sel) const SizedBox(width: 4),
                                       Text(ex.name, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600))
                                     ],
                                   ),
                                 ),
                               );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(() => provider.deleteWeightageGroup(widget.subject, wg)),
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 12, color: Colors.red),
                                const SizedBox(width: 4),
                                Text('REMOVE GROUP', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.red.shade400, letterSpacing: 1.5)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                }),
                
                GestureDetector(
                  onTap: () => setState(() => provider.addWeightageGroup(widget.subject, 'New Group', 20)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.red.shade200, style: BorderStyle.solid), borderRadius: BorderRadius.circular(24)),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text('ADD WEIGHTAGE GROUP', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade400)),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
            child: GestureDetector(
               onTap: () => Navigator.pop(context),
               child: Container(
                 width: double.infinity,
                 padding: const EdgeInsets.symmetric(vertical: 20),
                 decoration: BoxDecoration(color: _red600, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                 alignment: Alignment.center,
                 child: Text('UPDATE GRADE PLAN', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
               ),
            ),
          )
        ],
      ),
    );
  }
}