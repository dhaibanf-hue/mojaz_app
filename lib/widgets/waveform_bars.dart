import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';

/// Animated waveform bars that pulse during audio playback.
/// Shows 4 bars that animate height randomly to simulate audio activity.
/// When paused, bars smoothly settle to a low resting height.
class WaveformBars extends StatefulWidget {
  final bool isPlaying;
  final Color? barColor;
  final double height;
  final double barWidth;

  const WaveformBars({
    super.key,
    required this.isPlaying,
    this.barColor,
    this.height = 32,
    this.barWidth = 4,
  });

  @override
  State<WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<WaveformBars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final _random = Random();

  // Each bar has slightly different timing for organic feel
  static const List<int> _durations = [600, 450, 520, 380];
  // Resting heights as fraction of total height
  static const List<double> _restHeights = [0.3, 0.2, 0.35, 0.25];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _durations[i]),
      );
    });

    _animations = List.generate(4, (i) {
      return Tween<double>(
        begin: _restHeights[i],
        end: 0.6 + _random.nextDouble() * 0.4, // 0.6 to 1.0
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeInOut,
      ));
    });

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      // Stagger start slightly for natural look
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      // Animate to rest position smoothly
      _controllers[i].animateTo(
        0.0, // Returns to begin value (rest height)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(WaveformBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        // Randomize new targets
        for (int i = 0; i < _animations.length; i++) {
          _animations[i] = Tween<double>(
            begin: _restHeights[i],
            end: 0.6 + _random.nextDouble() * 0.4,
          ).animate(CurvedAnimation(
            parent: _controllers[i],
            curve: Curves.easeInOut,
          ));
        }
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.barColor ?? AppColors.newPrimary;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (context, child) {
              final fraction = _animations[i].value;
              return Container(
                width: widget.barWidth,
                height: widget.height * fraction,
                margin: EdgeInsets.symmetric(horizontal: widget.barWidth * 0.4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.7 + fraction * 0.3),
                  borderRadius: BorderRadius.circular(widget.barWidth / 2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
