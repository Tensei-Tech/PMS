import 'package:flutter/material.dart';

class A4FittedBoxWrapper extends StatelessWidget {
  final Widget child;

  const A4FittedBoxWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 900,
        child: child,
      ),
    );
  }
}
