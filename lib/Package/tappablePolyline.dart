// // import 'dart:math';
// // import 'dart:ui';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';
// //
// // class TaggedPolyline extends Polyline {
// //   final String? tag;
// //   final List<Offset> _offsets = [];
// //   final VoidCallback onTap;
// //
// //   TaggedPolyline({
// //     required super.points,
// //     super.strokeWidth = 1.0,
// //     super.color = const Color(0xFF00FF00),
// //     super.borderStrokeWidth = 0.0,
// //     super.borderColor = const Color(0xFFFFFF00),
// //     super.gradientColors,
// //     super.colorsStop,
// //     super.isDotted = false,
// //     this.tag,
// //     required this.onTap,
// //   });
// // }
// //
// // class TappablePolylineLayer extends StatelessWidget {
// //   final List<TaggedPolyline> polylines;
// //   final double pointerDistanceTolerance;
// //   final void Function(TapUpDetails tapPosition)? onMiss;
// //
// //   const TappablePolylineLayer({
// //     Key? key,
// //     this.polylines = const [],
// //     this.onMiss,
// //     this.pointerDistanceTolerance = 15,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final mapCamera = MapCamera.of(context);
// //     final size = Size(mapCamera.size.x, mapCamera.size.y);
// //     return _build(context, size, polylines);
// //   }
// //
// //   Widget _build(BuildContext context, Size size, List<TaggedPolyline> lines) {
// //     final mapState = MapCamera.of(context);
// //     final rotation = mapState.rotation;
// //     final scale = mapState.getZoomScale(mapState.zoom, mapState.zoom);
// //     final pixelOrigin = mapState.pixelOrigin.toDoublePoint();
// //
// //     for (var polyline in lines) {
// //       polyline._offsets.clear();
// //       for (var point in polyline.points) {
// //         var pos = mapState.project(point) * scale - pixelOrigin;
// //         var offset = Offset(pos.x.toDouble(), pos.y.toDouble());
// //         // Rotate the offset
// //         offset = _rotateOffset(offset, rotation, size);
// //         polyline._offsets.add(offset);
// //       }
// //     }
// //
// //     return GestureDetector(
// //       behavior: HitTestBehavior.translucent,
// //       onTapUp: (details) {
// //         _handlePolylineTap(context, details.localPosition, details);
// //       },
// //       child: MobileLayerTransformer(
// //         child: CustomPaint(
// //           painter: PolylinePainter(lines, rotation, size),
// //           size: size,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Offset _rotateOffset(Offset offset, double rotation, Size size) {
// //     final radians = rotation * (pi / 180);
// //     final centerX = size.width / 2;
// //     final centerY = size.height / 2;
// //
// //     final dx = offset.dx - centerX;
// //     final dy = offset.dy - centerY;
// //
// //     final newX = dx * cos(radians) - dy * sin(radians) + centerX;
// //     final newY = dx * sin(radians) + dy * cos(radians) + centerY;
// //
// //     return Offset(newX, newY);
// //   }
// //
// //   void _handlePolylineTap(BuildContext context, Offset tapPosition, TapUpDetails details) {
// //     final mapState = MapCamera.of(context);
// //     final rotation = mapState.rotation;
// //     final size = Size(mapState.size.x, mapState.size.y);
// //
// //     tapPosition = _rotateOffset(tapPosition, -rotation, size);
// //
// //     double closestDistance = double.infinity;
// //     TaggedPolyline? closestPolyline;
// //
// //     for (var polyline in polylines) {
// //       for (var i = 0; i < polyline._offsets.length - 1; i++) {
// //         var point1 = polyline._offsets[i];
// //         var point2 = polyline._offsets[i + 1];
// //
// //         var distance = _distanceToSegment(tapPosition, point1, point2);
// //
// //         if (distance < pointerDistanceTolerance && distance < closestDistance) {
// //           closestDistance = distance;
// //           closestPolyline = polyline;
// //         }
// //       }
// //     }
// //
// //     if (closestPolyline != null) {
// //       closestPolyline.onTap();
// //     } else {
// //       onMiss?.call(details);
// //     }
// //   }
// //
// //   static double _distanceToSegment(Offset p, Offset v, Offset w) {
// //     final l2 = (v - w).distanceSquared;
// //     if (l2 == 0) return (p - v).distance;
// //
// //     double t = ((p - v).dot(w - v) / l2).clamp(0, 1);
// //     var projection = v + (w - v) * t;
// //     return (p - projection).distance;
// //   }
// // }
// //
// // class PolylinePainter extends CustomPainter {
// //   final List<TaggedPolyline> polylines;
// //   final double rotation;
// //   final Size size;
// //
// //   PolylinePainter(this.polylines, this.rotation, this.size);
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     canvas.save();
// //     // Rotate the canvas
// //     canvas.translate(size.width / 2, size.height / 2);
// //     canvas.rotate(-rotation * (pi / 180));
// //     canvas.translate(-size.width / 2, -size.height / 2);
// //
// //     for (final polyline in polylines) {
// //       if (polyline._offsets.isEmpty) continue;
// //
// //       final paint = Paint()
// //         ..color = polyline.color
// //         ..strokeWidth = polyline.strokeWidth
// //         ..strokeCap = StrokeCap.round
// //         ..strokeJoin = StrokeJoin.round
// //         ..style = PaintingStyle.stroke;
// //
// //       canvas.drawPoints(PointMode.polygon, polyline._offsets, paint);
// //     }
// //
// //     canvas.restore();
// //   }
// //
// //   @override
// //   bool shouldRepaint(PolylinePainter oldDelegate) =>
// //       rotation!= oldDelegate.rotation || polylines!= oldDelegate.polylines;
// // }
// //
// // extension on Offset {
// //   double get distance => sqrt(dx * dx + dy * dy);
// //   double get distanceSquared => dx * dx + dy * dy;
// //   double dot(Offset other) => dx * other.dx + dy * other.dy;
// // }
//
//
// import 'dart:core';
// import 'dart:math';
// import 'dart:ui' as ui;
//
// import 'package:flutter/widgets.dart';
// import 'package:flutter_map/src/geo/latlng_bounds.dart';
// import 'package:flutter_map/src/layer/general/mobile_layer_transformer.dart';
// import 'package:flutter_map/src/map/camera/camera.dart';
// import 'package:latlong2/latlong.dart';
//
// class TaggedPolyline {
//   final List<LatLng> points;
//   final double strokeWidth;
//   final Color color;
//   final double borderStrokeWidth;
//   final Color? borderColor;
//   final List<Color>? gradientColors;
//   final List<double>? colorsStop;
//   final bool isDotted;
//   final StrokeCap strokeCap;
//   final StrokeJoin strokeJoin;
//   final bool useStrokeWidthInMeter;
//   final String tag; // New property
//
//   LatLngBounds? _boundingBox;
//
//   LatLngBounds get boundingBox =>
//       _boundingBox ??= LatLngBounds.fromPoints(points);
//
//   TaggedPolyline({
//     required this.points,
//     this.strokeWidth = 1.0,
//     this.color = const Color(0xFF00FF00),
//     this.borderStrokeWidth = 0.0,
//     this.borderColor = const Color(0xFFFFFF00),
//     this.gradientColors,
//     this.colorsStop,
//     this.isDotted = false,
//     this.strokeCap = StrokeCap.round,
//     this.strokeJoin = StrokeJoin.round,
//     this.useStrokeWidthInMeter = false,
//     required this.tag, // New parameter
//   });
//
//   /// Used to batch draw calls to the canvas.
//   int get renderHashCode => Object.hash(
//       strokeWidth,
//       color,
//       borderStrokeWidth,
//       borderColor,
//       gradientColors,
//       colorsStop,
//       isDotted,
//       strokeCap,
//       strokeJoin,
//       useStrokeWidthInMeter);
// }
//
// @immutable
// class TappablePolylineLayer extends StatelessWidget {
//   final List<TaggedPolyline> polylines;
//   final bool polylineCulling;
//   final Function(String)? onTap; // New property
//
//   const TappablePolylineLayer({
//     super.key,
//     required this.polylines,
//     this.polylineCulling = false,
//     this.onTap, // New parameter
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final map = MapCamera.of(context);
//
//     return MobileLayerTransformer(
//       child: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTapUp: (details) => _handleTap(details, map),
//         child: CustomPaint(
//           painter: PolylinePainter(
//             polylineCulling
//                 ? polylines
//                 .where((p) => p.boundingBox.isOverlapping(map.visibleBounds))
//                 .toList()
//                 : polylines,
//             map,
//           ),
//           size: Size(map.size.x, map.size.y),
//           isComplex: true,
//         ),
//       ),
//     );
//   }
//
//   void _handleTap(TapUpDetails details, MapCamera map) {
//     if (onTap == null) return;
//
//     final point = map.pointToLatLng(details.localPosition as Point<num>);
//     for (final polyline in polylines) {
//       if (_isPointNearPolyline(point, polyline, map)) {
//         onTap!(polyline.tag);
//         break;
//       }
//     }
//   }
//
//   bool _isPointNearPolyline(LatLng point, TaggedPolyline polyline, MapCamera map) {
//     const toleranceInPixels = 10.0;
//
//     for (int i = 0; i < polyline.points.length - 1; i++) {
//       final start = map.getOffsetFromOrigin(polyline.points[i]);
//       final end = map.getOffsetFromOrigin(polyline.points[i + 1]);
//       final tap = map.getOffsetFromOrigin(point);
//
//       final distance = _distanceToLineSegment(tap, start, end);
//       if (distance <= toleranceInPixels) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   double _distanceToLineSegment(Offset p, Offset start, Offset end) {
//     final l2 = (end - start).distanceSquared;
//     if (l2 == 0) return (p - start).distance;
//
//     final t = ((p - start).dx * (end - start).dx + (p - start).dy * (end - start).dy) / l2;
//     if (t < 0) return (p - start).distance;
//     if (t > 1) return (p - end).distance;
//
//     final projection = start + (end - start) * t;
//     return (p - projection).distance;
//   }
// }
//
// class PolylinePainter extends CustomPainter {
//   final List<TaggedPolyline> polylines;
//
//   final MapCamera map;
//   final LatLngBounds bounds;
//
//   PolylinePainter(this.polylines, this.map) : bounds = map.visibleBounds;
//
//   int get hash => _hash ??= Object.hashAll(polylines);
//
//   int? _hash;
//
//   List<Offset> getOffsets(List<LatLng> points) {
//     return List.generate(points.length, (index) {
//       return getOffset(points[index]);
//     }, growable: false);
//   }
//
//   Offset getOffset(LatLng point) => map.getOffsetFromOrigin(point);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;
//
//     var path = ui.Path();
//     var borderPath = ui.Path();
//     var filterPath = ui.Path();
//     var paint = Paint();
//     var needsLayerSaving = false;
//
//     Paint? borderPaint;
//     Paint? filterPaint;
//     int? lastHash;
//
//     void drawPaths() {
//       final hasBorder = borderPaint != null && filterPaint != null;
//       if (hasBorder) {
//         if (needsLayerSaving) {
//           canvas.saveLayer(rect, Paint());
//         }
//
//         canvas.drawPath(borderPath, borderPaint!);
//         borderPath = ui.Path();
//         borderPaint = null;
//
//         if (needsLayerSaving) {
//           canvas.drawPath(filterPath, filterPaint!);
//           filterPath = ui.Path();
//           filterPaint = null;
//
//           canvas.restore();
//         }
//       }
//
//       canvas.drawPath(path, paint);
//       path = ui.Path();
//       paint = Paint();
//     }
//
//     for (final polyline in polylines) {
//       final offsets = getOffsets(polyline.points);
//       if (offsets.isEmpty) {
//         continue;
//       }
//
//       final hash = polyline.renderHashCode;
//       if (needsLayerSaving || (lastHash != null && lastHash != hash)) {
//         drawPaths();
//       }
//       lastHash = hash;
//       needsLayerSaving = polyline.color.opacity < 1.0 ||
//           (polyline.gradientColors?.any((c) => c.opacity < 1.0) ?? false);
//
//       late final double strokeWidth;
//       if (polyline.useStrokeWidthInMeter) {
//         final firstPoint = polyline.points.first;
//         final firstOffset = offsets.first;
//         final r = const Distance().offset(
//           firstPoint,
//           polyline.strokeWidth,
//           180,
//         );
//         final delta = firstOffset - getOffset(r);
//
//         strokeWidth = delta.distance;
//       } else {
//         strokeWidth = polyline.strokeWidth;
//       }
//
//       final isDotted = polyline.isDotted;
//       paint = Paint()
//         ..strokeWidth = strokeWidth
//         ..strokeCap = polyline.strokeCap
//         ..strokeJoin = polyline.strokeJoin
//         ..style = isDotted ? PaintingStyle.fill : PaintingStyle.stroke
//         ..blendMode = BlendMode.srcOver;
//
//       if (polyline.gradientColors == null) {
//         paint.color = polyline.color;
//       } else {
//         polyline.gradientColors!.isNotEmpty
//             ? paint.shader = _paintGradient(polyline, offsets)
//             : paint.color = polyline.color;
//       }
//
//       if (polyline.borderColor != null && polyline.borderStrokeWidth > 0.0) {
//         // Outlined lines are drawn by drawing a thicker path underneath, then
//         // stenciling the middle (in case the line fill is transparent), and
//         // finally drawing the line fill.
//         borderPaint = Paint()
//           ..color = polyline.borderColor ?? const Color(0x00000000)
//           ..strokeWidth = strokeWidth + polyline.borderStrokeWidth
//           ..strokeCap = polyline.strokeCap
//           ..strokeJoin = polyline.strokeJoin
//           ..style = isDotted ? PaintingStyle.fill : PaintingStyle.stroke
//           ..blendMode = BlendMode.srcOver;
//
//         filterPaint = Paint()
//           ..color = polyline.borderColor!.withAlpha(255)
//           ..strokeWidth = strokeWidth
//           ..strokeCap = polyline.strokeCap
//           ..strokeJoin = polyline.strokeJoin
//           ..style = isDotted ? PaintingStyle.fill : PaintingStyle.stroke
//           ..blendMode = BlendMode.dstOut;
//       }
//
//       final radius = paint.strokeWidth / 2;
//       final borderRadius = (borderPaint?.strokeWidth ?? 0) / 2;
//
//       if (isDotted) {
//         final spacing = strokeWidth * 1.5;
//         if (borderPaint != null && filterPaint != null) {
//           _paintDottedLine(borderPath, offsets, borderRadius, spacing);
//           _paintDottedLine(filterPath, offsets, radius, spacing);
//         }
//         _paintDottedLine(path, offsets, radius, spacing);
//       } else {
//         if (borderPaint != null && filterPaint != null) {
//           _paintLine(borderPath, offsets);
//           _paintLine(filterPath, offsets);
//         }
//         _paintLine(path, offsets);
//       }
//     }
//
//     drawPaths();
//   }
//
//   void _paintDottedLine(
//       ui.Path path, List<Offset> offsets, double radius, double stepLength) {
//     var startDistance = 0.0;
//     for (var i = 0; i < offsets.length - 1; i++) {
//       final o0 = offsets[i];
//       final o1 = offsets[i + 1];
//       final totalDistance = (o0 - o1).distance;
//       var distance = startDistance;
//       while (distance < totalDistance) {
//         final f1 = distance / totalDistance;
//         final f0 = 1.0 - f1;
//         final offset = Offset(o0.dx * f0 + o1.dx * f1, o0.dy * f0 + o1.dy * f1);
//         path.addOval(Rect.fromCircle(center: offset, radius: radius));
//         distance += stepLength;
//       }
//       startDistance = distance < totalDistance
//           ? stepLength - (totalDistance - distance)
//           : distance - totalDistance;
//     }
//     path.addOval(Rect.fromCircle(center: offsets.last, radius: radius));
//   }
//
//   void _paintLine(ui.Path path, List<Offset> offsets) {
//     if (offsets.isEmpty) {
//       return;
//     }
//     path.addPolygon(offsets, false);
//   }
//
//   ui.Gradient _paintGradient(TaggedPolyline polyline, List<Offset> offsets) =>
//       ui.Gradient.linear(offsets.first, offsets.last, polyline.gradientColors!,
//           _getColorsStop(polyline));
//
//   List<double>? _getColorsStop(TaggedPolyline polyline) =>
//       (polyline.colorsStop != null &&
//           polyline.colorsStop!.length == polyline.gradientColors!.length)
//           ? polyline.colorsStop
//           : _calculateColorsStop(polyline);
//
//   List<double> _calculateColorsStop(TaggedPolyline polyline) {
//     final colorsStopInterval = 1.0 / polyline.gradientColors!.length;
//     return polyline.gradientColors!
//         .map((gradientColor) =>
//     polyline.gradientColors!.indexOf(gradientColor) *
//         colorsStopInterval)
//         .toList();
//   }
//
//   @override
//   bool shouldRepaint(PolylinePainter oldDelegate) {
//     return oldDelegate.bounds != bounds ||
//         oldDelegate.polylines.length != polylines.length ||
//         oldDelegate.hash != hash;
//   }
// }


import 'dart:core';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_map/src/geo/latlng_bounds.dart';
import 'package:flutter_map/src/layer/general/mobile_layer_transformer.dart';
import 'package:flutter_map/src/map/camera/camera.dart';
import 'package:latlong2/latlong.dart';

class TaggedPolyline {
  final List<LatLng> points;
  final double strokeWidth;
  final Color color;
  final double borderStrokeWidth;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final List<double>? colorsStop;
  final bool isDotted;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final bool useStrokeWidthInMeter;
  final String tag; // New property

  LatLngBounds? _boundingBox;

  LatLngBounds get boundingBox =>
      _boundingBox ??= LatLngBounds.fromPoints(points);

  TaggedPolyline({
    required this.points,
    this.strokeWidth = 1.0,
    this.color = const Color(0xFF00FF00),
    this.borderStrokeWidth = 0.0,
    this.borderColor = const Color(0xFFFFFF00),
    this.gradientColors,
    this.colorsStop,
    this.isDotted = false,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.useStrokeWidthInMeter = false,
    required this.tag, // New parameter
  });

  /// Used to batch draw calls to the canvas.
  int get renderHashCode => Object.hash(
      strokeWidth,
      color,
      borderStrokeWidth,
      borderColor,
      gradientColors,
      colorsStop,
      isDotted,
      strokeCap,
      strokeJoin,
      useStrokeWidthInMeter);
}

@immutable
class TappablePolylineLayer extends StatelessWidget {
  final List<TaggedPolyline> polylines;
  final bool polylineCulling;
  final Function(String)? onTap; // New property

  const TappablePolylineLayer({
    super.key,
    required this.polylines,
    this.polylineCulling = false,
    this.onTap, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    final map = MapCamera.of(context);

    return MobileLayerTransformer(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) => _handleTap(details, map),
        child: CustomPaint(
          painter: PolylinePainter(
            polylineCulling
                ? polylines
                .where((p) => p.boundingBox.isOverlapping(map.visibleBounds))
                .toList()
                : polylines,
            map,
          ),
          size: Size(map.size.x, map.size.y),
          isComplex: true,
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details, MapCamera map) {
    if (onTap == null) return;

    final point = map.pointToLatLng(Point<double>(details.localPosition.dx, details.localPosition.dy));
    for (final polyline in polylines) {
      if (_isPointNearPolyline(point, polyline, map)) {
        onTap!(polyline.tag);
        break;
      }
    }
  }

  bool _isPointNearPolyline(LatLng point, TaggedPolyline polyline, MapCamera map) {
    const toleranceInPixels = 10.0;

    for (int i = 0; i < polyline.points.length - 1; i++) {
      final start = map.getOffsetFromOrigin(polyline.points[i]);
      final end = map.getOffsetFromOrigin(polyline.points[i + 1]);
      final tap = map.getOffsetFromOrigin(point);

      final distance = _distanceToLineSegment(tap, start, end);
      if (distance <= toleranceInPixels) {
        return true;
      }
    }
    return false;
  }

  double _distanceToLineSegment(Offset p, Offset start, Offset end) {
    final l2 = (end - start).distanceSquared;
    if (l2 == 0) return (p - start).distance;

    final t = ((p - start).dx * (end - start).dx + (p - start).dy * (end - start).dy) / l2;
    if (t < 0) return (p - start).distance;
    if (t > 1) return (p - end).distance;

    final projection = start + (end - start) * t;
    return (p - projection).distance;
  }
}

class PolylinePainter extends CustomPainter {
  final List<TaggedPolyline> polylines;

  final MapCamera map;
  final LatLngBounds bounds;

  PolylinePainter(this.polylines, this.map) : bounds = map.visibleBounds;

  int get hash => _hash ??= Object.hashAll(polylines);

  int? _hash;

  List<Offset> getOffsets(List<LatLng> points) {
    return List.generate(points.length, (index) {
      return getOffset(points[index]);
    }, growable: false);
  }

  Offset getOffset(LatLng point) => map.getOffsetFromOrigin(point);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    var path = ui.Path();
    var borderPath = ui.Path();
    var filterPath = ui.Path();
    var paint = Paint();
    var needsLayerSaving = false;

    Paint? borderPaint;
    Paint? filterPaint;
    int? lastHash;

    void drawPaths() {
      final hasBorder = borderPaint != null && filterPaint != null;
      if (hasBorder) {
        if (needsLayerSaving) {
          canvas.saveLayer(rect, Paint());
        }

        canvas.drawPath(borderPath, borderPaint!);
        borderPath = ui.Path();
        borderPaint = null;

        if (needsLayerSaving) {
          canvas.drawPath(filterPath, filterPaint!);
          filterPath = ui.Path();
          filterPaint = null;

          canvas.restore();
        }
      }

      canvas.drawPath(path, paint);
      path = ui.Path();
      paint = Paint();
    }

    for (final polyline in polylines) {
      final offsets = getOffsets(polyline.points);
      if (offsets.isEmpty) {
        continue;
      }

      final hash = polyline.renderHashCode;
      if (needsLayerSaving || (lastHash != null && lastHash != hash)) {
        drawPaths();
      }
      lastHash = hash;
      needsLayerSaving = polyline.color.opacity < 1.0 ||
          (polyline.gradientColors?.any((c) => c.opacity < 1.0) ?? false);

      late final double strokeWidth;
      if (polyline.useStrokeWidthInMeter) {
        final firstPoint = polyline.points.first;
        final firstOffset = offsets.first;
        final r = const Distance().offset(
          firstPoint,
          polyline.strokeWidth,
          180,
        );
        final delta = firstOffset - getOffset(r);

        strokeWidth = delta.distance;
      } else {
        strokeWidth = polyline.strokeWidth;
      }

      final isDotted = polyline.isDotted;
      paint = Paint()
        ..strokeWidth = strokeWidth
        ..strokeCap = polyline.strokeCap
        ..strokeJoin = polyline.strokeJoin
        ..style = isDotted ? PaintingStyle.fill : PaintingStyle.stroke
        ..blendMode = BlendMode.srcOver;

      if (polyline.gradientColors == null) {
        paint.color = polyline.color;
      } else {
        polyline.gradientColors!.isNotEmpty
            ? paint.shader = _paintGradient(polyline, offsets)
            : paint.color = polyline.color;
      }

      if (polyline.borderColor != null && polyline.borderStrokeWidth > 0.0) {
        // Outlined lines are drawn by drawing a thicker path underneath, then
        // stenciling the middle (in case the line fill is transparent), and
        // finally drawing the line fill.
        borderPaint = Paint()
          ..color = polyline.borderColor ?? const Color(0x00000000)
          ..strokeWidth = strokeWidth + polyline.borderStrokeWidth
          ..strokeCap = polyline.strokeCap
          ..strokeJoin = polyline.strokeJoin
          ..style = isDotted ? PaintingStyle.fill : PaintingStyle.stroke
          ..blendMode = BlendMode.srcOver;

        filterPaint = Paint()
          ..color = polyline.borderColor!.withAlpha(255)
          ..strokeWidth = strokeWidth
          ..strokeCap = polyline.strokeCap
          ..strokeJoin = polyline.strokeJoin
          ..style = isDotted ? PaintingStyle.fill : PaintingStyle.stroke
          ..blendMode = BlendMode.dstOut;
      }

      final radius = paint.strokeWidth / 2;
      final borderRadius = (borderPaint?.strokeWidth ?? 0) / 2;

      if (isDotted) {
        final spacing = strokeWidth * 1.5;
        if (borderPaint != null && filterPaint != null) {
          _paintDottedLine(borderPath, offsets, borderRadius, spacing);
          _paintDottedLine(filterPath, offsets, radius, spacing);
        }
        _paintDottedLine(path, offsets, radius, spacing);
      } else {
        _paintLine(borderPath, offsets);
        _paintLine(path, offsets);
      }
    }

    drawPaths();
  }

  void _paintLine(ui.Path path, List<Offset> points) {
    for (var i = 0; i < points.length; i++) {
      final point = points[i];

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
  }

  void _paintDottedLine(
      ui.Path path, List<Offset> points, double radius, double spacing) {
    for (var i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final total = (p2 - p1).distance;
      var distance = 0.0;
      while (distance < total) {
        final x = p1.dx + (p2.dx - p1.dx) * (distance / total);
        final y = p1.dy + (p2.dy - p1.dy) * (distance / total);
        path.addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
        distance += spacing;
      }
    }
  }

  Shader _paintGradient(TaggedPolyline polyline, List<Offset> points) {
    final colors = polyline.gradientColors!;
    final colorsStop = polyline.colorsStop ??
        colors
            .asMap()
            .entries
            .map((entry) => entry.key / colors.length)
            .toList();

    return ui.Gradient.linear(points.first, points.last, colors, colorsStop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! PolylinePainter) return false;
    return hash != oldDelegate.hash;
  }
}
