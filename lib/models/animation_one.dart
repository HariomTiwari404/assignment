import 'package:flutter/material.dart';

class AnimatedAddToCart extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final String image;
  final VoidCallback onAnimationComplete;

  const AnimatedAddToCart({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.image,
    required this.onAnimationComplete,
  });

  @override
  State<AnimatedAddToCart> createState() => _AnimatedAddToCartState();
}

class _AnimatedAddToCartState extends State<AnimatedAddToCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _sizeAnimation = Tween<double>(
      begin: 50.0,
      end: 20.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _positionAnimation.value;
        final size = _sizeAnimation.value;

        return Positioned(
          top: offset.dy,
          left: offset.dx,
          child: Opacity(
            opacity: 1.0 - _controller.value,
            child: Image.network(
              widget.image,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: size,
                  height: size,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 20),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
