import 'package:flutter/material.dart';

import 'info_page.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  static const List<InfoBlock> _blocks = [
    InfoBlock.paragraph(
        'Rishta Ads makes discovering and sharing matrimonial advertisements simple.'),
    InfoBlock.heading('1. Browse Advertisements'),
    InfoBlock.paragraph(
        'Open the app and explore available matrimonial advertisements from different cities across Pakistan.'),
    InfoBlock.heading('2. Apply Filters'),
    InfoBlock.paragraph(
        'Find relevant advertisements using filters such as city, gender, age, and marital status.'),
    InfoBlock.heading('3. Read Advertisements'),
    InfoBlock.paragraph(
        'Review the information provided in each advertisement carefully.'),
    InfoBlock.heading('4. Reveal Contact Number'),
    InfoBlock.paragraph(
        "Phone numbers are initially hidden. Tap the Show Number button to reveal the advertiser's contact number."),
    InfoBlock.heading('5. Post Your Own Advertisement'),
    InfoBlock.paragraph(
        'Anyone can submit a matrimonial advertisement without creating an account.'),
    InfoBlock.paragraph(
        'Provide the required information, write a short and truthful introduction, and submit your advertisement for review.'),
    InfoBlock.heading('6. Advertisement Approval'),
    InfoBlock.paragraph(
        'Submitted advertisements are reviewed by the administration before they become publicly visible. Submission does not guarantee approval.'),
    InfoBlock.heading('7. Advertisement Duration'),
    InfoBlock.paragraph(
        'Approved advertisements remain active for seven days. Where an expiry notification is available, advertisers may receive an email with a renewal link.'),
  ];

  @override
  Widget build(BuildContext context) {
    return const InfoPage(title: 'How Rishta Ads Works', blocks: _blocks);
  }
}
