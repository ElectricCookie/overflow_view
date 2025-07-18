import 'package:flutter/material.dart';

class OverflowControls extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Axis axis;
  final double spacing;
  final bool expandFirstChild;
  final bool fixed;
  final int count;
  final double width;
  final ValueChanged<MainAxisAlignment>? onMainAxisAlignmentChanged;
  final ValueChanged<CrossAxisAlignment>? onCrossAxisAlignmentChanged;
  final ValueChanged<Axis>? onAxisChanged;
  final ValueChanged<double>? onSpacingChanged;
  final ValueChanged<bool>? onExpandFirstChildChanged;
  final ValueChanged<bool>? onFixedChanged;
  final ValueChanged<int>? onCountChanged;
  final ValueChanged<double>? onWidthChanged;

  const OverflowControls({
    super.key,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.axis,
    required this.spacing,
    required this.expandFirstChild,
    required this.fixed,
    required this.count,
    required this.width,
    this.onMainAxisAlignmentChanged,
    this.onCrossAxisAlignmentChanged,
    this.onAxisChanged,
    this.onSpacingChanged,
    this.onExpandFirstChildChanged,
    this.onFixedChanged,
    this.onCountChanged,
    this.onWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (onCountChanged != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Count: $count"),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: count.toDouble(),
                      max: 20,
                      min: 1,
                      onChanged: (value) {
                        onCountChanged?.call(value.toInt());
                      },
                    ),
                  ),
                ],
              ),
            if (onWidthChanged != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Width: ${width.toInt()}"),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: width,
                      max: 500,
                      min: 100,
                      onChanged: onWidthChanged,
                    ),
                  ),
                ],
              ),
            if (onSpacingChanged != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Spacing: ${spacing.toInt()}"),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: spacing,
                      max: 50,
                      min: -10,
                      onChanged: onSpacingChanged,
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (onExpandFirstChildChanged != null || onFixedChanged != null)
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (onExpandFirstChildChanged != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: expandFirstChild,
                      onChanged: onExpandFirstChildChanged,
                    ),
                    Text('Expand first child'),
                  ],
                ),
              if (onFixedChanged != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Fixed"),
                    Switch(
                      value: fixed,
                      onChanged: onFixedChanged,
                    ),
                  ],
                ),
            ],
          ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (onAxisChanged != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Axis:"),
                  SizedBox(width: 8),
                  DropdownButton<Axis>(
                    value: axis,
                    onChanged: (value) {
                      if (value != null) {
                        onAxisChanged?.call(value);
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
            if (onMainAxisAlignmentChanged != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("MainAxisAlignment:"),
                  SizedBox(width: 8),
                  DropdownButton<MainAxisAlignment>(
                    value: mainAxisAlignment,
                    onChanged: (value) {
                      if (value != null) {
                        onMainAxisAlignmentChanged?.call(value);
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
            if (onCrossAxisAlignmentChanged != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("CrossAxisAlignment:"),
                  SizedBox(width: 8),
                  DropdownButton<CrossAxisAlignment>(
                    value: crossAxisAlignment,
                    onChanged: (value) {
                      if (value != null) {
                        onCrossAxisAlignmentChanged?.call(value);
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
    );
  }
}
