import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';
import '../../utils/constants.dart';
import '../../utils/external_links.dart';
import '../../widgets/app_header.dart';
import '../static_pages/about_screen.dart';
import '../static_pages/how_it_works_screen.dart';
import '../static_pages/privacy_screen.dart';
import '../static_pages/safety_screen.dart';
import '../static_pages/terms_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _shareApp() async {
    await Share.share(
      '${AppConstants.appName} - browse and post matrimonial advertisements '
      'across Pakistan.\n${AppConstants.poweredBy}\n${AppConstants.appShareUrl}',
      subject: AppConstants.appName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const AppHeader(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MenuGroup(
                  children: [
                    _MenuTile(
                      icon: Icons.info_outline,
                      title: 'About Rishta Ads',
                      onTap: () => _open(const AboutScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.help_outline,
                      title: 'How It Works',
                      onTap: () => _open(const HowItWorksScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.shield_outlined,
                      title: 'Safety Guidelines',
                      onTap: () => _open(const SafetyScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _open(const PrivacyScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.description_outlined,
                      title: 'Terms and Conditions',
                      onTap: () => _open(const TermsScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.mail_outline,
                      title: 'Contact Us',
                      external: true,
                      onTap: () =>
                          openExternalUrl(context, AppConstants.contactUrl),
                    ),
                    _MenuTile(
                      icon: Icons.share_outlined,
                      title: 'Share App',
                      onTap: _shareApp,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBiahCard(),
                const SizedBox(height: 24),
                _buildFooter(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiahCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Biah.pk',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Visit Biah.pk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Looking for a complete free matrimonial platform?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Biah.pk helps individuals and families discover matrimonial profiles and find suitable marriage proposals across Pakistan.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore verified profiles, discover potential life partners, and enjoy a simple matrimonial experience without paid memberships.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => openExternalUrl(context, AppConstants.websiteUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Visit Biah.pk'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          AppConstants.poweredBy,
          style: TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 2),
        FutureBuilder<PackageInfo>(
          future: _packageInfo,
          builder: (context, snapshot) {
            final info = snapshot.data;
            return Text(
              info == null ? 'Version' : 'Version ${info.version}',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            );
          },
        ),
      ],
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(const Divider(height: 1, color: AppColors.border));
      }
      items.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.external = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// Shows an "opens outside the app" icon instead of a chevron.
  final bool external;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Icon(
        external ? Icons.open_in_new : Icons.chevron_right,
        size: 20,
        color: AppColors.muted,
      ),
      onTap: onTap,
    );
  }
}
