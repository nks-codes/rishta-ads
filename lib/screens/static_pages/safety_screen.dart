import 'package:flutter/material.dart';

import 'info_page.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  static const List<InfoBlock> _blocks = [
    InfoBlock.paragraph('Your safety and privacy are important to us.'),
    InfoBlock.paragraph(
        'Please follow these guidelines when using Rishta Ads.'),
    InfoBlock.heading('1. Verify Information'),
    InfoBlock.paragraph(
        'Always independently verify the identity, family background, education, occupation, and other important details provided by an advertiser.'),
    InfoBlock.heading('2. Never Send Money'),
    InfoBlock.paragraph(
        'Never send money, advance payments, gifts, or financial assistance to someone you have only contacted through a matrimonial advertisement.'),
    InfoBlock.heading('3. Protect Your Personal Information'),
    InfoBlock.paragraph(
        'Do not share passwords, verification codes, identity documents, banking information, or other sensitive personal details with strangers.'),
    InfoBlock.heading('4. Communicate Carefully'),
    InfoBlock.paragraph(
        'Take your time when communicating with potential marriage proposals. Involve trusted family members when appropriate.'),
    InfoBlock.heading('5. Arrange Safe Meetings'),
    InfoBlock.paragraph(
        'If you decide to meet someone, choose a safe public location and inform your trusted family members.'),
    InfoBlock.heading('6. Report Suspicious Advertisements'),
    InfoBlock.paragraph(
        'If you notice misleading information, suspicious behaviour, fraudulent advertisements, or inappropriate content, please report it to Biah.pk.'),
    InfoBlock.heading('7. Do Your Own Verification'),
    InfoBlock.paragraph(
        'Rishta Ads provides a platform for sharing matrimonial advertisements. Publication of an advertisement does not mean that the advertiser or the information has been independently verified.'),
    InfoBlock.paragraph('Contact us if you encounter a safety concern.'),
  ];

  @override
  Widget build(BuildContext context) {
    return const InfoPage(title: 'Safety Guidelines', blocks: _blocks);
  }
}
