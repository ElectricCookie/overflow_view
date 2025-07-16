import 'package:flutter/material.dart';
import 'package:overflow_view/src/rendering/overflow_view.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

/// Signature for a builder that creates an overflow indicator when there is not
/// enough space to display all the children of an [OverflowView].
typedef OverflowIndicatorBuilder = Widget Function(
  BuildContext context,
  int remainingItemCount,
);

/// A widget that displays its children in a one-dimensional array until there
/// is no more room. If all the children don't fit in the available space, it
/// displays an indicator at the end.
///
/// All chidren will have the same size as the first child.
class OverflowView extends MultiChildRenderObjectWidget {
  /// Creates an [OverflowView].
  ///
  /// All children will have the same size has the first child.
  ///
  /// The [spacing] argument must also be positive and finite.
  OverflowView({
    Key? key,
    required OverflowIndicatorBuilder builder,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Axis direction = Axis.horizontal,
    required List<Widget> children,
    bool expandFirstChild = false,
    double spacing = 0,
  }) : this._all(
          key: key,
          builder: builder,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          direction: direction,
          children: children,
          spacing: spacing,
          expandFirstChild: expandFirstChild,
          layoutBehavior: OverflowViewLayoutBehavior.fixed,
        );

  /// Creates a flexible [OverflowView].
  ///
  /// All children can have their own size.
  ///
  /// The [spacing] argument must also be positive and finite.
  OverflowView.flexible({
    Key? key,
    required OverflowIndicatorBuilder builder,
    Axis direction = Axis.horizontal,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    required List<Widget> children,
    bool expandFirstChild = false,
    double spacing = 0,
  }) : this._all(
          key: key,
          builder: builder,
          direction: direction,
          mainAxisAlignment: mainAxisAlignment,
          children: children,
          spacing: spacing,
          expandFirstChild: expandFirstChild,
          crossAxisAlignment: crossAxisAlignment,
          layoutBehavior: OverflowViewLayoutBehavior.flexible,
        );

  OverflowView._all({
    Key? key,
    required OverflowIndicatorBuilder builder,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.direction = Axis.horizontal,
    required List<Widget> children,
    this.spacing = 0,
    this.expandFirstChild = false,
    required OverflowViewLayoutBehavior layoutBehavior,
  })  : assert(spacing > double.negativeInfinity && spacing < double.infinity),
        _layoutBehavior = layoutBehavior,
        super(
          key: key,
          children: [
            ...children,
            ValueLayoutBuilder<int>(
              builder: (context, constraints) {
                return builder(context, constraints.value);
              },
            ),
          ],
        );

  /// The direction to use as the main axis.
  ///
  /// For example, if [direction] is [Axis.horizontal], the default, the
  /// children are placed adjacent to one another as in a [Row].
  final Axis direction;

  /// The amount of space between successive children.
  final double spacing;

  final OverflowViewLayoutBehavior _layoutBehavior;

  /// The alignment of the children along the main axis.
  ///
  /// For example, if [mainAxisAlignment] is [MainAxisAlignment.end], the
  /// children are placed at the end of the main axis.
  final MainAxisAlignment mainAxisAlignment;

  /// The alignment of the children along the cross axis.
  ///
  /// For example, if [crossAxisAlignment] is [CrossAxisAlignment.end], the
  /// children are placed at the end of the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the first child should be expanded to fill the available space.
  final bool expandFirstChild;

  @override
  _OverflowViewElement createElement() {
    return _OverflowViewElement(this);
  }

  @override
  RenderOverflowView createRenderObject(BuildContext context) {
    return RenderOverflowView(
      expandFirstChild: expandFirstChild,
      direction: direction,
      spacing: spacing,
      layoutBehavior: _layoutBehavior,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowView renderObject,
  ) {
    renderObject
      ..direction = direction
      ..spacing = spacing
      ..layoutBehavior = _layoutBehavior
      ..mainAxisAlignment = mainAxisAlignment
      ..expandFirstChild = expandFirstChild
      ..crossAxisAlignment = crossAxisAlignment;
  }
}

class _OverflowViewElement extends MultiChildRenderObjectElement {
  _OverflowViewElement(OverflowView widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    children.forEach((element) {
      if (element.renderObject?.isOnstage == true) {
        visitor(element);
      }
    });
  }
}
