import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FallbackNetworkImage extends StatefulWidget {
  const FallbackNetworkImage({
    super.key,
    required this.urls,
    this.width,
    this.height,
    this.fit,
    this.radius,
    this.placeholder,
    this.fallback,
  }) : assert(urls.length > 0, 'Provide at least one URL');

  final List<String> urls;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double? radius;
  final Widget? placeholder;
  final Widget? fallback;

  @override
  State<FallbackNetworkImage> createState() => _FallbackNetworkImageState();
}

class _FallbackNetworkImageState extends State<FallbackNetworkImage> {
  int _index = 0;
  bool _switchScheduled = false;

  void _nextUrl() {
    if (_switchScheduled || _index >= widget.urls.length - 1) return;
    _switchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _index++;
        _switchScheduled = false;
      });
    });
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) return widget.placeholder!;
    final w = widget.width ?? 48;
    final h = widget.height ?? w;
    final size = math.min(w, h) * 0.4;
    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: SizedBox(
          width: size.clamp(16, 48),
          height: size.clamp(16, 48),
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == widget.urls.length - 1;

    Widget image = CachedNetworkImage(
      imageUrl: widget.urls[_index],
      width: widget.width,
      height: widget.height,
      fit: widget.fit ?? BoxFit.cover,
      placeholder: (_, __) => _buildPlaceholder(),
      errorWidget: (_, __, ___) {
        if (isLast) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child:
                widget.fallback ??
                const Center(child: Icon(Icons.broken_image, size: 40)),
          );
        }
        _nextUrl(); // programa el cambio para el siguiente frame
        return _buildPlaceholder();
      },
    );

    if ((widget.radius ?? 0) > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius!),
        child: image,
      );
    }

    return image;
  }
}
