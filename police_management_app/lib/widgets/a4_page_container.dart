import 'package:flutter/material.dart';

class A4PageContainer extends StatelessWidget {
  final Widget child;
  final bool readOnly;

  const A4PageContainer({
    super.key,
    required this.child,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 900, // Fixed desktop-like width
            child: AspectRatio(
              aspectRatio: 1 / 1.414,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFCFA),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: AbsorbPointer(
                      absorbing: readOnly,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
