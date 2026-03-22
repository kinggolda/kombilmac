import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: child,
    );
  }
}

class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 12,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

