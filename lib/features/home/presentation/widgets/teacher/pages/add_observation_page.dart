import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/observation_repository.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

import 'dart:io';

import 'dart:io';

import 'package:file_picker/file_picker.dart';

class AddObservationPage extends StatefulWidget {
  final Student student;
  final VoidCallback onSave;

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
  String _selectedActivity = 'Circle Time & Story Telling';
  String _startTime = '';
  String _endTime = '';
  bool _isSaving = false;

  // File upload
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  final List<String> _activities = [
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
    _setDefaultTimes();
  }

  void _setDefaultTimes() {
    final now = DateTime.now();
    final end = now.add(const Duration(minutes: 44));
    _startTime = _formatTime(now);
    _endTime = _formatTime(end);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickFile() async {
    try {
      // Call pickFiles directly as a static method
      final result = await FilePicker.pickFiles(
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
        allowMultiple: false,
      );

      // In v12+, result is a List<PlatformFile>? directly
      if (result == null || result.isEmpty) return;

      final filePath = result.first.path;
      if (filePath == null) {
        if (!mounted) return;
        SnackbarUtils.showError(context, 'Could not get file path');
        return;
      }

      final file = File(filePath);
      setState(() {
        _selectedFile = file;
        _fileName = result.first.name;
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'Failed to select file: ${e.toString()}',
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  Future<void> _saveObservation() async {
    final note = _noteController.text.trim();

    if (note.isEmpty) {
      SnackbarUtils.showError(context, 'Please enter an observation note');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to save observation');
        setState(() => _isSaving = false);
        return;
      }

      final repository = di.sl<ObservationRepository>();

      // 1. Upload file if selected
      String? fileUrl;
      if (_selectedFile != null && _fileName != null) {
        setState(() => _isUploading = true);
        fileUrl = await repository.uploadObservationFile(
          fileName: _fileName!,
          filePath: _selectedFile!.path,
        );
        setState(() => _isUploading = false);
      }

      // 2. Create observation with file info
      final data = {
        'student': widget.student.name,
        'student_name': widget.student.name,
        'activity': _selectedActivity,
        'note': note,
        'start_time': _startTime,
        'end_time': _endTime,
        if (fileUrl != null) 'file_url': fileUrl,
        if (_fileName != null) 'file_name': _fileName,
      };

      await repository.createObservation(data);

      setState(() => _isSaving = false);
      widget.onSave();
      Navigator.pop(context);
      SnackbarUtils.showSuccess(context, 'Observation saved successfully!');
    } catch (e) {
      setState(() {
        _isSaving = false;
        _isUploading = false;
      });
      SnackbarUtils.showError(
        context,
        'Failed to save observation: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final name = widget.student.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Add Observation',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: (_isSaving || _isUploading) ? null : _saveObservation,
            child: (_isSaving || _isUploading)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withValues(alpha: 0.5),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.student.ageRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Time Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _startTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
                          _selectedActivity,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_startTime – $_endTime',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Activity Selection - Horizontal Scrollable Chips
            const Text(
              'Activity',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  final isSelected = activity == _selectedActivity;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        activity,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedActivity = activity;
                        });
                      },
                      backgroundColor: colorScheme.surfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      selectedColor: colorScheme.primaryContainer,
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Note
            const Text(
              'Observation Note',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),

            // File Upload Section
            const Text(
              'Attach File',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (_selectedFile == null)
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _pickFile,
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text('Upload File'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.insert_drive_file_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName ?? 'Unknown file',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isSaving ? null : _removeFile,
                      icon: Icon(Icons.close_rounded, color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Supported formats: JPG, PNG, PDF, DOC, MP4, MOV',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
