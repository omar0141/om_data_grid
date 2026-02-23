import 'package:flutter/material.dart';

class OmMaybeExpanded extends StatelessWidget {
  final bool expand;
  final Widget child;

  const OmMaybeExpanded({super.key, required this.expand, required this.child});

  @override
  Widget build(BuildContext context) {
    if (expand) {
      return Expanded(child: child);
    }
    return child;
  }
}

class OmMaybeIntrinsicHeight extends StatelessWidget {
  final bool intrinsic;
  final Widget child;

  const OmMaybeIntrinsicHeight({
    super.key,
    required this.intrinsic,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (intrinsic) {
      return IntrinsicHeight(child: child);
    }
    return child;
  }
}
