import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avrgreen/core/models/image_metadata.dart';
import 'package:avrgreen/core/widgets/app_product_image.dart';
import 'package:avrgreen/features/catalog/data/providers/catalog_provider.dart';

void main() {
  group('Realistic Product Image System Tests', () {
    test('Image Metadata Registry contains valid provenance for all registered assets', () {
      expect(ImageMetadataRegistry.allMetadata.isNotEmpty, isTrue);

      for (final entry in ImageMetadataRegistry.allMetadata.entries) {
        final path = entry.key;
        final meta = entry.value;

        expect(path, startsWith('assets/images/'));
        expect(meta.crop.isNotEmpty, isTrue);
        expect(meta.title.isNotEmpty, isTrue);
        expect(meta.stage.isNotEmpty, isTrue);
        expect(meta.license.isNotEmpty, isTrue);
        expect(meta.source.isNotEmpty, isTrue);
        expect(meta.isVerifiedAuthentic, isTrue);
      }
    });

    test('All bundled product assets physically exist on disk', () {
      for (final path in ImageMetadataRegistry.allMetadata.keys) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Asset must physically exist: $path');
      }
    });

    test('Every product in defaultBotanicalCatalog maps to an authentic, distinct asset without cross-crop mismatch', () {
      final cropsSeen = <String, String>{};

      for (final product in defaultBotanicalCatalog) {
        final asset = product.primaryImageAsset;
        expect(asset, startsWith('assets/images/products/'));

        final file = File(asset);
        expect(file.existsSync(), isTrue, reason: 'Product ${product.commonName} asset missing: $asset');

        // Check that crops map to their own dedicated agricultural photography
        if (product.crop == 'Tomato') {
          expect(asset, contains('tomato'));
        } else if (product.crop == 'Chilli') {
          expect(asset, contains('green_chilli'));
        } else if (product.crop == 'Capsicum') {
          expect(asset, contains('capsicum'));
        } else if (product.crop == 'Brinjal') {
          expect(asset, contains('brinjal'));
        } else if (product.crop == 'Marigold') {
          expect(asset, contains('marigold'));
        } else if (product.crop == 'Chrysanthemum') {
          expect(asset, contains('chrysanthemum'));
        } else if (product.crop == 'Rose') {
          expect(asset, contains('rose'));
        } else if (product.crop == 'Mango') {
          expect(asset, contains('mango'));
        } else if (product.crop == 'Guava') {
          expect(asset, contains('guava'));
        } else if (product.crop == 'Lemon') {
          expect(asset, contains('lemon'));
        } else if (product.crop == 'Ashwagandha') {
          expect(asset, contains('ashwagandha'));
        } else if (product.crop == 'Aloe Vera') {
          expect(asset, contains('aloe_vera'));
        } else if (product.crop == 'Tulsi') {
          expect(asset, contains('tulsi'));
        } else if (product.crop == 'Areca Palm') {
          expect(asset, contains('areca_palm'));
        } else if (product.crop == 'Nursery Trays') {
          expect(asset, contains('nursery_trays'));
        } else if (product.crop == 'Organic Fertilizers') {
          expect(asset, contains('organic_fertilizer'));
        }

        cropsSeen[product.crop] = asset;
      }

      // Verify that major agricultural crops have their own distinct assets
      expect(cropsSeen['Tomato'], isNot(equals(cropsSeen['Chilli'])));
      expect(cropsSeen['Tomato'], isNot(equals(cropsSeen['Marigold'])));
      expect(cropsSeen['Marigold'], isNot(equals(cropsSeen['Chrysanthemum'])));
      expect(cropsSeen['Mango'], isNot(equals(cropsSeen['Guava'])));
    });

    test('Product gallery images returns multi-perspective assets', () {
      final tomatoProduct = defaultBotanicalCatalog.firstWhere((p) => p.crop == 'Tomato');
      final gallery = tomatoProduct.galleryImages;

      expect(gallery.length, greaterThanOrEqualTo(2));
      expect(gallery.first, contains('tomato'));
      expect(gallery.contains('assets/images/products/nursery_trays.jpg'), isTrue);
    });

    testWidgets('AppProductImage renders card variant and fallback without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: 180,
                    child: AppProductImage.card(
                      imageUrl: 'assets/images/products/tomato.jpg',
                      cropName: 'Tomato',
                    ),
                  ),
                  AppProductImage.thumbnail(
                    imageUrl: 'assets/images/non_existent.jpg',
                    cropName: 'Tomato',
                    size: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AppProductImage), findsNWidgets(2));
    });

    testWidgets('AppProductImage nursery variants render properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AppProductImage.nurseryCover(
                    imageUrl: 'assets/images/nursery_hero_banner.jpg',
                    height: 80,
                  ),
                  AppProductImage.nurseryAvatar(
                    imageUrl: 'assets/images/nursery_hero_banner.jpg',
                    size: 44,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AppProductImage), findsNWidgets(2));
    });
  });
}
