import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_extensions.dart';
import '../domain/entities/business_plan.dart';

class BusinessPlansScreen extends StatefulWidget {
  const BusinessPlansScreen({super.key});

  @override
  State<BusinessPlansScreen> createState() => _BusinessPlansScreenState();
}

class _BusinessPlansScreenState extends State<BusinessPlansScreen> {
  int _selectedPlanIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Business Plans',
          style: TextStyle(
            color: context.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            ...List.generate(BusinessPlan.allPlans.length, (index) {
              final plan = BusinessPlan.allPlans[index];
              return _buildPlanCard(context, plan, index);
            }),
            const SizedBox(height: 24),
            _buildComparisonSection(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upgrade Your Business',
          style: TextStyle(
            color: context.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Unlock more media uploads, analytics, and premium features to grow your business.',
          style: TextStyle(
            color: context.onSurfaceVariant,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, BusinessPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    final isFree = plan.type == BusinessPlanType.free;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
              : context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : context.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              color: context.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.mediaLimitText,
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price,
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (!isFree)
                      Text(
                        '/${plan.billingCycle}',
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plan.features.take(4).map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF10B981),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        feature,
                        style: TextStyle(
                          color: context.onSurface.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (isSelected && !isFree) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF8B5CF6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Includes all features from lower tiers',
                        style: TextStyle(
                          color: context.onSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: context.iconColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Quick Comparison',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildComparisonRow(context, 'Videos', ['2', '5', '15', '∞']),
          const SizedBox(height: 12),
          _buildComparisonRow(context, 'Images', ['5', '15', '50', '∞']),
          const SizedBox(height: 12),
          _buildComparisonRow(context, 'Duration', ['1m', '3m', '10m', '60m']),
          const SizedBox(height: 12),
          _buildComparisonRow(context, 'Analytics', ['Basic', 'Enhanced', 'Advanced', 'Full']),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(BuildContext context, String label, List<String> values) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: context.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
        ...List.generate(values.length, (index) {
          final isSelected = _selectedPlanIndex == index;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                values[index],
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : context.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final selectedPlan = BusinessPlan.allPlans[_selectedPlanIndex];
    final isFree = selectedPlan.type == BusinessPlanType.free;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.dividerColor)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFree) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedPlan.name} Plan',
                    style: TextStyle(
                      color: context.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${selectedPlan.price}/${selectedPlan.billingCycle}',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFree
                    ? () => context.pop()
                    : () {
                        context.push('/subscription-payment', extra: {
                          'planName': selectedPlan.name,
                          'planPrice': selectedPlan.price,
                          'planLimit': selectedPlan.mediaLimitText,
                          'planFeatures': selectedPlan.features,
                          'agentName': '${selectedPlan.name} Business Plan',
                          'successButtonText': 'Go to My Business',
                          'successRoute': '/business',
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFree
                      ? context.onSurface.withValues(alpha: 0.1)
                      : const Color(0xFF8B5CF6),
                  foregroundColor: isFree ? context.onSurface : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isFree ? 'Continue with Free' : 'Upgrade to ${selectedPlan.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
