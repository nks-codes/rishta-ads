import 'package:flutter/material.dart';

import 'info_page.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const List<InfoBlock> _blocks = [
    InfoBlock.paragraph(
        'By accessing or using Rishta Ads, you agree to these Terms and Conditions.'),
    InfoBlock.heading('1. Purpose of the Platform'),
    InfoBlock.paragraph(
        'Rishta Ads provides a platform for publishing and discovering matrimonial advertisements. It helps individuals and families connect regarding potential marriage proposals.'),
    InfoBlock.heading('2. Free Service'),
    InfoBlock.paragraph(
        'Browsing and submitting advertisements are intended to be free of charge. The platform does not require a paid membership to use its basic matrimonial classifieds functionality.'),
    InfoBlock.heading('3. Accurate Information'),
    InfoBlock.paragraph(
        'Users must provide truthful, accurate, and relevant information when submitting advertisements.'),
    InfoBlock.paragraph(
        'Misleading, fraudulent, impersonated, or intentionally false advertisements are not permitted.'),
    InfoBlock.heading('4. Permission to Publish'),
    InfoBlock.paragraph(
        'Users must have the right and permission to submit any personal or family information included in an advertisement.'),
    InfoBlock.paragraph(
        "Do not publish another person's phone number, photograph, or personal details without appropriate permission."),
    InfoBlock.heading('5. Advertisement Review'),
    InfoBlock.paragraph(
        'All submitted advertisements are subject to administrative review.'),
    InfoBlock.paragraph(
        'The administration may approve, reject, edit for formatting or safety, remove, or decline to publish advertisements that violate these terms or platform guidelines.'),
    InfoBlock.heading('6. Advertisement Duration'),
    InfoBlock.paragraph(
        'Approved advertisements are normally displayed for seven days.'),
    InfoBlock.paragraph(
        'Renewal may be available through an email renewal link where supported.'),
    InfoBlock.heading('7. Contact Information'),
    InfoBlock.paragraph(
        'Phone numbers are initially hidden and can be revealed through the Show Number feature.'),
    InfoBlock.paragraph(
        'Users who submit advertisements understand that their provided contact numbers may become visible to visitors who use this feature.'),
    InfoBlock.heading('8. Prohibited Content'),
    InfoBlock.paragraph('The following are not allowed:'),
    InfoBlock.bullet('Fake or misleading matrimonial advertisements.'),
    InfoBlock.bullet('Fraudulent or deceptive information.'),
    InfoBlock.bullet('Harassment, threats, or abusive language.'),
    InfoBlock.bullet('Financial scams or requests for money.'),
    InfoBlock.bullet('Advertisements containing illegal or inappropriate material.'),
    InfoBlock.bullet('Personal information published without permission.'),
    InfoBlock.bullet('Duplicate or spam advertisements.'),
    InfoBlock.heading('9. User Responsibility'),
    InfoBlock.paragraph(
        'Users are responsible for independently verifying the identity and background of people they contact through advertisements.'),
    InfoBlock.paragraph(
        'Rishta Ads does not guarantee the authenticity of every advertiser, the accuracy of submitted information, or the outcome of any matrimonial interaction.'),
    InfoBlock.heading('10. Limitation of Responsibility'),
    InfoBlock.paragraph(
        'Rishta Ads provides a platform for advertisement publication and discovery. Users are responsible for their own communications, decisions, meetings, and interactions.'),
    InfoBlock.heading('11. Changes to Terms'),
    InfoBlock.paragraph(
        'We may update these terms when necessary. Continued use of the application after changes means users accept the updated terms.'),
    InfoBlock.heading('12. Contact'),
    InfoBlock.paragraph(
        'For complaints, questions, or concerns, please contact us through our official website.'),
  ];

  @override
  Widget build(BuildContext context) {
    return const InfoPage(title: 'Terms and Conditions', blocks: _blocks);
  }
}
