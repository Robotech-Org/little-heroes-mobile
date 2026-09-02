import 'package:flutter/material.dart';

import 'document_viewer_page.dart';

class DocumentViewerDemoPage extends StatelessWidget {
  const DocumentViewerDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Viewer Demo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _DocumentTile(
            title: 'Student Report',
            subtitle: 'PDF document',
            icon: Icons.picture_as_pdf_rounded,
            onTap: () {
              _open(
                context,
                'https://www.soundcityreading.net/uploads/3/7/6/1/37611941/bphp-storiesonly-1-8_1.pdf',
                'Student Report',
              );
            },
          ),

          _DocumentTile(
            title: 'School Image',
            subtitle: 'Image',
            icon: Icons.image_rounded,
            onTap: () {
              _open(context, 'https://picsum.photos/900/600', 'School Image');
            },
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewerPage(url: url, title: title),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DocumentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
