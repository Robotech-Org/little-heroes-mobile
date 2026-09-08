import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:little_heroes_mobile/core/constants/api_constants.dart';
import 'package:little_heroes_mobile/core/utils/snackbar_utils.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/home/domain/repositories/moment_repository.dart';
import 'package:little_heroes_mobile/features/students/domain/entities/student.dart';
import 'package:little_heroes_mobile/features/students/domain/repositories/student_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class AddMomentPage extends StatefulWidget {
  const AddMomentPage({super.key});

  @override
  State<AddMomentPage> createState() => _AddMomentPageState();
}

class _AddMomentPageState extends State<AddMomentPage> {
  final TextEditingController _notesController = TextEditingController();

  // Student selection
  List<Student> _students = [];
  List<Student> _selectedStudents = [];
  bool _isLoadingStudents = true;

  // File upload
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  bool _isSaving = false;

  // Upload result
  String? _uploadedFileUrl;
  String? _uploadedFileName;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _notesController.dispose();
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
        // Auto-select first student if available
        if (_students.isNotEmpty && _selectedStudents.isEmpty) {
          _selectedStudents.add(_students.first);
        }
      });
    } catch (e) {
      setState(() => _isLoadingStudents = false);
      SnackbarUtils.showError(
        context,
        'Failed to load students: ${e.toString()}',
      );
    }
  }

  void _toggleStudentSelection(Student student) {
    setState(() {
      if (_selectedStudents.contains(student)) {
        _selectedStudents.remove(student);
      } else {
        _selectedStudents.add(student);
      }
    });
  }

  bool _isStudentSelected(Student student) {
    return _selectedStudents.contains(student);
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
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

  Future<void> _submitForReview() async {
    final notes = _notesController.text.trim();

    if (_selectedStudents.isEmpty) {
      SnackbarUtils.showError(context, 'Please select at least one student');
      return;
    }

    if (_selectedFile == null) {
      SnackbarUtils.showError(context, 'Please upload a photo');
      return;
    }

    if (notes.isEmpty) {
      SnackbarUtils.showError(context, 'Please add notes');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        SnackbarUtils.showError(context, 'Please login to submit');
        setState(() => _isSaving = false);
        return;
      }

      final repository = di.sl<MomentRepository>();

      // 1. Upload file first
      String? fileUrl;
      if (_selectedFile != null && _fileName != null) {
        setState(() => _isUploading = true);

        final uploadResult = await repository.uploadMomentFile(
          fileName: _fileName!,
          filePath: _selectedFile!.path,
        );

        fileUrl = uploadResult;
        if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
          final baseUrl = ApiConstants.baseUrl;
          final cleanBaseUrl = baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
          final cleanFileUrl = fileUrl.startsWith('/') ? fileUrl : '/$fileUrl';
          fileUrl = '$cleanBaseUrl$cleanFileUrl';
        }

        setState(() {
          _uploadedFileUrl = fileUrl;
          _uploadedFileName = _fileName;
          _isUploading = false;
        });
      }

      // 2. Get current date and time
      final now = DateTime.now();
      final momentDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final momentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00';

      // 3. Prepare data for API
      final data = {
        'moment_date': momentDate,
        'moment_time': momentTime,
        'moment_photo': fileUrl,
        'moment_notes': notes,
        'tagged_students': _selectedStudents
            .map((s) => {'student': s.id})
            .toList(),
      };

      // 4. Create moment
      await repository.createMoment(data);

      setState(() => _isSaving = false);

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Moment submitted for ${_selectedStudents.length} student(s)!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => {_isSaving = false, _isUploading = false});
      print('❌ Save error: $e');
      SnackbarUtils.showError(context, 'Failed to submit: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Moments',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: (_isSaving || _isUploading) ? null : _submitForReview,
            child: (_isSaving || _isUploading)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Submit',
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
            // Breadcrumb
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    '‹ Home',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Moments',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Upload a moment',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Image Upload
            _buildImageUploadSection(theme, colors),
            const SizedBox(height: 24),

            // Student Selection
            Text(
              'Select main character child',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select one or more child',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _buildStudentSelection(theme, colors),
            const SizedBox(height: 24),

            // Notes
            Text(
              'NOTES',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              minLines: 4,
              maxLines: 6,
              enabled: !_isSaving,
              decoration: InputDecoration(
                hintText: 'Write notes about this moment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surfaceVariant.withValues(alpha: 0.2),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_isSaving || _isUploading)
                    ? null
                    : _submitForReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit for Review',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Photo Reference',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedFile == null)
          GestureDetector(
            onTap: _isSaving ? null : _pickFile,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
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
                    '📷 Upload Photo Reference',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPEG, PNG, HEIC',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
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
                  child: Text(
                    _fileName ?? 'Uploaded',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStudentSelection(ThemeData theme, ColorScheme colors) {
    if (_isLoadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No students available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _students.map((student) {
        final isSelected = _isStudentSelected(student);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primaryContainer.withValues(alpha: 0.15)
                : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0.1),
              child: Text(
                student.initials,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? colors.onPrimary : colors.primary,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              student.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              student.ageRange,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            trailing: isSelected
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '✓ Added',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => _toggleStudentSelection(student),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(60, 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      backgroundColor: colors.surfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '+ Add',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
            onTap: _isSaving ? null : () => _toggleStudentSelection(student),
          ),
        );
      }).toList(),
    );
  }
}
