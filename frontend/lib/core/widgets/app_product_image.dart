import 'package:flutter/material.dart';
import 'package:avrgreen/core/theme/app_theme.dart';
import 'package:avrgreen/core/models/image_metadata.dart';

enum AppProductImageType {
  thumbnail,
  card,
  hero,
  galleryThumb,
  nurseryCover,
  nurseryAvatar,
}

/// Reusable, high-performance agricultural product image component.
/// Enforces compact marketplace image aspect ratios, memory cache limits,
/// verified botanical fallback badges, and metadata provenance.
class AppProductImage extends StatelessWidget {
  final String imagePath;
  final String? fallbackCrop;
  final AppProductImageType type;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool showVerifiedBadge;
  final VoidCallback? onTap;

  const AppProductImage({
    super.key,
    required this.imagePath,
    this.fallbackCrop,
    this.type = AppProductImageType.card,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.showVerifiedBadge = false,
    this.onTap,
  });

  /// Quick factory for Compact Marketplace Product Cards
  factory AppProductImage.card({
    String? imagePath,
    String? imageUrl,
    String? crop,
    String? cropName,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    bool showVerifiedBadge = false,
    VoidCallback? onTap,
  }) {
    return AppProductImage(
      imagePath: imagePath ?? imageUrl ?? 'assets/images/products/tomato.jpg',
      fallbackCrop: crop ?? cropName,
      type: AppProductImageType.card,
      width: width,
      height: height,
      borderRadius: borderRadius ?? const BorderRadius.vertical(top: Radius.circular(10)),
      showVerifiedBadge: showVerifiedBadge,
      onTap: onTap,
    );
  }

  /// Quick factory for Product Detail Hero Section (Max 260dp)
  factory AppProductImage.hero({
    String? imagePath,
    String? imageUrl,
    String? crop,
    String? cropName,
    double height = 260,
    VoidCallback? onTap,
  }) {
    return AppProductImage(
      imagePath: imagePath ?? imageUrl ?? 'assets/images/products/tomato.jpg',
      fallbackCrop: crop ?? cropName,
      type: AppProductImageType.hero,
      height: height,
      borderRadius: BorderRadius.zero,
      showVerifiedBadge: true,
      onTap: onTap,
    );
  }

  /// Quick factory for Compact Thumbnails (Cart, Orders, List Views)
  factory AppProductImage.thumbnail({
    String? imagePath,
    String? imageUrl,
    String? crop,
    String? cropName,
    double size = 52,
    BorderRadius? borderRadius,
  }) {
    return AppProductImage(
      imagePath: imagePath ?? imageUrl ?? 'assets/images/products/tomato.jpg',
      fallbackCrop: crop ?? cropName,
      type: AppProductImageType.thumbnail,
      width: size,
      height: size,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }

  /// Quick factory for Gallery Selectable Thumbnails
  factory AppProductImage.galleryThumb({
    String? imagePath,
    String? imageUrl,
    bool isSelected = false,
    double size = 48,
    VoidCallback? onTap,
  }) {
    return AppProductImage(
      imagePath: imagePath ?? imageUrl ?? 'assets/images/products/tomato.jpg',
      type: AppProductImageType.galleryThumb,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
    );
  }

  /// Quick factory for Nursery Cover Banners
  factory AppProductImage.nurseryCover({
    String? imagePath,
    String? imageUrl,
    double height = 140,
    BorderRadius? borderRadius,
  }) {
    return AppProductImage(
      imagePath: imagePath ?? imageUrl ?? 'assets/images/nursery_hero_banner.jpg',
      type: AppProductImageType.nurseryCover,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
    );
  }

  /// Quick factory for Nursery Avatars / Discovery Cards
  factory AppProductImage.nurseryAvatar({
    String? imagePath,
    String? imageUrl,
    double size = 48,
    BorderRadius? borderRadius,
  }) {
    return AppProductImage(
      imagePath: imagePath ?? imageUrl ?? 'assets/images/nursery_hero_banner.jpg',
      type: AppProductImageType.nurseryAvatar,
      width: size,
      height: size,
      borderRadius: borderRadius ?? BorderRadius.circular(10),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (type) {
      case AppProductImageType.card:
        content = AspectRatio(
          aspectRatio: 1.35,
          child: _buildImageCore(context, cacheWidth: 400),
        );
        break;
      case AppProductImageType.hero:
        content = SizedBox(
          height: height ?? 260,
          width: double.infinity,
          child: _buildImageCore(context, cacheWidth: 800),
        );
        break;
      case AppProductImageType.thumbnail:
        content = SizedBox(
          width: width ?? 52,
          height: height ?? 52,
          child: _buildImageCore(context, cacheWidth: 150),
        );
        break;
      case AppProductImageType.galleryThumb:
        content = SizedBox(
          width: width ?? 48,
          height: height ?? 48,
          child: _buildImageCore(context, cacheWidth: 150),
        );
        break;
      case AppProductImageType.nurseryCover:
        content = SizedBox(
          height: height ?? 140,
          width: double.infinity,
          child: _buildImageCore(context, cacheWidth: 600),
        );
        break;
      case AppProductImageType.nurseryAvatar:
        content = SizedBox(
          width: width ?? 48,
          height: height ?? 48,
          child: _buildImageCore(context, cacheWidth: 150),
        );
        break;
    }

    if (showVerifiedBadge) {
      content = Stack(
        children: [
          content,
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => showImageProvenance(context, imagePath),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.lightGreenAccent, size: 11),
                    SizedBox(width: 3),
                    Text(
                      'Verified Asset',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }

  Widget _buildImageCore(BuildContext context, {int? cacheWidth}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (ctx, err, stack) => _buildGracefulFallback(),
      );
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (ctx, err, stack) => _buildGracefulFallback(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AVRColors.sageSurface,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AVRColors.forestGreen.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }

  Widget _buildGracefulFallback() {
    final isCompact = (height != null && height! <= 72) || (width != null && width! <= 72);

    return Container(
      width: width,
      height: height,
      color: AVRColors.forestGreenSurface,
      padding: EdgeInsets.all(isCompact ? 4 : 6),
      child: Center(
        child: isCompact
            ? Icon(
                _getCropIcon(fallbackCrop),
                size: ((height ?? width ?? 48) * 0.45).clamp(16.0, 26.0),
                color: AVRColors.forestGreen,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getCropIcon(fallbackCrop), size: 28, color: AVRColors.forestGreen.withValues(alpha: 0.8)),
                  const SizedBox(height: 3),
                  Text(
                    fallbackCrop ?? 'Nursery Variety',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: AVRColors.forestGreenDark,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Verified Stock',
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
                  ),
                ],
              ),
      ),
    );
  }

  IconData _getCropIcon(String? crop) {
    if (crop == null) return Icons.eco_rounded;
    final s = crop.toLowerCase();
    if (s.contains('tomat') || s.contains('fruit')) return Icons.nature_rounded;
    if (s.contains('chil') || s.contains('caps')) return Icons.local_florist_rounded;
    if (s.contains('rose') || s.contains('flower') || s.contains('marigold')) return Icons.filter_vintage_rounded;
    if (s.contains('tree') || s.contains('mango') || s.contains('guava')) return Icons.park_rounded;
    return Icons.eco_rounded;
  }

  /// Opens bottom sheet showcasing genuine agricultural metadata & provenance
  static void showImageProvenance(BuildContext context, String assetPath) {
    final meta = ImageMetadataRegistry.getMetadata(assetPath);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AVRColors.forestGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Agricultural Photo Provenance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AVRColors.forestGreenDark),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AVRColors.forestGreenSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AVRColors.forestGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Authentic', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AVRColors.forestGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetaRow('Crop / Variety', meta.crop),
              _buildMetaRow('Image Subject', meta.title),
              _buildMetaRow('Growth Stage', meta.stage),
              _buildMetaRow('Registered Source', meta.source),
              _buildMetaRow('Licensing', meta.license),
              _buildMetaRow('Quality Standard', meta.resolution),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AVRColors.forestGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close Verification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AVRColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AVRColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
