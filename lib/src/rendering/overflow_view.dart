import 'package:flutter/rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

import 'dart:math' as math;

/// Parent data for use with [RenderOverflowView].
class OverflowViewParentData extends ContainerBoxParentData<RenderBox> {
  bool? offstage;
}

enum OverflowViewLayoutBehavior {
  fixed,
  flexible,
}

class RenderOverflowView extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, OverflowViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, OverflowViewParentData> {
  RenderOverflowView({
    List<RenderBox>? children,
    required Axis direction,
    required double spacing,
    required OverflowViewLayoutBehavior layoutBehavior,
    required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
    required bool expandFirstChild,
  })  : assert(spacing > double.negativeInfinity && spacing < double.infinity),
        _direction = direction,
        _spacing = spacing,
        _mainAxisAlignment = mainAxisAlignment,
        _layoutBehavior = layoutBehavior,
        _crossAxisAlignment = crossAxisAlignment,
        _expandFirstChild = expandFirstChild,
        _isHorizontal = direction == Axis.horizontal {
    addAll(children);
  }

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment != value) {
      _mainAxisAlignment = value;
      markNeedsLayout();
    }
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      _isHorizontal = direction == Axis.horizontal;
      markNeedsLayout();
    }
  }

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    assert(value > double.negativeInfinity && value < double.infinity);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  OverflowViewLayoutBehavior get layoutBehavior => _layoutBehavior;
  OverflowViewLayoutBehavior _layoutBehavior;
  set layoutBehavior(OverflowViewLayoutBehavior value) {
    if (_layoutBehavior != value) {
      _layoutBehavior = value;
      markNeedsLayout();
    }
  }

  bool get expandFirstChild => _expandFirstChild;
  bool _expandFirstChild;
  set expandFirstChild(bool value) {
    if (_expandFirstChild != value) {
      _expandFirstChild = value;
      markNeedsLayout();
    }
  }

  bool _isHorizontal;
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! OverflowViewParentData) child.parentData = OverflowViewParentData();
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

  bool _hasOverflow = false;

  @override
  void performLayout() {
    _hasOverflow = false;
    assert(firstChild != null);
    resetOffstage();
    if (layoutBehavior == OverflowViewLayoutBehavior.fixed) {
      performFixedLayout();
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

  void performFixedLayout() {
    RenderBox child = firstChild!;

    final BoxConstraints childConstraints = constraints.loosen();

    final double maxExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

    OverflowViewParentData childParentData = child.parentData as OverflowViewParentData;
    child.layout(childConstraints, parentUsesSize: true);
    final double childExtent = child.size.getMainExtent(direction);
    final double crossExtent = child.size.getCrossExtent(direction);
    final BoxConstraints otherChildConstraints = _isHorizontal
        ? childConstraints.tighten(width: childExtent, height: crossExtent)
        : childConstraints.tighten(height: childExtent, width: crossExtent);

    final double childStride = childExtent + spacing;

    int onstageCount = 0;
    final int count = childCount - 1;
    final double requestedExtent = childExtent * (childCount - 1) + spacing * (childCount - 2);
    final int renderedChildCount = requestedExtent <= maxExtent ? count : (maxExtent + spacing) ~/ childStride - 1;
    final int unRenderedChildCount = count - renderedChildCount;

    // Calculate the total size of rendered children
    final double totalRenderedSize = renderedChildCount * childStride - spacing;

    // Calculate alignment offset
    final double alignmentOffset = _calculateMainAxisAlignmentOffset(totalRenderedSize, maxExtent);

    if (renderedChildCount > 0) {
      childParentData.offstage = false;
      childParentData.offset = _isHorizontal ? Offset(alignmentOffset, 0) : Offset(0, alignmentOffset);
      onstageCount++;
    }

    for (int i = 1; i < renderedChildCount; i++) {
      child = childParentData.nextSibling!;
      childParentData = child.parentData as OverflowViewParentData;
      child.layout(otherChildConstraints);
      childParentData.offset =
          _isHorizontal ? Offset(alignmentOffset + i * childStride, 0) : Offset(0, alignmentOffset + i * childStride);
      childParentData.offstage = false;
      onstageCount++;
    }

    while (child != lastChild) {
      child = childParentData.nextSibling!;
      childParentData = child.parentData as OverflowViewParentData;
      childParentData.offstage = true;
    }

    if (unRenderedChildCount > 0) {
      // We have to layout the overflow indicator.
      final RenderBox overflowIndicator = lastChild!;

      final BoxValueConstraints<int> overflowIndicatorConstraints = BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: otherChildConstraints,
      );
      overflowIndicator.layout(overflowIndicatorConstraints);
      final OverflowViewParentData overflowIndicatorParentData = overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offset = _isHorizontal
          ? Offset(alignmentOffset + renderedChildCount * childStride, 0)
          : Offset(0, alignmentOffset + renderedChildCount * childStride);
      overflowIndicatorParentData.offstage = false;
      onstageCount++;
    }

    final double mainAxisExtent = onstageCount * childStride - spacing;
    final requestedSize = _isHorizontal ? Size(mainAxisExtent, crossExtent) : Size(crossExtent, mainAxisExtent);

    size = constraints.constrain(requestedSize);
  }

  BoxConstraints _getChildrenConstraints() {
    final double maxCrossExtent = _isHorizontal ? constraints.maxHeight : constraints.maxWidth;
    return _isHorizontal
        ? BoxConstraints.loose(Size(double.infinity, maxCrossExtent))
        : BoxConstraints.loose(Size(maxCrossExtent, double.infinity));
  }

  List<RenderBox> _applyChildrenConstraints() {
    RenderBox child = firstChild!;

    final List<RenderBox> children = <RenderBox>[];

    while (child != lastChild) {
      final childParentData = child.parentData as OverflowViewParentData;
      child.layout(_getChildrenConstraints(), parentUsesSize: true);
      children.add(child);
      child = childParentData.nextSibling!;
    }

    return children;
  }

  double _spacingExtent(int childCount) {
    if (childCount == 0) {
      return 0;
    }
    return spacing * (childCount - 1);
  }

  void _performFlexibleLayout() {
    double availableExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

    bool showOverflowIndicator = false;

    // First we retrieve the size of all the children.

    final children = _applyChildrenConstraints();

    double maxCrossSize = 0;

    double filledExtent = 0;
    int fittingChildren = 0;

    for (final child in children) {
      final childParentData = child.parentData as OverflowViewParentData;
      double childMainSize = _getMainSize(child);
      double childCrossSize = _getCrossSize(child);

      maxCrossSize = math.max(maxCrossSize, childCrossSize);

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
      // We need to place the overflow indicator. To do this we
      // might need to remove children until it fits.
      final RenderBox overflowIndicator = lastChild!;
      final BoxValueConstraints<int> overflowIndicatorConstraints = BoxValueConstraints<int>(
        value: childCount - fittingChildren - 1,
        constraints: _getChildrenConstraints(),
      );

      overflowIndicator.layout(
        overflowIndicatorConstraints,
        parentUsesSize: true,
      );

      final OverflowViewParentData overflowIndicatorParentData = overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offstage = false;

      double indicatorSize = _getMainSize(overflowIndicator);
      filledExtent += indicatorSize;

      while (filledExtent + _spacingExtent(fittingChildren + 1) >= availableExtent) {
        final RenderBox lastChild = renderedChildren.last;

        final OverflowViewParentData lastChildParentData = lastChild.parentData as OverflowViewParentData;
        lastChildParentData.offstage = true;

        renderedChildren.removeLast();
        fittingChildren--;
        final freed = _getMainSize(lastChild);

        filledExtent -= freed;
      }

      renderedChildren.add(overflowIndicator);

      maxCrossSize = math.max(maxCrossSize, _getCrossSize(overflowIndicator));
    }

    double remainder = availableExtent - filledExtent - _spacingExtent(renderedChildren.length);

    if (expandFirstChild) {
      double childMainSize = _getMainSize(children.first);

      firstChild!.layout(
        BoxConstraints.tight(Size(childMainSize + remainder, maxCrossSize)),
        parentUsesSize: true,
      );

      remainder = 0;
    }

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

    Size idealSize;
    if (_isHorizontal) {
      idealSize = Size(offset, maxCrossSize);
    } else {
      idealSize = Size(maxCrossSize, offset);
    }

    size = constraints.constrain(idealSize);
  }

  void visitOnlyOnStageChildren(RenderObjectVisitor visitor) {
    visitChildren((child) {
      if (child.isOnstage) {
        visitor(child);
      }
    });
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitOnlyOnStageChildren(visitor);
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
}

extension on Size {
  double getMainExtent(Axis axis) {
    return axis == Axis.horizontal ? width : height;
  }

  double getCrossExtent(Axis axis) {
    return axis == Axis.horizontal ? height : width;
  }
}

extension RenderObjectExtensions on RenderObject {
  bool get isOnstage => (parentData as OverflowViewParentData).offstage == false;
}
