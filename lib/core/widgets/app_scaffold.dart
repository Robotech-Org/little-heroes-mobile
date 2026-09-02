import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;

  final List<Widget>? actions;
  final Widget? leading;

  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  final bool automaticallyImplyLeading;

  final bool safeArea;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.automaticallyImplyLeading = true,
    this.safeArea = true, required bool resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    final content = safeArea
        ? SafeArea(child: body)
        : body;

    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              leading: leading,
              actions: actions,
              automaticallyImplyLeading:
                  automaticallyImplyLeading,
            )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}  

// how to use it 

// AppScaffold(
//   title: 'Notifications',
//   body: ListView(
//     children: const [
//       Text('Notification 1'),
//       Text('Notification 2'),
//     ],
//   ),
// )