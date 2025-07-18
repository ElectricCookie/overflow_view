import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';
import 'overflow_controls.dart';

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
          OverflowControls(
            mainAxisAlignment: _mainAxisAlignment,
            crossAxisAlignment: _crossAxisAlignment,
            axis: _axis,
            spacing: _spacing,
            expandFirstChild: false,
            fixed: _fixed,
            count: _count,
            width: _width,
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
            onAxisChanged: (value) {
              setState(() {
                _axis = value;
              });
            },
            onSpacingChanged: (value) {
              setState(() {
                _spacing = value;
              });
            },
            onFixedChanged: (value) {
              setState(() {
                _fixed = value;
              });
            },
            onCountChanged: (value) {
              setState(() {
                _count = value;
              });
            },
            onWidthChanged: (value) {
              setState(() {
                _width = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
