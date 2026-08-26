import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;

  final Widget? content;

  final String cancelText;
  final String confirmText;

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  final IconData? icon;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.onCancel,
    this.onConfirm,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: icon != null
          ? Icon(
              icon,
              color: colorScheme.primary,
            )
          : null,

      title: Text(title),

      content: content ??
          (message != null
              ? Text(message!)
              : null),

      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text(cancelText),
          ),

        if (onConfirm != null)
          FilledButton(
            onPressed: onConfirm,
            child: Text(confirmText),
          ),
      ],
    );
  }
}

//  how to use it 
// showDialog(
//   context: context,
//   builder: (context) {
//     return AppDialog(
//       title: 'Logout',
//       message: 'Are you sure you want to logout?',
//       onCancel: () {
//         Navigator.pop(context);
//       },
//       onConfirm: () {
//         Navigator.pop(context);
//       },
//     );
//   },
// );