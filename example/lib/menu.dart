import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';
import 'overflow_controls.dart';

class MenuDemo extends StatefulWidget {
  const MenuDemo({super.key});

  @override
  _MenuDemoState createState() => _MenuDemoState();
}

class _MenuDemoState extends State<MenuDemo> {
  MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.start;
  CrossAxisAlignment _crossAxisAlignment = CrossAxisAlignment.center;
  bool _expandFirstChild = true;
  double _spacing = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: MenuBar(
                mainAxisAlignment: _mainAxisAlignment,
                crossAxisAlignment: _crossAxisAlignment,
                spacing: _spacing,
                expandFirstChild: _expandFirstChild,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        OverflowControls(
          mainAxisAlignment: _mainAxisAlignment,
          crossAxisAlignment: _crossAxisAlignment,
          axis: Axis.horizontal,
          spacing: _spacing,
          expandFirstChild: _expandFirstChild,
          fixed: false,
          count: 0,
          width: 0,
          onMainAxisAlignmentChanged: (value) {
            setState(() {
              _mainAxisAlignment = value;
            });
          },
          onCrossAxisAlignmentChanged: (value) {
            setState(() {
              _crossAxisAlignment = value;
            });
          },
          onSpacingChanged: (value) {
            setState(() {
              _spacing = value;
            });
          },
          onExpandFirstChildChanged: (value) {
            setState(() {
              _expandFirstChild = value;
            });
          },
        ),
      ],
    );
  }
}

class MenuBar extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool expandFirstChild;
  final double spacing;

  const MenuBar({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.expandFirstChild = false,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final List<MenuItemData> commands = <MenuItemData>[
      MenuItemData(id: 'a', label: 'File'),
      MenuItemData(id: 'b', icon: Icons.save, label: 'Save'),
      MenuItemData(id: 'c', label: 'Edit'),
      MenuItemData(id: 'd', label: 'View'),
      MenuItemData(id: 'e', icon: Icons.exit_to_app),
      MenuItemData(id: 'f', label: 'Long Command'),
      MenuItemData(id: 'f', label: 'Very Long Command'),
      MenuItemData(id: 'f', label: 'Very very Long Command'),
      MenuItemData(id: 'f', label: 'Help'),
    ];

    return OverflowView(
      spacing: spacing,
      layoutBehavior:
          expandFirstChild ? OverflowViewLayoutBehavior.expandFirstFlexible : OverflowViewLayoutBehavior.flexible,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Menu title',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...commands.map((e) => _MenuItem(data: e))
      ],
      builder: (context, remaining) {
        return PopupMenuButton<String>(
          icon: Icon(Icons.menu),
          itemBuilder: (context) {
            return commands
                .skip(commands.length - remaining)
                .map((e) => PopupMenuItem<String>(
                      value: e.id,
                      child: _MenuItem(data: e),
                    ))
                .toList();
          },
        );
      },
    );
  }
}

class MenuItemData {
  const MenuItemData({
    required this.id,
    this.label,
    this.icon,
  });

  final String id;
  final String? label;
  final IconData? icon;
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.data,
  });

  final MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Row(
        children: [
          if (data.icon != null) Icon(data.icon),
          if (data.icon != null && data.label != null) SizedBox(width: 8),
          if (data.label != null) Text(data.label!),
        ],
      ),
    );
  }
}
