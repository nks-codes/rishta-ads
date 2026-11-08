import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/dependencies.dart';
import '../../models/ad_filters.dart';
import '../../utils/constants.dart';

/// Bottom sheet with the filters supported by the API.
/// Pops with the chosen [AdFilters] (an empty one when reset).
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final AdFilters initial;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  late Future<List<String>> _citiesFuture;
  String? _city;
  String? _gender;
  String? _marital;

  @override
  void initState() {
    super.initState();
    _city = widget.initial.city;
    _gender = widget.initial.gender;
    _marital = widget.initial.maritalStatus;
    _minCtrl =
        TextEditingController(text: widget.initial.minAge?.toString() ?? '');
    _maxCtrl =
        TextEditingController(text: widget.initial.maxAge?.toString() ?? '');
    _citiesFuture = cityService.loadCities();
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  String? _validateAge(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final age = int.tryParse(text);
    if (age == null || age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Use ${AppConstants.minAge}–${AppConstants.maxAge}';
    }
    return null;
  }

  String? _validateMax(String? value) {
    final basic = _validateAge(value);
    if (basic != null) return basic;
    final max = int.tryParse(value?.trim() ?? '');
    final min = int.tryParse(_minCtrl.text.trim());
    if (max != null && min != null && max < min) return 'Must be ≥ min';
    return null;
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      AdFilters(
        city: _city,
        gender: _gender,
        maritalStatus: _marital,
        minAge: int.tryParse(_minCtrl.text.trim()),
        maxAge: int.tryParse(_maxCtrl.text.trim()),
      ),
    );
  }

  void _reset() => Navigator.of(context).pop(const AdFilters());

  Widget _dropdown({
    required String label,
    required String allLabel,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String?>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      hint: Text(allLabel),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
        for (final option in options)
          DropdownMenuItem<String?>(
            value: option,
            child: Text(option, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildCityField() {
    return FutureBuilder<List<String>>(
      future: _citiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading cities…'),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Row(
            children: [
              const Expanded(child: Text('Could not load the city list.')),
              TextButton(
                onPressed: () => setState(() {
                  _citiesFuture = cityService.loadCities(forceRefresh: true);
                }),
                child: const Text('Retry'),
              ),
            ],
          );
        }
        final cities = <String>{...?snapshot.data, if (_city != null) _city!}
            .toList();
        return _dropdown(
          label: 'City',
          allLabel: 'All cities',
          value: _city,
          options: cities,
          onChanged: (v) => setState(() => _city = v),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filter ads',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildCityField(),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Gender',
                allLabel: 'Any',
                value: _gender,
                options: AppConstants.genders,
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Marital status',
                allLabel: 'Any',
                value: _marital,
                options: AppConstants.maritalStatuses,
                onChanged: (v) => setState(() => _marital = v),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Min age'),
                      validator: _validateAge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Max age'),
                      validator: _validateMax,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset Filters'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
