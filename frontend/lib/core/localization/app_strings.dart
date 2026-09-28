import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, hi, mr }

final appLanguageProvider = StateProvider<AppLanguage>((ref) => AppLanguage.en);

class AppStrings {
  static const Map<String, Map<AppLanguage, String>> _values = {
    // ── Brand & Navigation ───────────────────────────────────────────────────
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
    'nav_home': {
      AppLanguage.en: 'Home',
      AppLanguage.hi: 'होम',
      AppLanguage.mr: 'मुख्य',
    },
    'nav_categories': {
      AppLanguage.en: 'Categories',
      AppLanguage.hi: 'श्रेणियाँ',
      AppLanguage.mr: 'प्रवर्ग',
    },
    'nav_offers': {
      AppLanguage.en: 'Offers',
      AppLanguage.hi: 'ऑफ़र्स',
      AppLanguage.mr: 'ऑफर',
    },
    'nav_orders': {
      AppLanguage.en: 'Orders',
      AppLanguage.hi: 'ऑर्डर्स',
      AppLanguage.mr: 'ऑर्डर्स',
    },
    'nav_profile': {
      AppLanguage.en: 'Profile',
      AppLanguage.hi: 'प्रोफ़ाइल',
      AppLanguage.mr: 'माझे खाते',
    },
    'storefront': {
      AppLanguage.en: 'Storefront',
      AppLanguage.hi: 'दुकान',
      AppLanguage.mr: 'दुकान',
    },

    // ── Search & Placeholders ────────────────────────────────────────────────
    'search_plants': {
      AppLanguage.en: 'Search plants, fertilizers, pots...',
      AppLanguage.hi: 'पौधे, खाद, गमले खोजें...',
      AppLanguage.mr: 'रोपे, खते, कुंड्या शोधा...',
    },
    'search_marketplace_hint': {
      AppLanguage.en: 'Search nurseries, crops (Chilli, Tomato), varieties...',
      AppLanguage.hi: 'नर्सरी, फसलें (मिर्च, टमाटर), किस्में खोजें...',
      AppLanguage.mr: 'नर्सरी, पिके (मिरची, टोमॅटो), वाण शोधा...',
    },
    'search_results_title': {
      AppLanguage.en: 'Search Results',
      AppLanguage.hi: 'खोज परिणाम',
      AppLanguage.mr: 'शोध निकाल',
    },
    'search_type_crop': {
      AppLanguage.en: 'CROP',
      AppLanguage.hi: 'फसल',
      AppLanguage.mr: 'पीक',
    },
    'search_type_variety': {
      AppLanguage.en: 'VARIETY',
      AppLanguage.hi: 'किस्म',
      AppLanguage.mr: 'वाण',
    },
    'search_type_nursery': {
      AppLanguage.en: 'NURSERY',
      AppLanguage.hi: 'नर्सरी',
      AppLanguage.mr: 'नर्सरी',
    },

    // ── Availability & Stock Statuses (Issue #12, #23) ───────────────────────
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
    'ready_now': {
      AppLanguage.en: 'READY NOW',
      AppLanguage.hi: 'तत्काल उपलब्ध',
      AppLanguage.mr: 'आत्ताच उपलब्ध',
    },
    'ready_stock': {
      AppLanguage.en: 'Ready Stock',
      AppLanguage.hi: 'उपलब्ध स्टॉक',
      AppLanguage.mr: 'तयार साठा',
    },
    'limited_stock': {
      AppLanguage.en: 'LIMITED STOCK',
      AppLanguage.hi: 'सीमित स्टॉक',
      AppLanguage.mr: 'मर्यादित साठा',
    },
    'coming_soon': {
      AppLanguage.en: 'COMING SOON',
      AppLanguage.hi: 'जल्द आ रहा है',
      AppLanguage.mr: 'लवकरच येत आहे',
    },
    'prebook_available': {
      AppLanguage.en: 'PRE-BOOK AVAILABLE',
      AppLanguage.hi: 'प्री-बुकिंग उपलब्ध',
      AppLanguage.mr: 'पूर्व-नोंदणी उपलब्ध',
    },
    'sold_out': {
      AppLanguage.en: 'SOLD OUT',
      AppLanguage.hi: 'बिक चुका है',
      AppLanguage.mr: 'विक्री पूर्ण',
    },
    'immediate_dispatch': {
      AppLanguage.en: 'Immediate Dispatch',
      AppLanguage.hi: 'तुरंत प्रेषण',
      AppLanguage.mr: 'त्वरित पाठवणे',
    },
    'next_batch': {
      AppLanguage.en: 'Next Batch',
      AppLanguage.hi: 'अगला बैच',
      AppLanguage.mr: 'पुढील बॅच',
    },
    'expected_restock': {
      AppLanguage.en: 'Expected Restock',
      AppLanguage.hi: 'अपेक्षित पुनः स्टॉक',
      AppLanguage.mr: 'पुन्हा उपलब्ध होण्याची तारीख',
    },
    'expected_dispatch': {
      AppLanguage.en: 'Expected Dispatch',
      AppLanguage.hi: 'अपेक्षित प्रेषण',
      AppLanguage.mr: 'पाठवण्याची अंदाजे तारीख',
    },

    // ── CTAs & Actions ───────────────────────────────────────────────────────
    'add_to_cart': {
      AppLanguage.en: 'Add to Cart',
      AppLanguage.hi: 'कार्ट में जोड़ें',
      AppLanguage.mr: 'कार्टमध्ये जोडा',
    },
    'buy_now': {
      AppLanguage.en: 'Buy Now',
      AppLanguage.hi: 'अभी खरीदें',
      AppLanguage.mr: 'आत्ता खरेदी करा',
    },
    'prebook_now': {
      AppLanguage.en: 'Pre-Book Now',
      AppLanguage.hi: 'प्री-बुक करें',
      AppLanguage.mr: 'आत्ता नोंदवा',
    },
    'notify_me': {
      AppLanguage.en: 'Notify Me',
      AppLanguage.hi: 'सूचित करें',
      AppLanguage.mr: 'सूचना द्या',
    },
    'view_details': {
      AppLanguage.en: 'View Details',
      AppLanguage.hi: 'विवरण देखें',
      AppLanguage.mr: 'तपशील पहा',
    },
    'browse': {
      AppLanguage.en: 'Browse',
      AppLanguage.hi: 'ब्राउज़ करें',
      AppLanguage.mr: 'पहा',
    },
    'compare_nurseries': {
      AppLanguage.en: 'Available at Other Regional Nurseries',
      AppLanguage.hi: 'अन्य क्षेत्रीय नर्सरियों में उपलब्ध',
      AppLanguage.mr: 'इतर प्रादेशिक नर्सरींमध्ये उपलब्ध',
    },
    'change_nursery': {
      AppLanguage.en: 'Change Nursery',
      AppLanguage.hi: 'नर्सरी बदलें',
      AppLanguage.mr: 'नर्सरी बदला',
    },
    'view_cart': {
      AppLanguage.en: 'View Cart',
      AppLanguage.hi: 'कार्ट देखें',
      AppLanguage.mr: 'कार्ट पहा',
    },
    'clear_filter': {
      AppLanguage.en: 'Show All Crops',
      AppLanguage.hi: 'सभी फसलें देखें',
      AppLanguage.mr: 'सर्व पिके पहा',
    },
    'reset_filters': {
      AppLanguage.en: 'Reset All Filters',
      AppLanguage.hi: 'फ़िल्टर हटाएं',
      AppLanguage.mr: 'सर्व फिल्टर काढा',
    },
    'open_now': {
      AppLanguage.en: 'Open Now',
      AppLanguage.hi: 'खुला है',
      AppLanguage.mr: 'सुरू आहे',
    },
    'closed': {
      AppLanguage.en: 'Closed',
      AppLanguage.hi: 'बंद है',
      AppLanguage.mr: 'बंद आहे',
    },
    'trust': {
      AppLanguage.en: 'Trust',
      AppLanguage.hi: 'विश्वास',
      AppLanguage.mr: 'विश्वासू',
    },
    'view_all': {
      AppLanguage.en: 'View All',
      AppLanguage.hi: 'सभी देखें',
      AppLanguage.mr: 'सर्व पहा',
    },

    // ── Pricing Tiers & Units ────────────────────────────────────────────────
    'pricing_tiers': {
      AppLanguage.en: 'Commercial Pricing Tiers',
      AppLanguage.hi: 'वाणिज्यिक मूल्य निर्धारण',
      AppLanguage.mr: 'व्यावसायिक दर रचना',
    },
    'per_plant': {
      AppLanguage.en: 'Per Plant',
      AppLanguage.hi: 'प्रति पौधा',
      AppLanguage.mr: 'प्रति रोप',
    },
    'pro_tray': {
      AppLanguage.en: 'Pro-Tray',
      AppLanguage.hi: 'प्रो-ट्रे',
      AppLanguage.mr: 'प्रो-ट्रे',
    },
    'bulk_qty': {
      AppLanguage.en: 'Bulk Quantity',
      AppLanguage.hi: 'थोक मात्रा',
      AppLanguage.mr: 'मोठा साठा / घाऊक',
    },
    'tray_capacity': {
      AppLanguage.en: 'Configured Tray Capacity',
      AppLanguage.hi: 'ट्रे क्षमता',
      AppLanguage.mr: 'ट्रेमधील रोपांची संख्या',
    },

    // ── Homepage Sections ────────────────────────────────────────────────────
    'special_offers': {
      AppLanguage.en: 'Farmer Special Offers & Campaigns',
      AppLanguage.hi: 'किसान विशेष ऑफ़र्स व अभियान',
      AppLanguage.mr: 'शेतकरी विशेष ऑफर आणि योजना',
    },
    'live_production': {
      AppLanguage.en: 'Live Nursery Production',
      AppLanguage.hi: 'लाइव नर्सरी उत्पादन',
      AppLanguage.mr: 'थेट नर्सरी उत्पादन प्रसारण',
    },
    'participating_nurseries': {
      AppLanguage.en: 'Participating / Nearby Nurseries',
      AppLanguage.hi: 'भागीदार / निकटतम नर्सरियां',
      AppLanguage.mr: 'सहभागी व जवळच्या नर्सरी',
    },
    'explore_categories': {
      AppLanguage.en: 'Explore Plant Categories',
      AppLanguage.hi: 'पौधों की श्रेणियाँ देखें',
      AppLanguage.mr: 'रोपांचे प्रकार',
    },
    'popular_crops': {
      AppLanguage.en: 'Popular Agricultural Crops (Nashik Region)',
      AppLanguage.hi: 'प्रमुख कृषि फसलें (नासिक क्षेत्र)',
      AppLanguage.mr: 'प्रमुख शेती पिके (नाशिक विभाग)',
    },
    'featured_varieties': {
      AppLanguage.en: 'Featured Varieties',
      AppLanguage.hi: 'प्रमुख किस्में',
      AppLanguage.mr: 'खास शिफारस केलेले वाण',
    },
    'farming_guides': {
      AppLanguage.en: 'Verified Farming Practices & Crop Schedules',
      AppLanguage.hi: 'प्रमाणित कृषि पद्धतियाँ व फसल समय-सारणी',
      AppLanguage.mr: 'कृषी मार्गदर्शक व लागवड वेळापत्रक',
    },
    'ready_stock_trays': {
      AppLanguage.en: 'Ready Stock (Immediate Dispatch Trays)',
      AppLanguage.hi: 'उपलब्ध स्टॉक (तुरंत प्रेषण ट्रे)',
      AppLanguage.mr: 'तयार साठा (त्वरित पाठवण्यासाठी ट्रे)',
    },
    'prebooking_upcoming': {
      AppLanguage.en: 'Pre-booking Upcoming Batches',
      AppLanguage.hi: 'आगामी बैच की प्री-बुकिंग',
      AppLanguage.mr: 'आगामी बॅचसाठी पूर्व-नोंदणी',
    },

    // ── Field Agronomy & Guidance ────────────────────────────────────────────
    'agronomy_title': {
      AppLanguage.en: 'Field Agronomy & Growing Information',
      AppLanguage.hi: 'कृषि विज्ञान और फसल जानकारी',
      AppLanguage.mr: 'कृषी तंत्रज्ञान व लागवड मार्गदर्शन',
    },
    'season': {
      AppLanguage.en: 'Season',
      AppLanguage.hi: 'मौसम',
      AppLanguage.mr: 'हंगाम',
    },
    'temperature': {
      AppLanguage.en: 'Temperature',
      AppLanguage.hi: 'तापमान',
      AppLanguage.mr: 'तापमान',
    },
    'watering': {
      AppLanguage.en: 'Water Requirement',
      AppLanguage.hi: 'पानी की आवश्यकता',
      AppLanguage.mr: 'पाण्याची गरज',
    },
    'sunlight': {
      AppLanguage.en: 'Sunlight',
      AppLanguage.hi: 'सूर्यप्रकाश',
      AppLanguage.mr: 'सूर्यप्रकाश',
    },
    'soil': {
      AppLanguage.en: 'Soil Type',
      AppLanguage.hi: 'मिट्टी का प्रकार',
      AppLanguage.mr: 'जमिनीचा प्रकार',
    },
    'transplanting': {
      AppLanguage.en: 'Transplanting Age',
      AppLanguage.hi: 'रोपाई की आयु',
      AppLanguage.mr: 'पुनर्लागवडीचे वय',
    },
    'spacing': {
      AppLanguage.en: 'Field Spacing',
      AppLanguage.hi: 'खेत में दूरी',
      AppLanguage.mr: 'लागवडीचे अंतर',
    },
    'expected_yield': {
      AppLanguage.en: 'Expected Yield',
      AppLanguage.hi: 'अपेक्षित उत्पादन',
      AppLanguage.mr: 'अपेक्षित उत्पादन',
    },
    'harvest_days': {
      AppLanguage.en: 'Days to Harvest',
      AppLanguage.hi: 'कटाई के दिन',
      AppLanguage.mr: 'काढणीचा कालावधी',
    },
    'basic_care': {
      AppLanguage.en: 'Basic Field Care',
      AppLanguage.hi: 'बुनियादी देखभाल',
      AppLanguage.mr: 'मूलभूत पीक काळजी',
    },
    'fertilizer': {
      AppLanguage.en: 'Fertilizer',
      AppLanguage.hi: 'खाद',
      AppLanguage.mr: 'खत व पोषण',
    },
    'care_instructions': {
      AppLanguage.en: 'Plant Care Instructions',
      AppLanguage.hi: 'पौधे की देखभाल निर्देश',
      AppLanguage.mr: 'रोपांची काळजी घेण्याच्या सूचना',
    },

    // ── Cart & Checkout ──────────────────────────────────────────────────────
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

    // ── Orders & Invoices ────────────────────────────────────────────────────
    'orders': {
      AppLanguage.en: 'Orders',
      AppLanguage.hi: 'ऑर्डर्स',
      AppLanguage.mr: 'ऑर्डर्स',
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
    'invoice_pdf': {
      AppLanguage.en: 'Invoice PDF',
      AppLanguage.hi: 'इनवॉइस पीडीएफ',
      AppLanguage.mr: 'बीजक पीडीएफ',
    },

    // ── Dashboard & Feedback ─────────────────────────────────────────────────
    'dashboard': {
      AppLanguage.en: 'Dashboard',
      AppLanguage.hi: 'डैशबोर्ड',
      AppLanguage.mr: 'डॅशबोर्ड',
    },
    'inventory': {
      AppLanguage.en: 'Inventory',
      AppLanguage.hi: 'स्टॉक / इन्वेंटरी',
      AppLanguage.mr: 'साठा / इन्व्हेंटरी',
    },
    'network_issue_title': {
      AppLanguage.en: 'Network Connection Issue',
      AppLanguage.hi: 'नेटवर्क कनेक्शन समस्या',
      AppLanguage.mr: 'नेटवर्क कनेक्शन समस्या',
    },
    'network_issue_msg': {
      AppLanguage.en: 'Unable to connect to nursery network. Please check your mobile data / Wi-Fi and try again.',
      AppLanguage.hi: 'सर्वर से कनेक्ट करने में असमर्थ। कृपया अपना इंटरनेट जांचें और पुनः प्रयास करें।',
      AppLanguage.mr: 'नर्सरी नेटवर्कशी संपर्क होऊ शकला नाही. कृपया इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.',
    },
    'try_again': {
      AppLanguage.en: 'Try Again',
      AppLanguage.hi: 'पुनः प्रयास करें',
      AppLanguage.mr: 'पुन्हा प्रयत्न करा',
    },
    'pending_process': {
      AppLanguage.en: 'Pending Process',
      AppLanguage.hi: 'लंबित प्रक्रिया',
      AppLanguage.mr: 'प्रलंबित प्रक्रिया',
    },
    'retrying': {
      AppLanguage.en: 'Connecting & resuming...',
      AppLanguage.hi: 'पुनः प्रयास हो रहा है...',
      AppLanguage.mr: 'पुन्हा कनेक्ट करत आहे...',
    },
    'cancel': {
      AppLanguage.en: 'Cancel',
      AppLanguage.hi: 'रद्द करें',
      AppLanguage.mr: 'रद्द करा',
    },
    'no_varieties_found': {
      AppLanguage.en: 'No varieties found matching criteria',
      AppLanguage.hi: 'कोई किस्म नहीं मिली',
      AppLanguage.mr: 'कोणतेही वाण सापडले नाही',
    },
    'calendar_farmer_title': {
      AppLanguage.en: 'Farm Calendar & Dispatch Schedule',
      AppLanguage.hi: 'कृषि कैलेंडर एवं प्रेषण अनुसूची',
      AppLanguage.mr: 'कृषी दिनदर्शिका व प्रेषण वेळापत्रक',
    },
    'calendar_owner_title': {
      AppLanguage.en: 'Nursery Production & Dispatch Calendar',
      AppLanguage.hi: 'नर्सरी उत्पादन एवं प्रेषण कैलेंडर',
      AppLanguage.mr: 'नर्सरी उत्पादन व प्रेषण दिनदर्शिका',
    },
    'today': {
      AppLanguage.en: 'Today',
      AppLanguage.hi: 'आज',
      AppLanguage.mr: 'आज',
    },
    'upcoming': {
      AppLanguage.en: 'Upcoming',
      AppLanguage.hi: 'आगामी',
      AppLanguage.mr: 'आगामी',
    },
    'upcoming_schedule': {
      AppLanguage.en: 'Upcoming Schedule',
      AppLanguage.hi: 'आगामी कार्यक्रम',
      AppLanguage.mr: 'आगामी वेळापत्रक',
    },
    'month_view': {
      AppLanguage.en: 'Month View',
      AppLanguage.hi: 'माह दृश्य',
      AppLanguage.mr: 'महिना दृश्य',
    },
    'schedule_for': {
      AppLanguage.en: 'Schedule for',
      AppLanguage.hi: 'कार्यक्रम:',
      AppLanguage.mr: 'वेळापत्रक:',
    },
    'no_events_on_date': {
      AppLanguage.en: 'No nursery dispatches or offer deadlines on this date.',
      AppLanguage.hi: 'इस तारीख के लिए कोई प्रेषण या ऑफर निर्धारित नहीं है।',
      AppLanguage.mr: 'या तारखेसाठी कोणतेही प्रेषण किंवा ऑफर नियोजित नाही.',
    },
    'event_offer': {
      AppLanguage.en: 'Offer',
      AppLanguage.hi: 'ऑफर',
      AppLanguage.mr: 'ऑफर',
    },
    'event_delivery': {
      AppLanguage.en: 'Delivery',
      AppLanguage.hi: 'वितरण',
      AppLanguage.mr: 'वितरण',
    },
    'event_production': {
      AppLanguage.en: 'Production Batch',
      AppLanguage.hi: 'उत्पादन बैच',
      AppLanguage.mr: 'उत्पादन बॅच',
    },
    'event_prebooking': {
      AppLanguage.en: 'Pre-booking',
      AppLanguage.hi: 'प्री-बुकिंग',
      AppLanguage.mr: 'पूर्व-नोंदणी',
    },
    'event_order': {
      AppLanguage.en: 'Order',
      AppLanguage.hi: 'ऑर्डर',
      AppLanguage.mr: 'ऑर्डर',
    },
    'event_agronomy': {
      AppLanguage.en: 'Agri Advisory',
      AppLanguage.hi: 'कृषि सलाह',
      AppLanguage.mr: 'कृषी सल्ला',
    },
    'live_ist': {
      AppLanguage.en: 'LIVE IST',
      AppLanguage.hi: 'लाइव IST',
      AppLanguage.mr: 'थेट IST',
    },
  };

  static String get(String key, AppLanguage lang) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry[AppLanguage.en] ?? key;
  }
}
