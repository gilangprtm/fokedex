import 'package:flutter/material.dart';

class MahasGrid extends StatelessWidget {
  final List<Widget> items;
  final int crossAxisCount;
  final double childAspectRatio;
  final Axis scrollDirection;

  const MahasGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      scrollDirection: scrollDirection,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}
