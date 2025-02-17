// ///TODO: OG CODE
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
//     final point = map.pointToLatLng(Point<double>(details.localPosition.dx, details.localPosition.dy));
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
//         _paintLine(borderPath, offsets);
//         _paintLine(path, offsets);
//       }
//     }
//
//     drawPaths();
//   }
//
//   void _paintLine(ui.Path path, List<Offset> points) {
//     for (var i = 0; i < points.length; i++) {
//       final point = points[i];
//
//       if (i == 0) {
//         path.moveTo(point.dx, point.dy);
//       } else {
//         path.lineTo(point.dx, point.dy);
//       }
//     }
//   }
//
//   void _paintDottedLine(
//       ui.Path path, List<Offset> points, double radius, double spacing) {
//     for (var i = 1; i < points.length; i++) {
//       final p1 = points[i - 1];
//       final p2 = points[i];
//       final total = (p2 - p1).distance;
//       var distance = 0.0;
//       while (distance < total) {
//         final x = p1.dx + (p2.dx - p1.dx) * (distance / total);
//         final y = p1.dy + (p2.dy - p1.dy) * (distance / total);
//         path.addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
//         distance += spacing;
//       }
//     }
//   }
//
//   Shader _paintGradient(TaggedPolyline polyline, List<Offset> points) {
//     final colors = polyline.gradientColors!;
//     final colorsStop = polyline.colorsStop ??
//         colors
//             .asMap()
//             .entries
//             .map((entry) => entry.key / colors.length)
//             .toList();
//
//     return ui.Gradient.linear(points.first, points.last, colors, colorsStop);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     if (oldDelegate is! PolylinePainter) return false;
//     return hash != oldDelegate.hash;
//   }
// }
import 'dart:core';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/geo/latlng_bounds.dart';
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
  final double tapToleranceInMeters; // Geographic tolerance for tap

  const TappablePolylineLayer({
    super.key,
    required this.polylines,
    this.polylineCulling = false,
    this.onTap, // New parameter
    this.tapToleranceInMeters = 20.0, // Default tap tolerance in meters
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
                    .where(
                        (p) => p.boundingBox.isOverlapping(map.visibleBounds))
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

    final tapPositionPoint =
        Point<double>(details.localPosition.dx, details.localPosition.dy);
    final tappedLatLng =
        map.pointToLatLng(tapPositionPoint);

    for (final polyline in polylines) {
      if (_isPointNearPolyline(
          tappedLatLng, polyline, map, tapToleranceInMeters)) {
        onTap!(polyline.tag);
        break;
      }
    }
  }

  bool _isPointNearPolyline(LatLng tapPoint, TaggedPolyline polyline,
      MapCamera map, double toleranceInMeters) {
    final distanceCalculator = const Distance();

    for (int i = 0; i < polyline.points.length - 1; i++) {
      final startPoint = polyline.points[i];
      final endPoint = polyline.points[i + 1];

      final distance = _distanceToLineSegment(
          tapPoint, startPoint, endPoint, distanceCalculator);
      if (distance <= toleranceInMeters) {
        return true;
      }
    }
    return false;
  }

  double _distanceToLineSegment(
      LatLng p, LatLng start, LatLng end, Distance distanceCalculator) {
    final segmentLengthKm =
        distanceCalculator.as(LengthUnit.Kilometer, start, end);
    if (segmentLengthKm == 0.0)
      return distanceCalculator.as(
          LengthUnit.Meter, p, start); // Segment is a point

    final u = ((p.latitude - start.latitude) * (end.latitude - start.latitude) +
            (p.longitude - start.longitude) *
                (end.longitude - start.longitude)) /
        (segmentLengthKm * segmentLengthKm);
    if (u < 0 || u > 1) {
      return min(
          distanceCalculator.as(LengthUnit.Meter, p, start),
          distanceCalculator.as(
              LengthUnit.Meter, p, end)); // Closest to segment endpoints
    }

    final projectionLat = start.latitude + u * (end.latitude - start.latitude);
    final projectionLng =
        start.longitude + u * (end.longitude - start.longitude);
    final projectionPoint = LatLng(projectionLat, projectionLng);

    return distanceCalculator.as(LengthUnit.Meter, p,
        projectionPoint); // Distance to the projected point
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
