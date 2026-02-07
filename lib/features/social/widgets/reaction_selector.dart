import 'package:flutter/material.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/motion/motion_system.dart';
import '../models/post_data.dart';

class ReactionSelector extends StatefulWidget {
  final Function(ReactionType) onReactionSelected;
  final ReactionType? currentReaction;

  const ReactionSelector({
    super.key,
    required this.onReactionSelected,
    this.currentReaction,
  });

  @override
  State<ReactionSelector> createState() => _ReactionSelectorState();
}

class _ReactionSelectorState extends State<ReactionSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.purposeful,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: context.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode 
                ? Colors.black.withValues(alpha: 0.5) 
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ReactionType.values.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final reaction = PostReaction(type: type, count: 0);
          final isSelected = widget.currentReaction == type;

          return StaggeredFadeSlide(
            animation: _controller,
            index: index,
            staggerDelay: const Duration(milliseconds: 40),
            child: Padding(
              padding: EdgeInsets.only(
                right: index < ReactionType.values.length - 1 ? 6 : 0,
              ),
              child: TapScaleButton(
                onTap: () {
                  widget.onReactionSelected(type);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(reaction.color),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(reaction.color).withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      reaction.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

void showReactionSelector({
  required BuildContext context,
  required Function(ReactionType) onReactionSelected,
  ReactionType? currentReaction,
}) {
  showMotionModal(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: ReactionSelector(
            onReactionSelected: onReactionSelected,
            currentReaction: currentReaction,
          ),
        ),
      );
    },
  );
}
