import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../core/utils/formatters.dart';

class EarningsChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final double maxValue;

  const EarningsChart({
    super.key,
    required this.data,
    required this.labels,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных',
          style: TextStyle(color: AppColors.textHint),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(data.length, (index) {
              final value = data[index];
              final heightFactor =
                  maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (value > 0)
                        Text(
                          Formatters.currency(value),
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 2),
                      FractionallySizedBox(
                        heightFactor: heightFactor == 0 ? 0.02 : heightFactor,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: value > 0
                                ? AppColors.primaryGradient
                                : const LinearGradient(
                                    colors: [
                                      AppColors.border,
                                      AppColors.border
                                    ],
                                  ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: labels
              .map((label) => Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
