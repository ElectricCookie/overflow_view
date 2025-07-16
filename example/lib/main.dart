import 'dart:math';

import 'package:example/avatars.dart';
import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overflow View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Overflow View Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.start;
  CrossAxisAlignment _crossAxisAlignment = CrossAxisAlignment.start;
  bool _expandFirstChild = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avatars',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Avatars(),
                Divider(),
                Text('Command Bar', style: TextStyle(fontSize: 20)),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MainAxisAlignment'),
                        SizedBox(height: 10),
                        SegmentedButton<MainAxisAlignment>(
                          segments: [
                            ButtonSegment(value: MainAxisAlignment.start, label: Text('Start')),
                            ButtonSegment(value: MainAxisAlignment.center, label: Text('Center')),
                            ButtonSegment(value: MainAxisAlignment.end, label: Text('End')),
                          ],
                          selected: {_mainAxisAlignment},
                          onSelectionChanged: (value) {
                            setState(() {
                              _mainAxisAlignment = value.first;
                            });
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CrossAxisAlignment'),
                        SizedBox(height: 10),
                        SegmentedButton<CrossAxisAlignment>(
                          segments: [
                            ButtonSegment(value: CrossAxisAlignment.start, label: Text('Start')),
                            ButtonSegment(value: CrossAxisAlignment.center, label: Text('Center')),
                            ButtonSegment(value: CrossAxisAlignment.end, label: Text('End')),
                          ],
                          selected: {_crossAxisAlignment},
                          onSelectionChanged: (value) {
                            setState(() {
                              _crossAxisAlignment = value.first;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Switch(
                          value: _expandFirstChild,
                          onChanged: (value) {
                            setState(() {
                              _expandFirstChild = value;
                            });
                          },
                        ),
                        Text('Expand first child'),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  child: Card(
                    child: CommandBar(
                      mainAxisAlignment: _mainAxisAlignment,
                      crossAxisAlignment: _crossAxisAlignment,
                      expandFirstChild: _expandFirstChild,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class CommandBar extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool expandFirstChild;

  const CommandBar({
    Key? key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.expandFirstChild = false,
  }) : super(key: key);

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

    return OverflowView.flexible(
      spacing: 4,
      expandFirstChild: expandFirstChild,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Menu title'),
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
    Key? key,
    required this.data,
  }) : super(key: key);

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
