import 'package:flutter/material.dart';
import '../../../data/models/paper.dart';

class HtmlReaderScreen extends StatelessWidget {
  const HtmlReaderScreen({
    required this.paper,
    this.initialSearchText,
    super.key,
  });

  final Paper paper;
  final String? initialSearchText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(paper.title)),
      body: const Center(child: Text('HTML Reader — coming soon')),
    );
  }
}
