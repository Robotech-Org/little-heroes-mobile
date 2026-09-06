import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';

import '../pages/three_month_reports_page.dart';

// OBSERVATION MODEL

class Observation {
  final String id;
  final String studentName;
  final String activity;
  final String note;
  final DateTime startTime;
  final DateTime endTime;
  final String? fileName;

  const Observation({
    required this.id,
    required this.studentName,
    required this.activity,
    required this.note,
    required this.startTime,
    required this.endTime,
    this.fileName,
  });
}

// OBSERVATIONS PAGE

class ObservationsPage extends StatefulWidget {
  const ObservationsPage({super.key});

  @override
  State<ObservationsPage> createState() => _ObservationsPageState();
}

class _ObservationsPageState extends State<ObservationsPage> {
  final List<Student> _students = const [];

  final List<Observation> _observations = [
    Observation(
      id: '1',
      studentName: 'Abebe Bekele',
      activity: 'Circle Time & Story Telling',
      note: 'Participated actively during the group activity.',
      startTime: DateTime(2026, 9, 1, 9, 50),
      endTime: DateTime(2026, 9, 1, 10, 34),
    ),
    Observation(
      id: '2',
      studentName: 'Sara Ahmed',
      activity: 'Free Play',
      note: 'Showed good communication skills with classmates.',
      startTime: DateTime(2026, 8, 31, 10, 15),
      endTime: DateTime(2026, 8, 31, 10, 45),
    ),
  ];

  void _openObservationForm(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddObservationPage(
          student: student,
          onSave: (observation) {
            setState(() {
              _observations.insert(0, observation);
            });
          },
        ),
      ),
    );
  }

  int _observationCount(Student student) {
    return _observations
        .where((item) => item.studentName == student.name)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Observations',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Student Observations',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            'Select a student to add an observation.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          ..._students.map(
            (student) => _StudentCard(
              student: student,
              count: _observationCount(student),
              onTap: () => _openObservationForm(student),
            ),
          ),
        ],
      ),
    );
  }
}

// STUDENT CARD

class _StudentCard extends StatelessWidget {
  final Student student;
  final int count;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final name = student.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   '${student.age} years • ${student.age}',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: colors.onSurfaceVariant,
                    //   ),
                    // ),
                    const SizedBox(height: 7),
                    Text(
                      '$count ${count == 1 ? 'observation' : 'observations'}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ADD OBSERVATION PAGE

class AddObservationPage extends StatefulWidget {
  final Student student;
  final ValueChanged<Observation> onSave;

  const AddObservationPage({
    super.key,
    required this.student,
    required this.onSave,
  });

  @override
  State<AddObservationPage> createState() => _AddObservationPageState();
}

class _AddObservationPageState extends State<AddObservationPage> {
  final _noteController = TextEditingController();

  String _activity = 'Circle Time & Story Telling';

  PlatformFile? _file;

  late DateTime _startTime;
  late DateTime _endTime;

  static const activities = [
    'Circle Time & Story Telling',
    'Free Play',
    'Reading',
    'Mathematics',
    'Outdoor Activity',
    'Creative Art',
    'Music & Movement',
    'Social Activity',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();
    _endTime = _startTime.add(const Duration(minutes: 44));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _time(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;

    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Future<void> _pickFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'mp4',
          'mov',
        ],
      );

      if (files.isEmpty) return;

      setState(() {
        _file = files.first;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select the file.')),
      );
    }
  }

  void _save() {
    final note = _noteController.text.trim();

    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an observation note.')),
      );
      return;
    }

    final observation = Observation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentName: widget.student.name,
      activity: _activity,
      note: note,
      startTime: _startTime,
      endTime: _endTime,
      fileName: _file?.name,
    );

    widget.onSave(observation);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final name = widget.student.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Observation',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // STUDENT

          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.student.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Text(
                    //   '${widget.student.age} years • '
                    //   '${widget.student.grade}',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: colors.onSurfaceVariant,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // TIME / ACTIVITY CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // TIME CIRCLE
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _time(_startTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Observation',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _activity,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '${_time(_startTime)} – ${_time(_endTime)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ACTIVITY
          const Text(
            'Activity',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: _activity,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.local_activity_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            items: activities
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _activity = value;
              });
            },
          ),

          const SizedBox(height: 22),

          // NOTE
          const Text(
            'Observation Note',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _noteController,
            minLines: 5,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Write what you observed about the student...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // FILE
          const Text(
            'Observation File',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 8),

          if (_file == null)
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('Upload File'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file_outlined, color: colors.primary),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      _file!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        _file = null;
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 28),

          // SAVE
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text(
              'Save Observation',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
