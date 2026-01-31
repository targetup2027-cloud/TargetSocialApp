import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UniverseButtonIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const UniverseButtonIcon({
    super.key,
    this.size = 56,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/b.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}