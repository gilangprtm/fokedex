import 'package:flutter/material.dart';

class MahasTabBar extends StatelessWidget {
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final Color? labelColor;

  const MahasTabBar({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          tabs: tabs,
          labelColor: labelColor,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            children: tabViews,
          ),
        ),
      ],
    );
  }
}
