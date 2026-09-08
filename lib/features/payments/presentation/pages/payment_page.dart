import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:little_heroes_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:little_heroes_mobile/features/payments/data/models/subscription_plan_model.dart';
import 'package:little_heroes_mobile/features/payments/domain/repositories/payment_repository.dart';
import 'package:little_heroes_mobile/injection_container.dart' as di;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<SubscriptionPlanModel> _plans = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _isRefreshing = false;
  String _errorMessage = '';
  SubscriptionPlanModel? _selectedPlan;

  // Cache
  List<SubscriptionPlanModel>? _cachedPlans;
  DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans({bool useCache = true}) async {
    // Check cache
    if (useCache && _cachedPlans != null && _lastCacheTime != null) {
      final cacheAge = DateTime.now().difference(_lastCacheTime!);
      if (cacheAge < _cacheDuration) {
        setState(() {
          _plans = _cachedPlans!;
          _isLoading = false;
          _isError = false;
          if (_plans.isNotEmpty && _selectedPlan == null) {
            _selectedPlan = _plans.first;
          }
        });
        return;
      }
    }

    setState(() {
      _isLoading = _cachedPlans == null;
      _isRefreshing = _cachedPlans != null;
      _isError = false;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = 'Please login to view plans';
        });
        return;
      }

      final repository = di.sl<PaymentRepository>();
      final response = await repository.getSubscriptionPlans();

      setState(() {
        _plans = response.items;
        _cachedPlans = response.items;
        _lastCacheTime = DateTime.now();
        _isLoading = false;
        _isRefreshing = false;
        _isError = false;
        if (_plans.isNotEmpty && _selectedPlan == null) {
          _selectedPlan = _plans.first;
        }
      });
    } catch (e) {
      // Use cached data if available
      if (_cachedPlans != null) {
        setState(() {
          _plans = _cachedPlans!;
          _isLoading = false;
          _isRefreshing = false;
          _isError = false;
          if (_plans.isNotEmpty && _selectedPlan == null) {
            _selectedPlan = _plans.first;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showPaymentSheet(SubscriptionPlanModel plan) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make Payment',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(plan.planName, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount Due',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        plan.formattedCost,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Payment for ${plan.planName} initiated. comming soon',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Continue to Payment',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Payments',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadPlans(useCache: false),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPlans(useCache: false),
        child: _buildContent(theme, colors),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colors) {
    if (_isLoading) {
      return _buildSkeletonLoading(theme, colors);
    }

    if (_isError) {
      return _buildErrorWidget(theme, colors);
    }

    if (_plans.isEmpty) {
      return _buildEmptyWidget(theme, colors);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Balance Due Card
              if (_plans.isNotEmpty) _BalanceDueCard(plan: _plans.first),
              const SizedBox(height: 30),
              // Stats
              Row(
                children: [
                  Text(
                    'Subscription Plans ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 14),
              ..._plans.map((plan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(
                    plan: plan,
                    isSelected: _selectedPlan == plan,
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan;
                      });
                    },
                    onPay: () => _showPaymentSheet(plan),
                  ),
                );
              }),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SKELETON LOADING
  // ============================================================

  Widget _buildSkeletonLoading(ThemeData theme, ColorScheme colors) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Balance Due Card Skeleton
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonLine(width: 100, height: 14),
                    const SizedBox(height: 8),
                    _buildSkeletonLine(width: 180, height: 28),
                    const SizedBox(height: 12),
                    _buildSkeletonLine(width: 120, height: 22),
                    const SizedBox(height: 4),
                    _buildSkeletonLine(width: 80, height: 14),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Title Skeleton
              _buildSkeletonLine(width: 160, height: 24),
              const SizedBox(height: 14),
              // Plan Cards Skeletons
              ...List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSkeletonLine(width: 140, height: 18),
                            const SizedBox(height: 4),
                            _buildSkeletonLine(width: 80, height: 14),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSkeletonLine(width: 70, height: 18),
                          const SizedBox(height: 6),
                          _buildSkeletonLine(width: 50, height: 16),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLine({double? width, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load plans',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _loadPlans(useCache: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY WIDGET
  // ============================================================

  Widget _buildEmptyWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No Subscription Plans',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No plans are currently available.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BALANCE DUE CARD
// ============================================================

class _BalanceDueCard extends StatelessWidget {
  final SubscriptionPlanModel plan;

  const _BalanceDueCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE PLAN',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.planName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            plan.formattedCost,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.billingText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.75),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PLAN CARD
// ============================================================

class _PlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPay;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.subscriptions_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.planName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.billingText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.formattedCost,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Selected',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: onPay,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
