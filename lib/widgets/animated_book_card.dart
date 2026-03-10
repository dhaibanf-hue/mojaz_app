import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../models/book.dart';
import '../screens/book_detail_screen.dart';

/// Reusable widget that wraps any book card content with a Container Transform
/// animation that "opens" the card into the BookDetailScreen.
class AnimatedBookCard extends StatelessWidget {
  final Book book;
  final String? heroTag;
  final Widget Function(BuildContext context, VoidCallback openContainer) cardBuilder;
  final Color? closedColor;
  final double closedElevation;
  final ShapeBorder closedShape;

  const AnimatedBookCard({
    super.key,
    required this.book,
    required this.cardBuilder,
    this.heroTag,
    this.closedColor,
    this.closedElevation = 0,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 480),
      openBuilder: (context, _) => BookDetailScreen(
        book: book,
        heroTag: heroTag,
      ),
      closedBuilder: cardBuilder,
      closedColor: closedColor ?? (isDark ? Colors.transparent : Colors.transparent),
      openColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      closedElevation: closedElevation,
      openElevation: 0,
      closedShape: closedShape,
      middleColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      transitionType: ContainerTransitionType.fadeThrough,
    );
  }
}
