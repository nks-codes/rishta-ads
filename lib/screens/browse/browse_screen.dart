import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../models/ad_filters.dart';
import '../../models/ad_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'ad_card.dart';
import 'filter_sheet.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  static const String _genericError =
      'Something went wrong. Please try again.';

  final ScrollController _scroll = ScrollController();
  final List<Ad> _ads = [];
  final Set<String> _ids = {};

  AdFilters _filters = const AdFilters();
  int _page = 0;
  bool _hasMore = true;
  int? _total;
  bool _loadingFirst = true;
  bool _loadingMore = false;
  String? _error;
  String? _moreError;

  /// Incremented for every fresh load so late responses are ignored.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage({bool showSpinner = true}) async {
    final generation = ++_generation;
    setState(() {
      _loadingMore = false;
      _moreError = null;
      if (showSpinner) {
        _loadingFirst = true;
        _error = null;
      }
    });
    try {
      final result = await apiService.fetchAds(page: 1, filters: _filters);
      if (!mounted || generation != _generation) return;
      setState(() {
        _ads
          ..clear()
          ..addAll(result.ads);
        _ids
          ..clear()
          ..addAll(result.ads.map((a) => a.id));
        _page = 1;
        _hasMore = result.hasMore;
        _total = result.pagination.totalAds;
        _loadingFirst = false;
        _error = null;
      });
    } on ApiException catch (e) {
      _handleFirstPageError(generation, e.message);
    } catch (_) {
      _handleFirstPageError(generation, _genericError);
    }
  }

  void _handleFirstPageError(int generation, String message) {
    if (!mounted || generation != _generation) return;
    final keepList = _ads.isNotEmpty;
    setState(() {
      _loadingFirst = false;
      if (!keepList) _error = message;
    });
    if (keepList) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _loadMore() async {
    if (_loadingFirst || _loadingMore || !_hasMore || _error != null) return;
    final generation = _generation;
    setState(() {
      _loadingMore = true;
      _moreError = null;
    });
    try {
      final result =
          await apiService.fetchAds(page: _page + 1, filters: _filters);
      if (!mounted || generation != _generation) return;
      setState(() {
        for (final ad in result.ads) {
          if (_ids.add(ad.id)) _ads.add(ad);
        }
        _page += 1;
        _hasMore = result.hasMore;
        _total = result.pagination.totalAds;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      _handleMoreError(generation, e.message);
    } catch (_) {
      _handleMoreError(generation, _genericError);
    }
  }

  void _handleMoreError(int generation, String message) {
    if (!mounted || generation != _generation) return;
    setState(() {
      _loadingMore = false;
      _moreError = message;
    });
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<AdFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => FilterSheet(initial: _filters),
    );
    if (result == null) return;
    _applyFilters(result);
  }

  void _applyFilters(AdFilters filters) {
    setState(() {
      _filters = filters;
      _ads.clear();
      _ids.clear();
      _total = null;
      _page = 0;
      _hasMore = true;
    });
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const AppHeader(),
          _buildFilterBar(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final count = _filters.activeCount;
    final total = _total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune, size: 20),
            label: Text(count > 0 ? 'Filters ($count)' : 'Filters'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              total == null ? '' : '$total ${total == 1 ? 'ad' : 'ads'} found',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ),
          if (_filters.isActive)
            TextButton(
              onPressed: () => _applyFilters(const AdFilters()),
              child: const Text('Reset'),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingFirst) return const LoadingWidget();

    if (_error != null && _ads.isEmpty) {
      return ErrorStateWidget(
        message: _error!,
        onRetry: () => _loadFirstPage(),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        // Also refresh the city list so newly approved cities appear.
        cityService.loadCities(forceRefresh: true).ignore();
        return _loadFirstPage(showSpinner: false);
      },
      child: _ads.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 60),
                EmptyStateWidget(
                  message: 'No matching advertisements found.',
                  onReset: _filters.isActive
                      ? () => _applyFilters(const AdFilters())
                      : null,
                ),
              ],
            )
          : ListView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: _ads.length + 1,
              itemBuilder: (context, index) {
                if (index < _ads.length) {
                  final ad = _ads[index];
                  return AdCard(
                    key: ValueKey(ad.id),
                    ad: ad,
                    onReveal: apiService.revealPhone,
                  );
                }
                return _buildFooter();
              },
            ),
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.primary),
          ),
        ),
      );
    }
    if (_moreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(_moreError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted)),
            TextButton(onPressed: _loadMore, child: const Text('Try again')),
          ],
        ),
      );
    }
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'You have reached the end.',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
