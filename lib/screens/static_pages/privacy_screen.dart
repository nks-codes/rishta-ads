import 'package:flutter/material.dart';

import 'info_page.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const List<InfoBlock> _blocks = [
    InfoBlock.paragraph(
        'We respect your privacy and aim to handle your information responsibly.'),
    InfoBlock.paragraph(
        'This policy explains how Rishta Ads collects, uses, displays, and protects information submitted through the application.'),
    InfoBlock.heading('1. Information We Collect'),
    InfoBlock.paragraph(
        'When submitting an advertisement, users may be asked to provide information such as:'),
    InfoBlock.bullet('Name or introductory details.'),
    InfoBlock.bullet('Gender.'),
    InfoBlock.bullet('Age.'),
    InfoBlock.bullet('City.'),
    InfoBlock.bullet('Marital status.'),
    InfoBlock.bullet('Advertisement description.'),
    InfoBlock.bullet('Contact phone number.'),
    InfoBlock.bullet('Email address, where required.'),
    InfoBlock.heading('2. How We Use Information'),
    InfoBlock.paragraph('Submitted information is used to:'),
    InfoBlock.bullet('Publish approved matrimonial advertisements.'),
    InfoBlock.bullet('Help visitors discover suitable advertisements.'),
    InfoBlock.bullet('Apply search filters.'),
    InfoBlock.bullet('Allow interested individuals to contact advertisers.'),
    InfoBlock.bullet('Review and moderate submitted advertisements.'),
    InfoBlock.bullet('Manage advertisement expiry and renewal.'),
    InfoBlock.heading('3. Phone Number Privacy'),
    InfoBlock.paragraph(
        'Phone numbers are not displayed openly on advertisement cards by default.'),
    InfoBlock.paragraph(
        'Visitors must use the Show Number feature to reveal the contact number.'),
    InfoBlock.paragraph(
        "By submitting an advertisement and providing a contact number for this purpose, the advertiser acknowledges that interested visitors may reveal and use that number."),
    InfoBlock.heading('4. Advertisement Visibility'),
    InfoBlock.paragraph(
        'Advertisements are not publicly displayed immediately after submission.'),
    InfoBlock.paragraph(
        'They are first reviewed by the administration. Only approved advertisements become publicly visible.'),
    InfoBlock.heading('5. Advertisement Expiry'),
    InfoBlock.paragraph(
        'Approved advertisements are intended to remain active for seven days. After expiry, they may no longer appear in public listings.'),
    InfoBlock.heading('6. Data Retention'),
    InfoBlock.paragraph(
        'Information may be retained for administrative, security, operational, and record-keeping purposes in accordance with applicable requirements.'),
    InfoBlock.heading('7. Third-Party Access'),
    InfoBlock.paragraph(
        "We do not intend to sell users' personal information. However, information deliberately published in an advertisement or revealed through its contact feature may be accessed or copied by other people."),
    InfoBlock.heading('8. User Responsibility'),
    InfoBlock.paragraph(
        'Users should only submit information they have permission to share. Do not include sensitive information that is unnecessary for a matrimonial advertisement.'),
    InfoBlock.heading('9. Policy Updates'),
    InfoBlock.paragraph(
        'We may update this policy when application features or privacy practices change.'),
    InfoBlock.paragraph(
        'For privacy-related questions, contact us through our website.'),
  ];

  @override
  Widget build(BuildContext context) {
    return const InfoPage(title: 'Privacy Policy', blocks: _blocks);
  }
}
