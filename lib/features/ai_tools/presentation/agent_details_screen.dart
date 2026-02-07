import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_extensions.dart';

class AgentDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final IconData icon;
  final Color iconColor;
  final String badge;
  final Color badgeColor;

  const AgentDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.iconColor,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.onSurface),
              onPressed: () => context.pop(),
            ),
            expandedHeight: 0,
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildStats(context),
                _buildCapabilities(context),
                const SizedBox(height: 24),
                _buildSubscriptionPlans(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
           Align(
            alignment: Alignment.centerRight,
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildStatCard(
            context,
            Icons.bolt, 
            'Lightning Fast', 
            '< 2s response',
            const Color(0xFF8B5CF6)
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            Icons.group, 
            'Active Users', 
            '12.5K+',
            const Color(0xFF00D1FF)
          ),
           const SizedBox(height: 12),
          _buildStatCard(
            context,
            Icons.show_chart, 
            'Accuracy', 
            '99.2%',
            const Color(0xFF10B981)
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilities(BuildContext context) {
    final capabilities = [
      'Multi-language content generation',
      'SEO optimization',
      'Brand voice customization',
      'Real-time collaboration',
      'API integration',
      'Advanced analytics',
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capabilities',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...capabilities.map((cap) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  cap,
                  style: TextStyle(
                    color: context.onSurface.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Plans',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
           _buildPlanCard(
            context,
            'Starter',
            '\$29',
            '1K requests/mo',
            [
              'Basic AI models', 
              'Email support', 
              'API access'
            ],
            isPopular: false,
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            'Professional',
            '\$99',
            '10K requests/mo',
            [
              'Advanced AI models',
              'Priority support',
              'Custom training', 
              'Analytics'
            ],
            isPopular: true,
          ),
          const SizedBox(height: 16),
           _buildPlanCard(
            context,
            'Enterprise',
            '\$299',
            'Unlimited',
             [
              'All AI models',
              '24/7 support',
              'Dedicated account',
              'Custom integration',
              'SLA guarantee'
            ],
            isPopular: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String planTitle, 
    String planPrice, 
    String limit, 
    List<String> features, 
    {required bool isPopular}
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isPopular ? const Color(0xFF6366F1) : context.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: isPopular ? null : Border.all(color: context.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planTitle,
                style: TextStyle(
                  color: isPopular ? Colors.white : context.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: planPrice,
                      style: TextStyle(
                        color: isPopular ? Colors.white : context.onSurface,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '/month',
                      style: TextStyle(
                        color: isPopular ? Colors.white.withValues(alpha: 0.7) : context.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                limit,
                style: TextStyle(
                  color: isPopular ? Colors.white.withValues(alpha: 0.5) : context.hintColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                         color: isPopular ? Colors.white.withValues(alpha: 0.2) : context.dividerColor,
                         shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.check, size: 10, color: isPopular ? Colors.white : context.iconColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: TextStyle(
                        color: isPopular ? Colors.white : context.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/subscription-payment', extra: {
                      'planName': planTitle,
                      'planPrice': planPrice,
                      'planLimit': limit,
                      'planFeatures': features,
                      'agentName': title,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular ? const Color(0xFF8B5CF6) : context.onSurface.withValues(alpha: 0.1),
                    foregroundColor: isPopular ? Colors.white : context.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Subscribe',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
         if (isPopular)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
             Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Free Trial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Configure'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.onSurface,
                  side: BorderSide(color: context.dividerColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
