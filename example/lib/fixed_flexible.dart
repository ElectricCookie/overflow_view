import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

class FixedVsFlexibleDemo extends StatefulWidget {
  const FixedVsFlexibleDemo({super.key});

  @override
  State<FixedVsFlexibleDemo> createState() => _FixedVsFlexibleDemoState();
}

class _FixedVsFlexibleDemoState extends State<FixedVsFlexibleDemo> {
  bool _fixed = false;
  int _count = 10;
  double _width = 300;
  double _spacing = 8.0;
  Axis _axis = Axis.horizontal;
  MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.start;
  CrossAxisAlignment _crossAxisAlignment = CrossAxisAlignment.start;

  Widget _buildOverflow(BuildContext context, int count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 50,
      width: 50,
      child: Center(child: Text("Ov: $count")),
    );
  }

  List<Widget> _buildChildren(BuildContext context, int count) {
    return List.generate(
      count,
      (index) => Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        height: index % 3 * 10 + 50,
        width: 50 + index % 3 * 10,
        child: Center(child: Text("Child: $index")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 300,
            width: _width,
            child: Center(
              child: OverflowView(
                mainAxisAlignment: _mainAxisAlignment,
                crossAxisAlignment: _crossAxisAlignment,
                builder: _buildOverflow,
                direction: _axis,
                layoutBehavior: _fixed ? OverflowViewLayoutBehavior.fixed : OverflowViewLayoutBehavior.flexible,
                spacing: _spacing,
                children: _buildChildren(context, _count),
              ),
            ),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Count: $_count"),
                  SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: _count.toDouble(),
                      max: 20,
                      min: 1,
                      onChanged: (value) {
                        setState(() {
                          _count = value.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Width: ${_width.toInt()}"),
                  SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: _width,
                      max: 500,
                      min: 100,
                      onChanged: (value) {
                        setState(() {
                          _width = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Spacing: ${_spacing.toInt()}"),
                  SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: _spacing,
                      max: 50,
                      min: -10,
                      onChanged: (value) {
                        setState(() {
                          _spacing = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Fixed"),
              Switch(
                  value: _fixed,
                  onChanged: (value) {
                    setState(() {
                      _fixed = value;
                    });
                  }),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Axis:"),
                  SizedBox(
                    width: 8,
                  ),
                  DropdownButton<Axis>(
                    value: _axis,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _axis = value;
                        });
                      }
                    },
                    items: Axis.values.map((axis) {
                      return DropdownMenuItem<Axis>(
                        value: axis,
                        child: Text(axis == Axis.horizontal ? "Horizontal" : "Vertical"),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("MainAxisAlignment:"),
                  SizedBox(
                    width: 8,
                  ),
                  DropdownButton<MainAxisAlignment>(
                    value: _mainAxisAlignment,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _mainAxisAlignment = value;
                        });
                      }
                    },
                    items: MainAxisAlignment.values.map((alignment) {
                      return DropdownMenuItem<MainAxisAlignment>(
                        value: alignment,
                        child: Text(alignment.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("CrossAxisAlignment:"),
                  SizedBox(
                    width: 8,
                  ),
                  DropdownButton<CrossAxisAlignment>(
                    value: _crossAxisAlignment,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _crossAxisAlignment = value;
                        });
                      }
                    },
                    items: CrossAxisAlignment.values.map((alignment) {
                      return DropdownMenuItem<CrossAxisAlignment>(
                        value: alignment,
                        child: Text(alignment.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
