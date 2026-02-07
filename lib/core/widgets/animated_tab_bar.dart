import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';

class AnimatedTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color? activeColor;
  final Color? indicatorColor;
  final EdgeInsets padding;
  final double spacing;
  final bool showIndicator;
  final TabIndicatorStyle indicatorStyle;

  const AnimatedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.activeColor,
    this.indicatorColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.spacing = 24,
    this.showIndicator = true,
    this.indicatorStyle = TabIndicatorStyle.underline,
  });

  @override
  State<AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar> {
  late List<GlobalKey> _tabKeys;
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
    // Use multiple frame callbacks to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _updateIndicator(animate: false);
      });
    });
  }

  @override
  void didUpdateWidget(AnimatedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _updateIndicator(animate: true);
    }
    // Regenerate keys if tabs changed
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateIndicator(animate: false);
      });
    }
  }

  void _updateIndicator({required bool animate}) {
    if (!mounted) return;
    if (widget.selectedIndex >= _tabKeys.length) return;
    
    final key = _tabKeys[widget.selectedIndex];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // Retry after a short delay if render box isn't ready
      Future.delayed(const Duration(milliseconds: 16), () {
        if (mounted) _updateIndicator(animate: animate);
      });
      return;
    }
    
    final position = renderBox.localToGlobal(Offset.zero);
    final parentBox = context.findRenderObject() as RenderBox?;
    if (parentBox == null || !parentBox.hasSize) return;
    
    final parentPosition = parentBox.localToGlobal(Offset.zero);
    
    final newLeft = position.dx - parentPosition.dx;
    final newWidth = renderBox.size.width;
    
    if (newLeft != _indicatorLeft || newWidth != _indicatorWidth || !_isInitialized) {
      setState(() {
        _indicatorLeft = newLeft;
        _indicatorWidth = newWidth;
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? const Color(0xFF3B82F6);
    final indicatorColor = widget.indicatorColor ?? activeColor;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.dividerColor,
          ),
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: widget.padding,
            child: Row(
              children: List.generate(widget.tabs.length, (index) {
                final isSelected = widget.selectedIndex == index;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < widget.tabs.length - 1 ? widget.spacing : 0,
                  ),
                  child: _AnimatedTab(
                    key: _tabKeys[index],
                    label: widget.tabs[index],
                    isSelected: isSelected,
                    activeColor: activeColor,
                    onTap: () => widget.onTabChanged(index),
                  ),
                );
              }),
            ),
          ),
          if (widget.showIndicator && 
              widget.indicatorStyle == TabIndicatorStyle.underline && 
              _isInitialized)
            Positioned(
              left: _indicatorLeft,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: _indicatorWidth,
                height: 2,
                alignment: Alignment.center,
                child: Container(
                  width: 24,
                  height: 2,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _AnimatedTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_AnimatedTab> createState() => _AnimatedTabState();
}

class _AnimatedTabState extends State<_AnimatedTab> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isHovered;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.activeColor.withValues(alpha: 0.12)
                : _isHovered
                    ? widget.activeColor.withValues(alpha: 0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          transformAlignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              color: widget.isSelected
                  ? widget.activeColor
                  : _isHovered
                      ? widget.activeColor.withValues(alpha: 0.8)
                      : context.hintColor,
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class SmoothTabSwitcher extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const SmoothTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SmoothTabSwitcher> createState() => _SmoothTabSwitcherState();
}

class _SmoothTabSwitcherState extends State<SmoothTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _previousIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.03, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(SmoothTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = widget.selectedIndex;
      _slideAnimation = Tween<Offset>(
        begin: Offset(widget.selectedIndex > _previousIndex ? 0.03 : -0.03, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: IndexedStack(
              index: widget.selectedIndex,
              children: widget.children,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedTabContent extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> children;
  final Duration duration;

  const AnimatedTabContent({
    super.key,
    required this.selectedIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<AnimatedTabContent> createState() => _AnimatedTabContentState();
}

class _AnimatedTabContentState extends State<AnimatedTabContent> {
  int _displayedIndex = 0;

  @override
  void initState() {
    super.initState();
    _displayedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(AnimatedTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      setState(() {
        _displayedIndex = widget.selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_displayedIndex),
        child: widget.children[_displayedIndex],
      ),
    );
  }
}

enum TabIndicatorStyle {
  underline,
  pill,
  dot,
}
