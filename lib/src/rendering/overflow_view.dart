import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

enum OverflowViewLayoutBehavior {
  fixed,
  flexible,
  expandFirstFlexible,
}

/// Parent data for use with [RenderOverflowView].
class OverflowViewParentData extends ContainerBoxParentData<RenderBox> {
  bool? offstage;
}

class RenderOverflowView extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, OverflowViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, OverflowViewParentData> {
  MainAxisAlignment _mainAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  Axis _direction;
  double _spacing;
  OverflowViewLayoutBehavior _layoutBehavior;

  bool _isHorizontal;

  bool _hasOverflow = false;
  RenderOverflowView({
    List<RenderBox>? children,
    required Axis direction,
    required double spacing,
    required OverflowViewLayoutBehavior layoutBehavior,
    required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
  })  : assert(
          mainAxisAlignment != MainAxisAlignment.spaceBetween &&
              mainAxisAlignment != MainAxisAlignment.spaceAround &&
              mainAxisAlignment != MainAxisAlignment.spaceEvenly,
          "mainAxisAlignment must not be spaceBetween, spaceAround or spaceEvenly (current not supported)",
        ),
        assert(
          crossAxisAlignment != CrossAxisAlignment.baseline && crossAxisAlignment != CrossAxisAlignment.stretch,
          "crossAxisAlignment must not be baseline or stretch (current not supported)",
        ),
        _direction = direction,
        _spacing = spacing,
        _mainAxisAlignment = mainAxisAlignment,
        _layoutBehavior = layoutBehavior,
        _crossAxisAlignment = crossAxisAlignment,
        _isHorizontal = direction == Axis.horizontal {
    addAll(children);
  }
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;

  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      _isHorizontal = direction == Axis.horizontal;
      markNeedsLayout();
    }
  }

  OverflowViewLayoutBehavior get layoutBehavior => _layoutBehavior;

  set layoutBehavior(OverflowViewLayoutBehavior value) {
    if (_layoutBehavior != value) {
      _layoutBehavior = value;
      markNeedsLayout();
    }
  }

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment != value) {
      _mainAxisAlignment = value;
      markNeedsLayout();
    }
  }

  double get spacing => _spacing;
  set spacing(double value) {
    assert(value > double.negativeInfinity && value < double.infinity);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    visitOnlyOnStageChildren((renderObject) {
      final RenderBox child = renderObject as RenderBox;
      final OverflowViewParentData childParentData = child.parentData as OverflowViewParentData;
      result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
    });

    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void paintChild(RenderObject child) {
      final OverflowViewParentData childParentData = child.parentData as OverflowViewParentData;
      if (childParentData.offstage == false) {
        context.paintChild(child, childParentData.offset + offset);
      } else {
        // We paint it outside the box.
        context.paintChild(child, size.bottomRight(Offset.zero));
      }
    }

    void defaultPaint(PaintingContext context, Offset offset) {
      visitOnlyOnStageChildren(paintChild);
    }

    if (_hasOverflow) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: Clip.hardEdge,
      );
    } else {
      defaultPaint(context, offset);
    }
  }

  void _performFixedLayout() {
    double availableExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

    // First we retrieve the size of all the children.
    final children = _layoutChildrenSizes();

    // Needed to calculate the cross axis alignment later
    double maxCrossSize = 0;

    double maxMainSize = 0;

    // Calculate the total size needed for all children (excluding overflow indicator)

    for (final child in children) {
      double childCrossSize = _getCrossSize(child);
      maxCrossSize = math.max(maxCrossSize, childCrossSize);
      maxMainSize = math.max(maxMainSize, _getMainSize(child));
    }

    // Add spacing between children

    // Determine how many children can fit
    int fittingChildren = 0;
    double filledExtent = 0;
    bool showOverflowIndicator = false;

    for (final child in children) {
      // Check if this child would fit
      if (filledExtent + maxMainSize + (fittingChildren > 0 ? spacing : 0) <= availableExtent) {
        final childParentData = child.parentData as OverflowViewParentData;
        childParentData.offstage = false;
        filledExtent += maxMainSize + (fittingChildren > 0 ? spacing : 0);
        fittingChildren++;
      } else {
        showOverflowIndicator = true;
        final childParentData = child.parentData as OverflowViewParentData;
        childParentData.offstage = true;
      }
    }

    final renderedChildren = children.where((child) => child.isOnstage).toList();

    if (showOverflowIndicator) {
      // We need to place the overflow indicator.
      final RenderBox overflowIndicator = lastChild!;
      BoxValueConstraints<int> overflowIndicatorConstraints = BoxValueConstraints<int>(
        value: childCount - fittingChildren - 1,
        constraints: _childConstraints,
      );

      overflowIndicator.layout(
        overflowIndicatorConstraints,
        parentUsesSize: true,
      );

      final OverflowViewParentData overflowIndicatorParentData = overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offstage = false;

      double indicatorSize = _getMainSize(overflowIndicator);
      filledExtent += indicatorSize;

      // Remove children until we can fit the overflow indicator
      while (filledExtent + (fittingChildren > 0 ? spacing : 0) > availableExtent) {
        final RenderBox lastChild = renderedChildren.last;
        final OverflowViewParentData lastChildParentData = lastChild.parentData as OverflowViewParentData;
        lastChildParentData.offstage = true;

        renderedChildren.removeLast();
        fittingChildren--;
        final freed = _getMainSize(lastChild);
        filledExtent -= freed + (fittingChildren > 0 ? spacing : 0);
      }

      // Now that we know the final count of fitting children we
      // layout again to pass the correct count to the overflow indicator.
      overflowIndicatorConstraints = BoxValueConstraints<int>(
        value: childCount - fittingChildren - 1,
        constraints: _childConstraints,
      );

      overflowIndicator.layout(
        overflowIndicatorConstraints,
        parentUsesSize: true,
      );

      renderedChildren.add(overflowIndicator);
      maxCrossSize = math.max(maxCrossSize, _getCrossSize(overflowIndicator));
    }

    // Calculate alignment offset
    final double alignmentOffset = _calculateMainAxisAlignmentOffset(filledExtent, availableExtent);

    // Position all rendered children with uniform spacing
    double offset = alignmentOffset;
    for (final child in renderedChildren) {
      final childParentData = child.parentData as OverflowViewParentData;
      final double childCrossSize = _getCrossSize(child);

      double childCrossOffset = 0;
      if (crossAxisAlignment == CrossAxisAlignment.start) {
        childCrossOffset = 0;
      } else if (crossAxisAlignment == CrossAxisAlignment.end) {
        childCrossOffset = maxCrossSize - childCrossSize;
      } else if (crossAxisAlignment == CrossAxisAlignment.center) {
        childCrossOffset = (maxCrossSize - childCrossSize) / 2;
      }

      if (_isHorizontal) {
        childParentData.offset = Offset(offset, childCrossOffset);
      } else {
        childParentData.offset = Offset(childCrossOffset, offset);
      }

      offset += maxMainSize + spacing;
    }

    Size idealSize;

    double trailingSpace = availableExtent - filledExtent;
    if (_isHorizontal) {
      idealSize = Size(offset - spacing + trailingSpace, maxCrossSize);
    } else {
      idealSize = Size(maxCrossSize, offset - spacing + trailingSpace);
    }

    size = constraints.constrain(idealSize);
  }

  @override
  void performLayout() {
    _hasOverflow = false;
    assert(firstChild != null);
    resetOffstage();
    if (layoutBehavior == OverflowViewLayoutBehavior.fixed) {
      _performFixedLayout();
    } else {
      _performFlexibleLayout();
    }
  }

  void resetOffstage() {
    visitChildren((child) {
      final OverflowViewParentData childParentData = child.parentData as OverflowViewParentData;
      childParentData.offstage = null;
    });
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! OverflowViewParentData) child.parentData = OverflowViewParentData();
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitOnlyOnStageChildren(visitor);
  }

  void visitOnlyOnStageChildren(RenderObjectVisitor visitor) {
    visitChildren((child) {
      if (child.isOnstage) {
        visitor(child);
      }
    });
  }

  List<RenderBox> _layoutChildrenSizes() {
    RenderBox child = firstChild!;

    final List<RenderBox> children = <RenderBox>[];

    while (child != lastChild) {
      final childParentData = child.parentData as OverflowViewParentData;
      child.layout(_childConstraints, parentUsesSize: true);
      children.add(child);
      child = childParentData.nextSibling!;
    }

    return children;
  }

  double _calculateMainAxisAlignmentOffset(double totalChildrenSize, double availableSize) {
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        return 0.0;
      case MainAxisAlignment.end:
        return availableSize - totalChildrenSize;
      case MainAxisAlignment.center:
        return (availableSize - totalChildrenSize) / 2.0;
      default:
        return 0.0;
    }
  }

  BoxConstraints get _childConstraints {
    final double maxCrossExtent = _isHorizontal ? constraints.maxHeight : constraints.maxWidth;
    return _isHorizontal
        ? BoxConstraints.loose(Size(double.infinity, maxCrossExtent))
        : BoxConstraints.loose(Size(maxCrossExtent, double.infinity));
  }

  double _getCrossSize(RenderBox child) {
    switch (_direction) {
      case Axis.horizontal:
        return child.size.height;
      case Axis.vertical:
        return child.size.width;
    }
  }

  double _getMainSize(RenderBox child) {
    switch (_direction) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  void _performFlexibleLayout() {
    double availableExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

    bool showOverflowIndicator = false;

    // |_______| availableExtent
    // □ □ □ □ □ □
    //           ^overflowing child
    // <-------> fitting children (count)

    // First we retrieve the size of all the children.
    final children = _layoutChildrenSizes();

    // Needed to calculate the cross axis alignment later
    double maxCrossSize = 0;

    // Keep track of the total size of the children that are already on stage
    double filledExtent = 0;

    int fittingChildren = 0;

    for (final child in children) {
      double childMainSize = _getMainSize(child);
      double childCrossSize = _getCrossSize(child);
      maxCrossSize = math.max(maxCrossSize, childCrossSize);

      final childParentData = child.parentData as OverflowViewParentData;

      // Check if the filled space is less than the available extent.
      if (filledExtent + childMainSize + _spacingExtent(fittingChildren) <= availableExtent) {
        childParentData.offstage = false;
        filledExtent += childMainSize;
        fittingChildren++;
      } else {
        showOverflowIndicator = true;
        childParentData.offstage = true;
        break;
      }
    }

    final renderedChildren = children.where((child) => child.isOnstage).toList();

    if (showOverflowIndicator) {
      // We need to place the overflow indicator.
      // We start by determining its size, by passing the value of already
      // overflowing children.
      final RenderBox overflowIndicator = lastChild!;
      BoxValueConstraints<int> overflowIndicatorConstraints = BoxValueConstraints<int>(
        value: childCount - fittingChildren - 1,
        constraints: _childConstraints,
      );

      overflowIndicator.layout(
        overflowIndicatorConstraints,
        parentUsesSize: true,
      );

      final OverflowViewParentData overflowIndicatorParentData = overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offstage = false;

      double indicatorSize = _getMainSize(overflowIndicator);
      filledExtent += indicatorSize;

      // Remove children until we can fit the overflow indicator fits.

      while (filledExtent + _spacingExtent(fittingChildren + 1) > availableExtent) {
        final RenderBox lastChild = renderedChildren.last;

        final OverflowViewParentData lastChildParentData = lastChild.parentData as OverflowViewParentData;
        lastChildParentData.offstage = true;

        renderedChildren.removeLast();
        fittingChildren--;
        final freed = _getMainSize(lastChild);

        filledExtent -= freed;
      }

      // Now that we know the final count of fitting children we
      // layout again to pass the correct count to the overflow indicator.

      overflowIndicatorConstraints = BoxValueConstraints<int>(
        value: childCount - fittingChildren - 1,
        constraints: _childConstraints,
      );

      overflowIndicator.layout(
        overflowIndicatorConstraints,
        parentUsesSize: true,
      );

      renderedChildren.add(overflowIndicator);

      maxCrossSize = math.max(maxCrossSize, _getCrossSize(overflowIndicator));
    }

    double remainder = availableExtent - filledExtent - _spacingExtent(renderedChildren.length);

    // We increase the size of the first child to fill the leading space.
    // we consume the remainder space.
    if (layoutBehavior == OverflowViewLayoutBehavior.expandFirstFlexible) {
      double childMainSize = _getMainSize(children.first);

      firstChild!.layout(
        BoxConstraints.tight(Size(childMainSize + remainder, maxCrossSize)),
        parentUsesSize: true,
      );

      remainder = 0;
    }

    // We fill the extent based on the offset
    double offset = 0;

    // If we try to center the children we start with half the remaining space.
    if (mainAxisAlignment == MainAxisAlignment.center) {
      offset = remainder / 2;
    }

    // If we try to align the children at the end we start with the remaining space.
    if (mainAxisAlignment == MainAxisAlignment.end) {
      offset = remainder;
    }

    for (final child in renderedChildren) {
      final childParentData = child.parentData as OverflowViewParentData;

      final double childCrossSize = _getCrossSize(child);

      double childCrossOffset = 0;

      if (crossAxisAlignment == CrossAxisAlignment.start) {
        childCrossOffset = 0;
      } else if (crossAxisAlignment == CrossAxisAlignment.end) {
        childCrossOffset = maxCrossSize - childCrossSize;
      } else if (crossAxisAlignment == CrossAxisAlignment.center) {
        childCrossOffset = (maxCrossSize - childCrossSize) / 2;
      }

      if (_isHorizontal) {
        childParentData.offset = Offset(offset, childCrossOffset);
      } else {
        childParentData.offset = Offset(childCrossOffset, offset);
      }

      offset += _getMainSize(child) + spacing;
    }

    final trailingSpace = availableExtent - filledExtent;

    Size idealSize;
    if (_isHorizontal) {
      idealSize = Size(offset + trailingSpace, maxCrossSize);
    } else {
      idealSize = Size(maxCrossSize, offset + trailingSpace);
    }

    size = constraints.constrain(idealSize);
  }

  double _spacingExtent(int childCount) {
    if (childCount == 0) {
      return 0;
    }
    return spacing * (childCount - 1);
  }
}

extension RenderObjectExtensions on RenderObject {
  bool get isOnstage => (parentData as OverflowViewParentData).offstage == false;
}
