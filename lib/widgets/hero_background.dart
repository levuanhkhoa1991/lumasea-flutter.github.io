import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Hero background for the top banner.
///
/// If `assets/videos/hero_wave.mp4` exists (and is declared under
/// `flutter: assets:` in pubspec.yaml) it plays that video on loop, muted,
/// as the background. If the file is missing — which is the default,
/// out-of-the-box state of this project — it automatically falls back to
/// an animated gradient with layered painted waves, so the hero always
/// looks alive with zero required assets.
///
/// To use a real video: drop an .mp4 file at `assets/videos/hero_wave.mp4`
/// (already declared in pubspec.yaml) and hot-restart the app.
class HeroBackground extends StatefulWidget {
  const HeroBackground({super.key});

  @override
  State<HeroBackground> createState() => _HeroBackgroundState();
}

class _HeroBackgroundState extends State<HeroBackground>
    with TickerProviderStateMixin {
  static const String _videoAsset = 'assets/videos/hero_wave.mp4';

  VideoPlayerController? _videoController;
  bool _videoReady = false;

  late final AnimationController _waveController;
  late final AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 7))
          ..repeat();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _tryLoadVideo();
  }

  Future<void> _tryLoadVideo() async {
    final controller = VideoPlayerController.asset(_videoAsset);
    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      setState(() {
        _videoController = controller;
        _videoReady = true;
      });
    } catch (_) {
      // No video asset present (or it failed to load) — silently keep
      // the animated canvas fallback. This is expected in the default
      // project state, so we don't surface any error to the user.
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _waveController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      if (_videoReady && _videoController != null)
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        )
      else
        AnimatedBuilder(
          animation: Listenable.merge([_waveController, _gradientController]),
          builder: (_, __) => Stack(fit: StackFit.expand, children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(const Color(0xFF67C9E8), const Color(0xFF8FE4F2),
                        _gradientController.value)!,
                    const Color(0xFF075985),
                    const Color(0xFF062C3A),
                  ],
                ),
              ),
            ),
            CustomPaint(painter: _LayeredWavePainter(_waveController.value)),
          ]),
        ),
      // Soft dark overlay so text stays readable whether it's the video
      // or the canvas fallback underneath.
      Container(color: Colors.black.withOpacity(.12)),
    ]);
  }
}

/// Three sine-wave layers moving at slightly different speeds and
/// opacities to fake water depth, purely with CustomPainter (no assets).
class _LayeredWavePainter extends CustomPainter {
  final double progress;
  _LayeredWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(canvas, size, progress * 1.0, 0.70, 0.05, Colors.white.withOpacity(.10));
    _drawWave(canvas, size, progress * 1.4 + 0.30, 0.76, 0.04, Colors.white.withOpacity(.15));
    _drawWave(canvas, size, progress * 0.7 + 0.60, 0.83, 0.035, Colors.white.withOpacity(.22));
  }

  void _drawWave(Canvas canvas, Size size, double phase, double baseHeight,
      double amplitude, Color color) {
    final paint = Paint()..color = color;
    final path = Path()..moveTo(0, size.height * baseHeight);
    for (double x = 0; x <= size.width; x += 6) {
      final t = x / size.width;
      final y = size.height * baseHeight +
          amplitude * size.height * sin((t * 2 * pi) + phase * 2 * pi);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LayeredWavePainter old) =>
      old.progress != progress;
}
