import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum InfoBlockType { heading, paragraph, bullet }

/// One piece of content on an information page.
class InfoBlock {
  const InfoBlock.heading(this.text) : type = InfoBlockType.heading;
  const InfoBlock.paragraph(this.text) : type = InfoBlockType.paragraph;
  const InfoBlock.bullet(this.text) : type = InfoBlockType.bullet;

  final InfoBlockType type;
  final String text;
}

/// Reusable native screen for the informational pages (About, Privacy, ...).
class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.title, required this.blocks});

  final String title;
  final List<InfoBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [for (final block in blocks) _buildBlock(block)],
        ),
      ),
    );
  }

  Widget _buildBlock(InfoBlock block) {
    switch (block.type) {
      case InfoBlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 6),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        );
      case InfoBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.text,
            ),
          ),
        );
      case InfoBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Text('•',
                    style: TextStyle(fontSize: 15, color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
