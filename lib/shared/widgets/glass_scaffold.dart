import 'package:flutter/material.dart';
import '../../core/theme/animated_background.dart';
import '../../core/theme/liquid_glass_theme.dart';

/// Drop-in Scaffold replacement with animated glass background.
/// Provides a transparent AppBar over animated orbs.
class GlassScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const GlassScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.bottom,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        floatingActionButton: floatingActionButton,
        appBar: showAppBar
            ? AppBar(
                title: title != null
                    ? Text(title!, style: LiquidGlass.heading(fontSize: 20))
                    : null,
                leading: leading,
                actions: actions,
                bottom: bottom,
              )
            : null,
        body: SafeArea(child: body),
      ),
    );
  }
}
