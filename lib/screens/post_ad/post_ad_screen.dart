import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../models/api_response_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/app_header.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  static const Duration _cooldown = Duration(seconds: 30);
  static const String _consentText =
      'I allow visitors to reveal my contact number when they click Show Number.';

  final _formKey = GlobalKey<FormState>();
  final _cityCtrl = TextEditingController();
  final _cityFocus = FocusNode();
  final _ageCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? _gender;
  String? _marital;
  bool _consent = false;
  bool _consentError = false;

  bool _submitting = false;
  String? _error;
  SubmitResult? _success;

  /// Cities from the server, used only as suggestions. Users may type any city.
  List<String> _cities = const [];

  Timer? _timer;
  DateTime? _cooldownUntil;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    cityService.loadCities().then((cities) {
      if (mounted) setState(() => _cities = cities);
    }).catchError((Object _) {
      // Suggestions are optional; typing a city always works.
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cityCtrl.dispose();
    _cityFocus.dispose();
    _ageCtrl.dispose();
    _textCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Trims, collapses spaces, and uses the server's exact spelling when the
  /// typed city matches an existing one (ignoring letter case).
  String _normalizedCity() {
    final typed = _cityCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    for (final city in _cities) {
      if (city.toLowerCase() == typed.toLowerCase()) return city;
    }
    return typed;
  }

  void _startCooldown() {
    _timer?.cancel();
    _cooldownUntil = DateTime.now().add(_cooldown);
    _secondsLeft = _cooldown.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _cooldownUntil!.difference(DateTime.now());
      if (remaining.inMilliseconds <= 0) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft = (remaining.inMilliseconds / 1000).ceil());
      }
    });
  }

  void _clearForm() {
    _cityCtrl.clear();
    _ageCtrl.clear();
    _textCtrl.clear();
    _phoneCtrl.clear();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _gender = null;
    _marital = null;
    _consent = false;
    _consentError = false;
  }

  Future<void> _submit() async {
    // Block repeated taps while a request is running or during the cooldown.
    if (_submitting || _secondsLeft > 0) return;
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    setState(() => _consentError = !_consent);
    if (!valid || !_consent) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final result = await apiService.submitAd(
        adText: _textCtrl.text.trim(),
        city: _normalizedCity(),
        gender: _gender!,
        age: int.parse(_ageCtrl.text.trim()),
        maritalStatus: _marital!,
        phoneNumber: _phoneCtrl.text.trim(),
        phoneConsent: _consent,
        contactName: _nameCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      // Success is shown only after the API confirmed it.
      _clearForm();
      _startCooldown();
      setState(() {
        _submitting = false;
        _success = result;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 429) _startCooldown();
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const AppHeader(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _success != null ? _buildSuccess(_success!) : _buildForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const Text(
            'Post an Ad',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildCityField(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: [
                    for (final g in AppConstants.genders)
                      DropdownMenuItem<String>(value: g, child: Text(g)),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                  validator: Validators.gender,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(labelText: 'Age'),
                  validator: Validators.age,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _marital,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Marital status'),
            items: [
              for (final m in AppConstants.maritalStatuses)
                DropdownMenuItem<String>(value: m, child: Text(m)),
            ],
            onChanged: (v) => setState(() => _marital = v),
            validator: Validators.maritalStatus,
          ),
          const SizedBox(height: 12),
          _buildAdTextField(),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+().\-\s]')),
              LengthLimitingTextInputFormatter(30),
            ],
            decoration: const InputDecoration(
              labelText: 'Phone number',
              helperText: 'Hidden until a visitor taps Show Number.',
            ),
            validator: Validators.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Contact name (optional)',
              helperText: 'Not shown to visitors.',
            ),
            validator: Validators.contactName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Email (optional)',
              helperText: 'Not shown to visitors.',
            ),
            validator: Validators.contactEmail,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _consent,
            onChanged: _submitting
                ? null
                : (v) => setState(() {
                      _consent = v ?? false;
                      if (_consent) _consentError = false;
                    }),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            title: const Text(_consentText, style: TextStyle(fontSize: 14)),
          ),
          if (_consentError)
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Please tick the box to allow contact number reveal.',
                style: TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 20, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(color: AppColors.text)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_submitting || _secondsLeft > 0) ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _submitting
                    ? 'Submitting…'
                    : _secondsLeft > 0
                        ? 'Please wait ${_secondsLeft}s'
                        : 'Submit Advertisement',
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No account needed. Your advertisement is reviewed before it is '
              'published, and submitting does not guarantee approval. '
              'Approved advertisements stay active for 7 days.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          textEditingController: _cityCtrl,
          focusNode: _cityFocus,
          optionsBuilder: (value) {
            if (_cities.isEmpty) return const Iterable<String>.empty();
            final query = value.text.trim().toLowerCase();
            if (query.isEmpty) return _cities;
            return _cities.where((c) => c.toLowerCase().contains(query));
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'City',
                helperText: 'Type your city, or pick a suggestion.',
              ),
              validator: Validators.city,
              onFieldSubmitted: (_) => onSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 220,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _textCtrl,
          minLines: 4,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Advertisement text',
            alignLabelWithHint: true,
          ),
          validator: Validators.adText,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textCtrl,
              builder: (context, value, _) {
                final count = value.text.trim().runes.length;
                final over = count > AppConstants.adTextMaxLength;
                return Text(
                  '$count/${AppConstants.adTextMaxLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: over ? Colors.redAccent : AppColors.muted,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(SubmitResult result) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle, size: 72, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text(
          'Advertisement submitted',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          result.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        if (result.adId != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Reference: ${result.adId}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Your advertisement will appear in Browse after it is approved. '
          'Approved advertisements stay active for 7 days.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => setState(() => _success = null),
          child: Text(
            _secondsLeft > 0
                ? 'Post another ad (wait ${_secondsLeft}s to submit)'
                : 'Post another ad',
          ),
        ),
      ],
    );
  }
}
