import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final bool showValue;
  final int? totalReviews;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 16,
    this.showValue = true,
    this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxStars, (index) {
          final filled = index < rating.floor();
          final partial = !filled && index < rating;
          return Icon(
            filled
                ? Icons.star
                : partial
                    ? Icons.star_half
                    : Icons.star_border,
            color: AppColors.starFilled,
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          if (totalReviews != null) ...[
            const SizedBox(width: 2),
            Text(
              '($totalReviews)',
              style: TextStyle(
                fontSize: size * 0.75,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final void Function(double) onRatingChanged;
  final double size;

  const InteractiveStarRating({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() => _rating = index + 1.0);
            widget.onRatingChanged(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: AppColors.starFilled,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}
