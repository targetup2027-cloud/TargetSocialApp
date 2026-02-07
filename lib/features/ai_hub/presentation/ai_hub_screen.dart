import 'package:flutter/material.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../app/theme/uaxis_theme.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/motion/motion_system.dart';

class AIHubScreen extends StatefulWidget {
  const AIHubScreen({super.key});

  @override
  State<AIHubScreen> createState() => _AIHubScreenState();
}

class _AIHubScreenState extends State<AIHubScreen> {
  int _selectedTab = 0;
  int _selectedAgentFilter = 0;
  final TextEditingController _chatController = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hello! I'm your AI assistant. How can I help you today?",
      isUser: false,
    ),
  ];
  final ScrollController _scrollController = ScrollController();

  final List<String> _agentFilters = [
    'All',
    'Development',
    'Creative',
    'Business',
    'Content'
  ];

  final List<_AgentItem> _agents = [
    _AgentItem(
      title: 'Code Assistant',
      description: 'Expert in coding, debugging, and technical solutions',
      category: 'Development',
      rating: '4.9',
      uses: '12.3K',
      color: UAxisColors.discoverPremium,
      icon: Icons.code,
    ),
    _AgentItem(
      title: 'Image Generator',
      description: 'Create stunning visuals from text descriptions',
      category: 'Creative',
      rating: '4.8',
      uses: '24.1K',
      color: UAxisColors.businessAi,
      icon: Icons.image_outlined,
    ),
    _AgentItem(
      title: 'Strategy Advisor',
      description: 'Business insights and strategic planning',
      category: 'Business',
      rating: '4.7',
      uses: '8.7K',
      color: UAxisColors.aiHub,
      icon: Icons.psychology_outlined,
    ),
    _AgentItem(
      title: 'Content Writer',
      description: 'Professional writing for any purpose',
      category: 'Content',
      rating: '4.9',
      uses: '15.2K',
      color: UAxisColors.messagesCommerce,
      icon: Icons.bolt,
    ),
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _chatController.clear();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: "I understand your request. This is a demonstration of the AI chat interface. In a production environment, this would connect to actual AI models.",
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      drawer: const UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Hub',
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your intelligent assistant network',
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildTab(0, 'AI Chat', Icons.chat_bubble_outline),
                          const SizedBox(width: 12),
                          _buildTab(1, 'AI Agents', Icons.auto_awesome_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _selectedTab == 0 ? _buildChatView() : _buildAgentsView(),
                ),
                if (_selectedTab == 0) _buildChatInput(),
              ],
            ),
          ),
          Builder(
            builder: (context) => SideMenuToggle(
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const UniverseBackButton(),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    final primaryColor = const Color(0xFF06B6D4); // AI Hub Theme Color

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: MotionTokens.quick,
        curve: MotionTokens.entrance,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? const Color(0xFF0891B2)
                  : context.iconColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF0891B2)
                    : context.onSurfaceVariant,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: message.isUser
              ? _buildUserMessage(message.text)
              : _buildAiMessage(message.text),
        );
      },
    );
  }

  Widget _buildUserMessage(String text) {
    final firstChar = text.isNotEmpty ? text[0].toUpperCase() : '?';
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF06B6D4),
          ),
          child: Center(
            child: Text(
              firstChar,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF06B6D4),
                Color(0xFF0891B2),
              ],
            ),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.dividerColor,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: context.onSurface.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        border: Border(
          top: BorderSide(color: context.dividerColor),
        ),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                style: TextStyle(color: context.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(
                    color: context.hintColor,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentsView() {
    // Filter agents based on selected category
    final filteredAgents = _selectedAgentFilter == 0
        ? _agents
        : _agents.where((a) => a.category == _agentFilters[_selectedAgentFilter]).toList();

    return Column(
      children: [
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _agentFilters.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedAgentFilter == index;
              // Count agents in each category
              final count = index == 0
                  ? _agents.length
                  : _agents.where((a) => a.category == _agentFilters[index]).length;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAgentFilter = index),
                  child: AnimatedContainer(
                    duration: MotionTokens.quick,
                    curve: MotionTokens.entrance,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF06B6D4).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF06B6D4).withValues(alpha: 0.5)
                            : context.dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _agentFilters[index],
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF06B6D4)
                                : context.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF06B6D4).withValues(alpha: 0.2)
                                : context.onSurface.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF06B6D4)
                                  : context.hintColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Divider(color: context.dividerColor, height: 1),
        const SizedBox(height: 16),
        Expanded(
          child: filteredAgents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 48,
                        color: context.hintColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No agents in this category',
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: filteredAgents.length,
                  itemBuilder: (context, index) {
                    return _AgentCard(item: filteredAgents[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _AgentItem {
  final String title;
  final String description;
  final String category;
  final String rating;
  final String uses;
  final Color color;
  final IconData icon;

  const _AgentItem({
    required this.title,
    required this.description,
    required this.category,
    required this.rating,
    required this.uses,
    required this.color,
    required this.icon,
  });
}

class _AgentCard extends StatelessWidget {
  final _AgentItem item;

  const _AgentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    color: context.onSurfaceVariant.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.rating,
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.uses} uses',
                      style: TextStyle(
                        color: context.hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
