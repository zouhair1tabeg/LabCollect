import 'package:flutter/material.dart';
import '../../core/theme/liquid_glass_theme.dart';

/// Glass-styled step progress bar with animated gradient segments.
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Step label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ÉTAPE ${currentStep + 1} / $totalSteps',
                style: LiquidGlass.label().copyWith(
                  color: LiquidGlass.accentBlue,
                ),
              ),
              Text(
                '${((currentStep + 1) / totalSteps * 100).round()}%',
                style: LiquidGlass.bodySecondary(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Segmented progress bar
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              final isCurrent = index == currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: 3,
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? 3 : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              LiquidGlass.accentBlue,
                              LiquidGlass.accentViolet,
                            ],
                          )
                        : null,
                    color: isActive
                        ? null
                        : Colors.white.withValues(alpha: 0.15),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: LiquidGlass.accentBlue.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
