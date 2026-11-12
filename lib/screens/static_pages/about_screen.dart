import 'package:flutter/material.dart';

import 'info_page.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<InfoBlock> _blocks = [
    InfoBlock.paragraph(
        'Rishta Ads is a simple and free matrimonial classifieds platform designed to help individuals and families discover matrimonial advertisements from different cities across Pakistan.'),
    InfoBlock.paragraph(
        'Our goal is to make sharing and discovering marriage proposals easier, more accessible, and convenient for everyone.'),
    InfoBlock.paragraph(
        'Users can browse available advertisements, explore potential marriage proposals using filters, and contact advertisers directly after choosing to reveal their contact numbers.'),
    InfoBlock.paragraph(
        'Rishta Ads is designed to be simple and accessible. Users do not need to create an account to submit a matrimonial advertisement.'),
    InfoBlock.paragraph(
        'All submitted advertisements are reviewed before publication to help maintain the quality and safety of the platform.'),
    InfoBlock.paragraph(
        'Rishta Ads is powered by Biah.pk, a free matrimonial platform working to make finding suitable marriage proposals easier.'),
    InfoBlock.heading('Our mission'),
    InfoBlock.paragraph(
        'To make sharing and discovering matrimonial advertisements easier for everyone.'),
  ];

  @override
  Widget build(BuildContext context) {
    return const InfoPage(title: 'About Rishta Ads', blocks: _blocks);
  }
}
