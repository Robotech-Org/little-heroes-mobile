import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/data/models/classroom_model.dart';
import 'package:little_heroes_mobile/features/home/data/models/classroom_schedule_model.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/classroom_repository.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/classroom_schedule_repository.dart';
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

  // Classroom selection
  ClassroomModel? _selectedClassroom;
  bool _isLoadingClassrooms = true;
  List<ClassroomModel> _classrooms = [];

  // Classroom Schedule selection
  List<ClassroomScheduleModel> _classSchedules = [];
  ClassroomScheduleModel? _selectedClassSchedule;
  bool _isLoadingSchedules = true;

  // File upload
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  // Upload result
  String? _uploadedFileUrl;
  String? _uploadedFileName;

  // Tagged students
  List<Student> _taggedStudents = [];
  int _currentActivityIndex = 0;

  // Image picker (same as moments page)
  final ImagePicker _imagePicker = ImagePicker();

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
    _loadClassrooms();
    _loadClassSchedules();

    if (widget.student != null) {
      _selectedStudent = widget.student;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // LOADERS
  // ═══════════════════════════════════════════════════════════
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

  Future<void> _loadClassrooms() async {
    setState(() => _isLoadingClassrooms = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isLoadingClassrooms = false);
        return;
      }

      final repository = di.sl<ClassroomRepository>();
      final response = await repository.getClassrooms(page: 1, pageSize: 20);

      setState(() {
        _classrooms = response.items;
        _isLoadingClassrooms = false;

        if (_classrooms.isNotEmpty && _selectedClassroom == null) {
          _selectedClassroom = _classrooms.first;
        }
      });
    } catch (e) {
      setState(() => _isLoadingClassrooms = false);
    }
  }

  Future<void> _loadClassSchedules() async {
    setState(() => _isLoadingSchedules = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isLoadingSchedules = false);
        return;
      }

      final repository = di.sl<ClassroomScheduleRepository>();
      final response = await repository.getClassroomSchedules(
        page: 1,
        pageSize: 50,
      );

      setState(() {
        _classSchedules = response.items;
        _isLoadingSchedules = false;

        if (_classSchedules.isNotEmpty && _selectedClassSchedule == null) {
          _selectedClassSchedule = _classSchedules.first;
          _updateActivityFromSchedule(_selectedClassSchedule!);
        }
      });
    } catch (e) {
      setState(() => _isLoadingSchedules = false);
      // print('Failed to load class schedules: $e');
    }
  }

  void _updateActivityFromSchedule(ClassroomScheduleModel schedule) {
    setState(() {
      _selectedActivity = schedule.activity;
      _startTime = schedule.startTime.substring(0, 5);
      _endTime = schedule.endTime.substring(0, 5);
    });
  }

  void _setDefaultTimes() {
    final now = DateTime.now();
    final end = now.add(const Duration(minutes: 44));
    _startTime = _formatTime(now);
    _endTime = _formatTime(end);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════════
  // FILE PICKERS
  // ═══════════════════════════════════════════════════════════

  /// Camera capture (images only).
  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final file = File(image.path);
      if (!mounted) return;

      setState(() {
        _selectedFile = file;
        _fileName = image.name;
        _uploadedFileUrl = null;
        _uploadedFileName = null;
      });

      SnackbarUtils.showSuccess(context, 'Photo captured successfully!');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'Failed to capture photo: ${e.toString()}',
      );
    }
  }

  /// Gallery picker (images only).
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final file = File(image.path);
      if (!mounted) return;

      setState(() {
        _selectedFile = file;
        _fileName = image.name;
        _uploadedFileUrl = null;
        _uploadedFileName = null;
      });

      SnackbarUtils.showSuccess(context, 'Image selected successfully!');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed to pick image: ${e.toString()}');
    }
  }

  /// File picker — **images, PDF, DOC only** (no video).
  Future<void> _pickFromFilePicker() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result == null || result.isEmpty) return;

      final filePath = result.first.path;
      if (filePath == null) {
        if (!mounted) return;
        SnackbarUtils.showError(context, 'Could not get file path');
        return;
      }

      final file = File(filePath);
      if (!mounted) return;

      setState(() {
        _selectedFile = file;
        _fileName = result.first.name;
        _uploadedFileUrl = null;
        _uploadedFileName = null;
      });

      SnackbarUtils.showSuccess(context, 'File selected successfully!');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'Failed to select file: ${e.toString()}',
      );
    }
  }

  /// Bottom sheet with 3 source options.
  void _showAttachmentSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attach to observation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how you want to add a file',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(ctx);
                        _captureFromCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickFromGallery();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.folder_rounded,
                      label: 'Files',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickFromFilePicker();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _uploadedFileUrl = null;
      _uploadedFileName = null;
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE OBSERVATION
  // ═══════════════════════════════════════════════════════════
  Future<void> _saveObservation() async {
    final note = _noteController.text.trim();

    if (_selectedStudent == null) {
      SnackbarUtils.showError(context, 'Please select a student');
      return;
    }

    if (_selectedClassSchedule == null) {
      SnackbarUtils.showError(context, 'Please select a class schedule');
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

      String? fileUrl;
      if (_selectedFile != null && _fileName != null) {
        setState(() => _isUploading = true);

        final uploadResult = await repository.uploadObservationFile(
          fileName: _fileName!,
          filePath: _selectedFile!.path,
        );

        String fileUrlResult = uploadResult;
        if (!fileUrlResult.startsWith('http://') &&
            !fileUrlResult.startsWith('https://')) {
          final baseUrl = ApiConstants.baseUrl;
          final cleanBaseUrl = baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
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
        fileUrl = _uploadedFileUrl;
      }

      final data = {
        'student': _selectedStudent!.id,
        'student_name': _selectedStudent!.name,
        'observation_date': DateTime.now().toIso8601String().split('T').first,
        'observation_class_schedule': _selectedClassSchedule!.name,
        'observation_notes': note,
        'activity': _selectedActivity,
        'start_time': _startTime,
        'end_time': _endTime,
        'tagged_students': _taggedStudents
            .map((s) => {'student': s.id, 'student_name': s.name})
            .toList(),
      };

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

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
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
            _buildClassScheduleSelector(theme, colorScheme),
            const SizedBox(height: 16),
            _buildStudentSelector(theme, colorScheme),
            const SizedBox(height: 20),
            _buildNoteField(theme, colorScheme),
            const SizedBox(height: 20),
            _buildFileUploadSection(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CLASS SCHEDULE SELECTOR
  // ═══════════════════════════════════════════════════════════
  Widget _buildClassScheduleSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Class Schedule',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoadingSchedules)
          const Center(child: CircularProgressIndicator())
        else if (_classSchedules.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'No class schedules available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _classSchedules.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                final schedule = _classSchedules[index];
                final isSelected = _selectedClassSchedule == schedule;

                return GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _selectedClassSchedule = schedule;
                            _updateActivityFromSchedule(schedule);
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          schedule.activity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: colorScheme.onPrimary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STUDENT SELECTOR
  // ═══════════════════════════════════════════════════════════
  Widget _buildStudentSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Select Student',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
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
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NOTE FIELD
  // ═══════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════
  // FILE UPLOAD
  // ═══════════════════════════════════════════════════════════
  Widget _buildFileUploadSection(ThemeData theme, ColorScheme colors) {
    final isImageFile =
        _selectedFile != null &&
        _fileName != null &&
        _isImageExtension(_fileName!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attach File',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        // ── No file yet → empty state with chips ──
        if (_selectedFile == null && _uploadedFileUrl == null)
          GestureDetector(
            onTap: _isSaving ? null : _showAttachmentSourceSheet,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 56,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '📎 Add Attachment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to capture, choose from gallery, or pick a file',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSourceChip(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        color: Colors.blue,
                        onTap: () {
                          if (!_isSaving) _captureFromCamera();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSourceChip(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        color: Colors.green,
                        onTap: () {
                          if (!_isSaving) _pickFromGallery();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildSourceChip(
                        icon: Icons.folder_rounded,
                        label: 'Files',
                        color: Colors.orange,
                        onTap: () {
                          if (!_isSaving) _pickFromFilePicker();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        // ── Uploading ──
        else if (_isUploading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withValues(alpha: 0.3),
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
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        // ── Image preview ──
        else if (isImageFile)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(_selectedFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: _removeFile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _fileName ?? 'Uploaded',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _showAttachmentSourceSheet,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ),
              ),
            ],
          )
        // ── Non-image file card (PDF / DOC) ──
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _uploadedFileUrl != null
                    ? Colors.green
                    : colors.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
              color: _uploadedFileUrl != null
                  ? Colors.green.withValues(alpha: 0.05)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_iconForFile(_fileName), color: colors.primary),
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
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isSaving ? null : _removeFile,
                  icon: Icon(Icons.close_rounded, color: colors.error),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),
        Text(
          'Supported: JPG, PNG, PDF, DOC', // 👈 video formats removed
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════
  Widget _buildSourceChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isImageExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext);
  }

  IconData _iconForFile(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file_outlined;
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'heic':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}
