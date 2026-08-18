// lib/widgets/base_form/base_form_layout.dart
// Scaffold + constrained scroll shell for standalone data-entry forms.
// Do NOT use for Forms-tile official forms (Form I-V, Form 2-A, CommonForm, etc.).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'base_form_styles.dart';

/// Centers and width-limits scrollable form sections.
class BaseFormContent extends StatelessWidget {
  const BaseFormContent({
    super.key,
    required this.child,
    this.maxWidth = BaseFormStyles.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  static Widget scrollSections({
    required List<Widget> children,
    double maxWidth = BaseFormStyles.maxContentWidth,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
  }) {
    return BaseFormContent(
      maxWidth: maxWidth,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Full-page layout for standalone module entry screens.
class BaseFormLayout extends StatelessWidget {
  const BaseFormLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.children = const [],
    this.onSubmit,
    this.submitLabel = 'Submit',
    this.scrollController,
    this.onScrollNotification,
    this.header,
    this.bottomBar,
    this.embeddedBody,
    this.appBarActions,
    this.backgroundColor = BaseFormStyles.pageBg,
    this.darkAppBar = false,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 16, 16, 100),
    this.maxWidth = BaseFormStyles.maxContentWidth,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final ScrollController? scrollController;
  final bool Function(ScrollNotification)? onScrollNotification;
  final Widget? header;
  final Widget? bottomBar;
  final Widget? embeddedBody;
  final List<Widget>? appBarActions;
  final Color backgroundColor;
  final bool darkAppBar;
  final EdgeInsets contentPadding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final appBarFg = darkAppBar ? Colors.white : AppColors.navyDark;
    final appBarBg = darkAppBar ? AppColors.navyDark : Colors.white;

    Widget body;
    if (embeddedBody != null) {
      body = embeddedBody!;
    } else if (children.isEmpty) {
      body = const SizedBox.shrink();
    } else {
      Widget scroll = SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: contentPadding,
        child: BaseFormContent(
          maxWidth: maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      );
      if (onScrollNotification != null) {
        scroll = NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: scroll,
        );
      }
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          Expanded(child: scroll),
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: darkAppBar ? 0 : 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: appBarFg, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: subtitle == null
            ? Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: appBarFg,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: appBarFg,
                    ),
                  ),
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: darkAppBar
                          ? BaseFormStyles.accent
                          : AppColors.navyMid,
                    ),
                  ),
                ],
              ),
        actions: appBarActions,
      ),
      body: body,
      bottomNavigationBar: bottomBar ?? _defaultSubmitBar(context),
    );
  }

  Widget? _defaultSubmitBar(BuildContext context) {
    if (onSubmit == null) return null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          8,
          AppSpacing.lg,
          12,
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyMid,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Text(
              submitLabel,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
