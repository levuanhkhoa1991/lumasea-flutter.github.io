import 'dart:math';
import 'package:flutter/material.dart';
import '../data/catalog.dart';

/// An illustrated journey map: stops are laid out along a curved path
/// with a transport icon animating along the route.
///
/// This is a stylized illustration, not a real GPS map — it needs no API
/// key and no native map SDK setup, so it works out of the box anywhere
/// this project runs (including Snack). If you later want a real map,
/// swap this widget for `google_maps_flutter` with your own API key.
class RouteMap extends StatefulWidget {
  final List<String> stopLabels;
  final TransportMode mode;
  final double height;

  const RouteMap({
    super.key,
    required this.stopLabels,
    required this.mode,
    this.height = 220,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stops = widget.stopLabels.length >= 2
        ? widget.stopLabels
        : [...widget.stopLabels, widget.stopLabels.isEmpty ? '' : widget.stopLabels.first];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2FE), Color(0xFFF1F9FA)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _RouteMapPainter(
              stopCount: stops.length,
              progress: _controller.value,
              mode: widget.mode,
            ),
            child: _StopLabels(stops: stops),
          ),
        ),
      ),
    );
  }
}

/// Positions the stop name chips above/below their dots (painted
/// separately by [_RouteMapPainter], using the same layout math).
class _StopLabels extends StatelessWidget {
  final List<String> stops;
  const _StopLabels({required this.stops});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final points = _stopPositions(stops.length, constraints.biggest);
      return Stack(
        children: [
          for (var i = 0; i < stops.length; i++)
            Positioned(
              left: (points[i].dx - 55).clamp(0, constraints.maxWidth - 110),
              top: points[i].dy + (i.isEven ? 12 : -34),
              child: SizedBox(
                width: 110,
                child: Text(
                  stops[i],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF073B4C),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Lays stops out along a gentle S-curve across the available size.
List<Offset> _stopPositions(int count, Size size) {
  final points = <Offset>[];
  for (var i = 0; i < count; i++) {
    final t = count <= 1 ? 0.0 : i / (count - 1);
    final x = 24 + t * (size.width - 48);
    final wave = sin(t * pi * 1.4) * (size.height * 0.18);
    final y = size.height * 0.5 + wave;
    points.add(Offset(x, y));
  }
  return points;
}

class _RouteMapPainter extends CustomPainter {
  final int stopCount;
  final double progress;
  final TransportMode mode;

  _RouteMapPainter({required this.stopCount, required this.progress, required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    final points = _stopPositions(stopCount, size);
    if (points.length < 2) return;

    // Dotted route line through all stops.
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      path.quadraticBezierTo(mid.dx, mid.dy, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF0E7490).withOpacity(.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    _drawDashedPath(canvas, path, linePaint);

    // Stop dots.
    for (var i = 0; i < points.length; i++) {
      final isEndpoint = i == 0 || i == points.length - 1;
      canvas.drawCircle(points[i], isEndpoint ? 7 : 5,
          Paint()..color = isEndpoint ? const Color(0xFF0E7490) : const Color(0xFF67C9E8));
      canvas.drawCircle(points[i], isEndpoint ? 7 : 5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    // Moving transport icon along the path.
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
    final targetLength = totalLength * progress;
    double covered = 0;
    for (final metric in metrics) {
      if (targetLength <= covered + metric.length) {
        final tangent = metric.getTangentForOffset(targetLength - covered);
        if (tangent != null) {
          _drawTransportIcon(canvas, tangent.position, tangent.angle);
        }
        break;
      }
      covered += metric.length;
    }
  }

  void _drawTransportIcon(Canvas canvas, Offset position, double angle) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.drawCircle(Offset.zero, 14, Paint()..color = const Color(0xFFF4C95D));
    canvas.drawCircle(
        Offset.zero, 14, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

    final icon = transportIcon(mode);
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 15,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: const Color(0xFF073B4C),
        ),
      )
      ..layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      const dashLength = 7.0;
      const gapLength = 5.0;
      double distance = 0;
      while (distance < metric.length) {
        final next = min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter old) =>
      old.progress != progress || old.stopCount != stopCount || old.mode != mode;
}
