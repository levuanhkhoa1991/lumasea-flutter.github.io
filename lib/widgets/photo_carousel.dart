import 'package:flutter/material.dart';

/// A swipeable photo carousel with animated dot page indicators.
///
/// Each image is loaded from the network. If an image fails to load
/// (e.g. no internet connection on the device running the app), it
/// falls back to a soft icon placeholder instead of a broken-image icon,
/// so the UI never looks broken.
class PhotoCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final IconData fallbackIcon;
  final double height;
  final BorderRadius borderRadius;

  const PhotoCarousel({
    super.key,
    required this.imageUrls,
    required this.fallbackIcon,
    this.height = 180,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        child: Stack(children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => Image.network(
              widget.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFDFF6FA),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF0E7490)),
                  ),
                );
              },
              errorBuilder: (context, error, stack) => Container(
                color: const Color(0xFFDFF6FA),
                alignment: Alignment.center,
                child: Icon(widget.fallbackIcon,
                    color: const Color(0xFF0E7490), size: 34),
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
