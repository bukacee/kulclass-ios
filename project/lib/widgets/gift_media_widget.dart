import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class GiftMediaWidget extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const GiftMediaWidget({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
  });

  bool get _isLottie => url.toLowerCase().endsWith('.json');
  bool get _isSvg => url.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isLottie) {
      return Lottie.network(
        url,
        fit: fit,
      );
    }

    if (_isSvg) {
      return SvgPicture.network(
        url,
        fit: fit,
      );
    }

    return Image.network(
      url,
      fit: fit,
    );
  }
}
