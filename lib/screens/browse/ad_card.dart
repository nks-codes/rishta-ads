import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../models/ad_model.dart';
import '../../services/api_service.dart';

enum _PhoneState { hidden, loading, revealed, unavailable }

class AdCard extends StatefulWidget {
  const AdCard({super.key, required this.ad, required this.onReveal});

  final Ad ad;

  /// Calls the backend reveal API for the given advertisement ID.
  final Future<String> Function(String adId) onReveal;

  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  _PhoneState _state = _PhoneState.hidden;
  String? _phone;
  String? _message;

  Future<void> _reveal() async {
    if (_state == _PhoneState.loading) return;
    setState(() {
      _state = _PhoneState.loading;
      _message = null;
    });
    try {
      final phone = await widget.onReveal(widget.ad.id);
      if (!mounted) return;
      setState(() {
        _phone = phone;
        _state = _PhoneState.revealed;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = e.isNotFound ? _PhoneState.unavailable : _PhoneState.hidden;
        _message = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _PhoneState.hidden;
        _message = 'Could not get the phone number. Please try again.';
      });
    }
  }

  Future<void> _call() async {
    final number = _phone;
    if (number == null) return;
    final cleaned = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final ok = await launchUrl(
      Uri(scheme: 'tel', path: cleaned),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone app.')),
      );
    }
  }

  Future<void> _copy() async {
    final number = _phone;
    if (number == null) return;
    await Clipboard.setData(ClipboardData(text: number));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Number copied.')),
    );
  }

  String _daysLeftLabel(int days) {
    if (days <= 0) return 'Expiring today';
    if (days == 1) return '1 day left';
    return '$days days left';
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ad.id,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (ad.daysLeft != null)
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      _daysLeftLabel(ad.daysLeft!),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ad.city.isNotEmpty)
                _InfoChip(icon: Icons.location_on_outlined, label: ad.city),
              if (ad.gender.isNotEmpty)
                _InfoChip(icon: Icons.person_outline, label: ad.gender),
              if (ad.age > 0)
                _InfoChip(icon: Icons.cake_outlined, label: '${ad.age} years'),
              if (ad.maritalStatus.isNotEmpty)
                _InfoChip(
                    icon: Icons.favorite_border, label: ad.maritalStatus),
            ],
          ),
          if (ad.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              ad.text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppColors.text,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildPhoneSection(),
        ],
      ),
    );
  }

  Widget _buildPhoneSection() {
    switch (_state) {
      case _PhoneState.revealed:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.softPink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: SelectableText(
                  _phone ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Copy number',
                onPressed: _copy,
                icon: const Icon(Icons.copy, size: 20),
              ),
              IconButton(
                tooltip: 'Call',
                onPressed: _call,
                icon: const Icon(Icons.call, color: AppColors.primary),
              ),
            ],
          ),
        );
      case _PhoneState.unavailable:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _message ?? 'Phone number is unavailable for this advertisement.',
            style: const TextStyle(color: AppColors.muted),
          ),
        );
      case _PhoneState.loading:
      case _PhoneState.hidden:
        final loading = _state == _PhoneState.loading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loading ? null : _reveal,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.phone_outlined),
                label: const Text('Show Number'),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                style: const TextStyle(fontSize: 13, color: Colors.redAccent),
              ),
            ],
          ],
        );
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.text),
          ),
        ],
      ),
    );
  }
}
