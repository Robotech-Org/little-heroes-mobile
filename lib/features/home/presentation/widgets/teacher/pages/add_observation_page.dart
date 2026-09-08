import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/observation_repository.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class AddObservationPage extends StatefulWidget {
  final Student? student;
  final VoidCallback onSave;

  const AddObservationPage({super.key, this.student, required this.onSave});

  @override
  State<AddObservationPage> createState() => _AddObservationPageState();
}

class _AddObservationPageState extends State<AddObservationPage> {
  final _noteController = TextEditingController();
  String _selectedActivity = 'Circle Time & Story Telling';
  String _startTime = '';
  String _endTime = '';
  bool _isSaving = false;

  // Student selection
  List<Student> _students = [];
  Student? _selectedStudent;
  bool _isLoadingStudents = true;

  // File upload
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  // Tagged students
  List<Student> _taggedStudents = [];
  int _currentActivityIndex = 0;

  // Upload result
  String? _uploadedFileUrl;
  String? _uploadedFileName;

  final List<String> _activities = [
    'Morning Circle & Sensory Play',
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
    _loadStudents();

    // If student is passed from widget, pre-select it
    if (widget.student != null) {
      _selectedStudent = widget.student;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isLoadingStudents = false);
        return;
      }

      final repository = di.sl<StudentRepository>();
      final response = await repository.getStudents(page: 1, pageSize: 100);

      setState(() {
        _students = response.items;
        _isLoadingStudents = false;
      });
    } catch (e) {
      setState(() => _isLoadingStudents = false);
      SnackbarUtils.showError(
        context,
        'Failed to load students: ${e.toString()}',
      );
    }
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
      _uploadedFileUrl = null;
      _uploadedFileName = null;
    });
  }

  void _toggleTaggedStudent(Student student) {
    setState(() {
      if (_taggedStudents.contains(student)) {
        _taggedStudents.remove(student);
      } else {
        _taggedStudents.add(student);
      }
    });
  }

  Future<void> _saveObservation() async {
    final note = _noteController.text.trim();

    if (_selectedStudent == null) {
      SnackbarUtils.showError(context, 'Please select a student');
      return;
    }

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

      // 1. Upload file if selected and not yet uploaded
      String? fileUrl;
      if (_selectedFile != null && _fileName != null) {
        setState(() => _isUploading = true);

        // Upload the file
        final uploadResult = await repository.uploadObservationFile(
          fileName: _fileName!,
          filePath: _selectedFile!.path,
        );

        // The uploadResult might be a relative path like "/file/xxx.png"
        // If it doesn't start with http, prepend the base URL
        String fileUrlResult = uploadResult;
        if (!fileUrlResult.startsWith('http://') &&
            !fileUrlResult.startsWith('https://')) {
          // Get base URL from ApiConstants
          final baseUrl = ApiConstants.baseUrl;
          // Ensure baseUrl doesn't end with '/'
          final cleanBaseUrl = baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
          // Ensure fileUrl doesn't start with '/' if baseUrl doesn't end with '/'
          final cleanFileUrl = fileUrlResult.startsWith('/')
              ? fileUrlResult
              : '/$fileUrlResult';
          fileUrl = '$cleanBaseUrl$cleanFileUrl';
        } else {
          fileUrl = fileUrlResult;
        }

        setState(() {
          _uploadedFileUrl = fileUrl;
          _uploadedFileName = _fileName;
          _isUploading = false;
        });
      } else if (_uploadedFileUrl != null) {
        // Use previously uploaded file
        fileUrl = _uploadedFileUrl;
      }

      // ============================================================
      // DEBUG PRINTS - STUDENT AND TAGGED STUDENTS
      // ============================================================

      // 2. Create observation with all data
      final data = {
        'student': "fej2rtpth8",
        'student_name': _selectedStudent!.name,
        'observation_date': DateTime.now().toIso8601String().split('T').first,
        'observation_class_schedule': 'i0sv3kpume',
        'observation_notes': note,
        'activity': _selectedActivity,
        'start_time': _startTime,
        'end_time': _endTime,
        'tagged_students': _taggedStudents
            .map((s) => {'student': s.name})
            .toList(),
      };

      // Add observation_photo only if file was uploaded successfully
      if (fileUrl != null && fileUrl.isNotEmpty) {
        data['observation_photo'] = fileUrl;
      }

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
      print('❌ Save error: $e');
      SnackbarUtils.showError(context, 'Failed to save: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'New Observation',
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
            // Student Selector
            _buildStudentSelector(theme, colorScheme),
            const SizedBox(height: 20),

            // Activity Card with Left/Right Navigation
            _buildActivityCard(theme, colorScheme),
            const SizedBox(height: 20),

            // Observation Note
            _buildNoteField(theme, colorScheme),
            const SizedBox(height: 20),

            // Tagged Students
            _buildTaggedStudents(theme, colorScheme),
            const SizedBox(height: 20),

            // File Upload
            _buildFileUploadSection(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Student',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingStudents)
          const Center(child: CircularProgressIndicator())
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Student>(
                value: _selectedStudent,
                hint: const Text('Select a student...'),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: theme.textTheme.bodyMedium,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() => _selectedStudent = value);
                      },
                items: _students.map((student) {
                  return DropdownMenuItem<Student>(
                    value: student,
                    child: Text(student.name),
                  );
                }).toList(),
              ),
            ),
          ),
        if (_selectedStudent != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedStudent!.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActivityCard(ThemeData theme, ColorScheme colorScheme) {
    final hasPrevious = _currentActivityIndex > 0;
    final hasNext = _currentActivityIndex < _activities.length - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          InkWell(
            onTap: !_isSaving && hasPrevious
                ? () {
                    setState(() {
                      _currentActivityIndex--;
                      _selectedActivity = _activities[_currentActivityIndex];
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: hasPrevious
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimary.withValues(alpha: 0.35),
              ),
            ),
          ),

          // Activity Information
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Column(
                key: ValueKey(_selectedActivity),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_startTime - $_endTime',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _selectedActivity,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next Button
          InkWell(
            onTap: !_isSaving && hasNext
                ? () {
                    setState(() {
                      _currentActivityIndex++;
                      _selectedActivity = _activities[_currentActivityIndex];
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: hasNext
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimary.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observation Note',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          enabled: !_isSaving,
          decoration: InputDecoration(
            hintText: 'Write what you observed about the student...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildTaggedStudents(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tagged Students',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_taggedStudents.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_students.isEmpty)
          const Text(
            'No students available to tag',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _students.map((student) {
              final isTagged = _taggedStudents.contains(student);
              return FilterChip(
                label: Text(student.name),
                selected: isTagged,
                onSelected: _isSaving
                    ? null
                    : (_) => _toggleTaggedStudent(student),
                backgroundColor: colorScheme.surfaceVariant.withValues(
                  alpha: 0.3,
                ),
                selectedColor: colorScheme.primaryContainer,
                side: BorderSide(
                  color: isTagged
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.2),
                ),
                checkmarkColor: colorScheme.primary,
              );
            }).toList(),
          ),
        if (_taggedStudents.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Tagged: ${_taggedStudents.map((s) => s.name).join(', ')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileUploadSection(ThemeData theme, ColorScheme colorScheme) {
    final isFileUploaded =
        _uploadedFileUrl != null && _uploadedFileUrl!.isNotEmpty;
    final isUploading = _isUploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attach File',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedFile == null && !isFileUploaded)
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
        else if (isUploading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploading file...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isFileUploaded
                    ? Colors.green
                    : colorScheme.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
              color: isFileUploaded
                  ? Colors.green.withValues(alpha: 0.05)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFileUploaded
                        ? Colors.green.withValues(alpha: 0.1)
                        : colorScheme.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isFileUploaded
                        ? Icons.check_circle_rounded
                        : Icons.insert_drive_file_outlined,
                    color: isFileUploaded ? Colors.green : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFileUploaded
                            ? _uploadedFileName ?? 'Uploaded'
                            : _fileName ?? 'Unknown file',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isFileUploaded ? Colors.green : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFileUploaded
                            ? 'Uploaded successfully ✓'
                            : '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                        style: TextStyle(
                          fontSize: 12,
                          color: isFileUploaded
                              ? Colors.green
                              : colorScheme.onSurfaceVariant,
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
          isFileUploaded
              ? 'File uploaded successfully!'
              : 'Supported formats: JPG, PNG, PDF, DOC, MP4, MOV',
          style: TextStyle(
            fontSize: 12,
            color: isFileUploaded ? Colors.green : colorScheme.onSurfaceVariant,
            fontWeight: isFileUploaded ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
