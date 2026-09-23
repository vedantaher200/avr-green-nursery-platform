import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, hi, mr }

final appLanguageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.en);

class AppStrings {
  static const Map<String, Map<AppLanguage, String>> _values = {
    'app_name': {
      AppLanguage.en: 'AVR Green Nursery',
      AppLanguage.hi: 'एवीआर ग्रीन नर्सरी',
      AppLanguage.mr: 'एव्हीआर ग्रीन नर्सरी',
    },
    'tagline': {
      AppLanguage.en: 'Grow healthy, live green',
      AppLanguage.hi: 'स्वस्थ उगाएं, हरा-भरा जिएं',
      AppLanguage.mr: 'निरोगी वाढवा, हिरवेगार जगा',
    },
    'storefront': {
      AppLanguage.en: 'Storefront',
      AppLanguage.hi: 'दुकान',
      AppLanguage.mr: 'दुकान',
    },
    'search_plants': {
      AppLanguage.en: 'Search plants, fertilizers, pots...',
      AppLanguage.hi: 'पौधे, खाद, गमले खोजें...',
      AppLanguage.mr: 'रोपे, खते, कुंड्या शोधा...',
    },
    'categories': {
      AppLanguage.en: 'Categories',
      AppLanguage.hi: 'श्रेणियाँ',
      AppLanguage.mr: 'प्रवर्ग',
    },
    'all_plants': {
      AppLanguage.en: 'All Plants',
      AppLanguage.hi: 'सभी पौधे',
      AppLanguage.mr: 'सर्व रोपे',
    },
    'add_to_cart': {
      AppLanguage.en: 'Add to Cart',
      AppLanguage.hi: 'कार्ट में जोड़ें',
      AppLanguage.mr: 'कार्टमध्ये जोडा',
    },
    'cart': {
      AppLanguage.en: 'My Cart',
      AppLanguage.hi: 'मेरी कार्ट',
      AppLanguage.mr: 'माझी कार्ट',
    },
    'checkout': {
      AppLanguage.en: 'Checkout',
      AppLanguage.hi: 'चेकआउट',
      AppLanguage.mr: 'तपासा आणि खरेदी करा',
    },
    'subtotal': {
      AppLanguage.en: 'Subtotal',
      AppLanguage.hi: 'उप-योग',
      AppLanguage.mr: 'उप-एकूण',
    },
    'gst': {
      AppLanguage.en: 'GST (18%)',
      AppLanguage.hi: 'जीएसटी (18%)',
      AppLanguage.mr: 'जीएसटी (18%)',
    },
    'delivery_fee': {
      AppLanguage.en: 'Delivery',
      AppLanguage.hi: 'डिलीवरी',
      AppLanguage.mr: 'डिलिव्हरी',
    },
    'total': {
      AppLanguage.en: 'Total Amount',
      AppLanguage.hi: 'कुल राशि',
      AppLanguage.mr: 'एकूण रक्कम',
    },
    'place_order': {
      AppLanguage.en: 'Place Order',
      AppLanguage.hi: 'ऑर्डर करें',
      AppLanguage.mr: 'ऑर्डर द्या',
    },
    'order_confirmed': {
      AppLanguage.en: 'Order Confirmed! 🌿',
      AppLanguage.hi: 'ऑर्डर स्वीकृत हुई! 🌿',
      AppLanguage.mr: 'ऑर्डर निश्चित झाली! 🌿',
    },
    'track_order': {
      AppLanguage.en: 'Track Order',
      AppLanguage.hi: 'ऑर्डर ट्रैक करें',
      AppLanguage.mr: 'ऑर्डर ट्रॅक करा',
    },
    'download_invoice': {
      AppLanguage.en: 'Download PDF Invoice',
      AppLanguage.hi: 'पीडीएफ इनवॉइस डाउनलोड करें',
      AppLanguage.mr: 'पीडीएफ बीजक डाउनलोड करा',
    },
    'care_instructions': {
      AppLanguage.en: 'Plant Care Instructions',
      AppLanguage.hi: 'पौधे की देखभाल निर्देश',
      AppLanguage.mr: 'रोपांची काळजी घेण्याच्या सूचना',
    },
    'sunlight': {
      AppLanguage.en: 'Sunlight',
      AppLanguage.hi: 'धूप',
      AppLanguage.mr: 'सूर्यप्रकाश',
    },
    'watering': {
      AppLanguage.en: 'Watering',
      AppLanguage.hi: 'पानी',
      AppLanguage.mr: 'पाणी',
    },
    'fertilizer': {
      AppLanguage.en: 'Fertilizer',
      AppLanguage.hi: 'खाद',
      AppLanguage.mr: 'खत',
    },
    'inventory': {
      AppLanguage.en: 'Inventory',
      AppLanguage.hi: 'स्टॉक / इन्वेंटरी',
      AppLanguage.mr: 'साठा / इन्व्हेंटरी',
    },
    'orders': {
      AppLanguage.en: 'Orders',
      AppLanguage.hi: 'ऑर्डर्स',
      AppLanguage.mr: 'ऑर्डर्स',
    },
    'dashboard': {
      AppLanguage.en: 'Dashboard',
      AppLanguage.hi: 'डैशबोर्ड',
      AppLanguage.mr: 'डॅशबोर्ड',
    },
    'in_stock': {
      AppLanguage.en: 'In Stock',
      AppLanguage.hi: 'स्टॉक में उपलब्ध',
      AppLanguage.mr: 'साठ्यात उपलब्ध',
    },
    'out_of_stock': {
      AppLanguage.en: 'Out of Stock',
      AppLanguage.hi: 'स्टॉक समाप्त',
      AppLanguage.mr: 'साठा संपला',
    },
  };

  static String get(String key, AppLanguage lang) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry[AppLanguage.en] ?? key;
  }
}
