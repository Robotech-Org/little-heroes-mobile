import 'package:flutter/material.dart';

class LittleHeroesLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const LittleHeroesLoading({
    super.key,
    this.size = 80,
    this.color,
    this.message,
  });

  @override
  State<LittleHeroesLoading> createState() => _LittleHeroesLoadingState();
}

class _LittleHeroesLoadingState extends State<LittleHeroesLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Hero with cape
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cape
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: (_controller.value * 0.2),
                      child: Container(
                        width: widget.size * 0.7,
                        height: widget.size * 0.9,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.1),
                              color.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(widget.size * 0.3),
                            topRight: Radius.circular(widget.size * 0.3),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Shield/Superhero icon
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * _controller.value),
                      child: Container(
                        width: widget.size * 0.6,
                        height: widget.size * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color, color.withValues(alpha: 0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          size: widget.size * 0.35,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                // Star sparkles
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final angle = (index * 2.1) + (_controller.value * 3);
                      final distance = widget.size * 0.5;
                      final x = distance * (0.5 + 0.3 * _controller.value);
                      final y = distance * (0.5 + 0.3 * _controller.value);

                      return Positioned(
                        left: widget.size / 2 + x * (index == 0 ? 0.8 : -0.8),
                        top: widget.size / 2 - y * (index == 1 ? 0.8 : -0.8),
                        child: Icon(
                          Icons.star_rounded,
                          size: widget.size * 0.08,
                          color: Colors.white.withValues(
                            alpha: 0.5 + (0.5 * _controller.value),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // "Little Heroes" text with shimmer
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [color, color.withValues(alpha: 0.5), color],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: Text(
              'Little Heroes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (widget.message != null)
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

          const SizedBox(height: 16),

          // Pulsing dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPulsingDot(color, 0),
              const SizedBox(width: 8),
              _buildPulsingDot(color, 1),
              const SizedBox(width: 8),
              _buildPulsingDot(color, 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot(Color color, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.3;
        final value = (_controller.value + delay) % 1;
        final scale = 0.5 + (0.5 * value);
        final opacity = 0.3 + (0.7 * value);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}
