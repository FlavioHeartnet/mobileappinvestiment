import 'dart:ui';

import 'package:flutter/cupertino.dart';

class GlassNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;

  const GlassNavigationBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final Color bg = CupertinoDynamicColor.resolve(
      const CupertinoDynamicColor.withBrightness(
        color: Color(0x99FFFFFF),
        darkColor: Color(0x9918181C),
      ),
      context,
    );
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: CupertinoNavigationBar(
          backgroundColor: bg,
          border: const Border(bottom: BorderSide(color: Color(0x1FFFFFFF))),
          middle: Text(title),
          leading: leading,
          trailing: trailing,
        ),
      ),
    );
  }

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}
