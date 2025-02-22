// mapAnimationController.dart
import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapAnimationController {
  final MapController mapController;
  final TickerProvider tickerProvider;
  AnimationController? _animationController;
  Animation<double>? _animation;
  LatLng? _targetCenter;
  double? _targetRotation;
  double? _targetZoom;

  MapAnimationController({
    required this.mapController,
    required this.tickerProvider,
  });

  void updateMapCenter(LatLng newCenter, double? targetRotation,
      {double? zoomLevel, bool animated = true}) {
    if (animated && !isAnimating) {
      _animatedPanAndRotateTo(
          newCenter, zoomLevel ?? mapController.camera.zoom, targetRotation);
    } else {
      mapController.move(newCenter, zoomLevel ?? mapController.camera.zoom);
      if (targetRotation != null) {
        mapController.rotate(targetRotation);
      }
    }
  }

  void updateZoom(double zoom, {bool animated = true}) {
    if (animated && !isAnimating) {
      _animatedZoomTo(zoom);
    } else {
      mapController.move(mapController.camera.center, zoom);
    }
  }

  void _animatedZoomTo(double destZoom) {
    if (isAnimating) return;

    final startZoom = mapController.camera.zoom;
    _targetZoom = destZoom;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: tickerProvider,
    );

    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOutQuad,
    );

    void Function() animationListener;

    animationListener = () {
      if (!isAnimating) return;

      final t = _animation!.value;
      final lerpZoom = lerpDouble(startZoom, _targetZoom, t)!;

      mapController.move(mapController.camera.center, lerpZoom);

      if (t == 1.0) {
        _animationController!.stop();
      }
    };

    _animationController!.addListener(animationListener);

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _animationController!.removeListener(animationListener);
        _animationController!.dispose();
        _animationController = null;
        _animation = null;
        _targetZoom = null;
      }
    });

    _animationController!.forward();
  }

  void startContinuousPan() {
    _targetCenter = mapController.camera.center;
    _animationController?.forward();
  }

  void stopContinuousPan() {
    _animationController?.stop();
  }

  void resetRotation() {
    mapController.rotate(0.0);
  }

  bool get isAnimating => _animationController?.isAnimating ?? false;

  void _animatedPanAndRotateTo(
      LatLng destCenter, double destZoom, double? destRotation) {
    if (isAnimating) return;

    final startCenter = mapController.camera.center;
    final startZoom = mapController.camera.zoom;
    final startRotation = mapController.camera.rotation;

    _targetCenter = destCenter;
    _targetRotation = destRotation ?? 0.0;
    _targetZoom = destZoom;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: tickerProvider,
    );

    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOutCubic,
    );

    void Function() animationListener;

    animationListener = () {
      if (!isAnimating) return;

      final t = _animation!.value;

      final lerpLat =
          lerpDouble(startCenter.latitude, _targetCenter!.latitude, t)!;
      final lerpLng =
          lerpDouble(startCenter.longitude, _targetCenter!.longitude, t)!;
      final lerpZoom = lerpDouble(startZoom, _targetZoom, t)!;
      final lerpRotation =
          lerpDouble(startRotation, _targetRotation ?? 0.0, t)!;

      mapController.move(LatLng(lerpLat, lerpLng), lerpZoom);
      mapController.rotate(lerpRotation);

      if (t == 1.0) {
        _animationController!.stop();
      }
    };

    _animationController!.addListener(animationListener);

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _animationController!.removeListener(animationListener);
        _animationController!.dispose();
        _animationController = null;
        _animation = null;
        _targetCenter = null;
        _targetRotation = null;
        _targetZoom = null;
      }
    });

    _animationController!.forward();
  }
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == null || b == null) {
    return null;
  }
  return a + (b - a) * t;
}
