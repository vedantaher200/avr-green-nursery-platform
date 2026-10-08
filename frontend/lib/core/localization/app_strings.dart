import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supported Languages & Locale Mapping
// ─────────────────────────────────────────────────────────────────────────────

enum AppLanguage { en, hi, mr }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
        AppLanguage.en => 'en',
        AppLanguage.hi => 'hi',
        AppLanguage.mr => 'mr',
      };

  String get label => switch (this) {
        AppLanguage.en => 'English',
        AppLanguage.hi => 'हिन्दी (Hindi)',
        AppLanguage.mr => 'मराठी (Marathi)',
      };

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) => switch (code) {
        'hi' => AppLanguage.hi,
        'mr' => AppLanguage.mr,
        _ => AppLanguage.en,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Language State Notifier with Persistent Storage
// ─────────────────────────────────────────────────────────────────────────────

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier([AppLanguage initial = AppLanguage.en]) : super(initial) {
    if (initial == AppLanguage.en) {
      _loadPersistedLanguage();
    }
  }

  static const String _prefKey = 'selected_app_language';

  Future<void> _loadPersistedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null) {
        super.state = AppLanguageX.fromCode(savedCode);
      }
    } catch (_) {}
  }

  @override
  set state(AppLanguage value) {
    super.state = value;
    _persist(value);
  }

  void setLanguage(AppLanguage value) {
    state = value;
  }

  Future<void> _persist(AppLanguage value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, value.code);
    } catch (_) {}
  }
}

final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier();
});

// ─────────────────────────────────────────────────────────────────────────────
// Comprehensive Production Multilingual Dictionary (EN / HI / MR)
// ─────────────────────────────────────────────────────────────────────────────

class AppStrings {
  static const Map<String, Map<AppLanguage, String>> _values = {
    // ── Brand & App ──────────────────────────────────────────────────────────
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
    'platform_subtitle': {
      AppLanguage.en: 'Commercial Plant & Nursery Platform',
      AppLanguage.hi: 'व्यावसायिक पौधशाला एवं कृषि मंच',
      AppLanguage.mr: 'व्यावसायिक रोपवाटिका व शेती मंच',
    },

    // ── Navigation (All Roles) ───────────────────────────────────────────────
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
    'nav_catalog': {
      AppLanguage.en: 'Catalog',
      AppLanguage.hi: 'कैटलॉग',
      AppLanguage.mr: 'कॅटलॉग',
    },
    'nav_stock': {
      AppLanguage.en: 'Stock',
      AppLanguage.hi: 'स्टॉक',
      AppLanguage.mr: 'साठा',
    },
    'nav_reports': {
      AppLanguage.en: 'Reports',
      AppLanguage.hi: 'रिपोर्ट्स',
      AppLanguage.mr: 'अहवाल',
    },
    'nav_dashboard': {
      AppLanguage.en: 'Dashboard',
      AppLanguage.hi: 'डैशबोर्ड',
      AppLanguage.mr: 'डॅशबोर्ड',
    },
    'nav_deliveries': {
      AppLanguage.en: 'Deliveries',
      AppLanguage.hi: 'वितरण',
      AppLanguage.mr: 'डिलिव्हरी',
    },
    'nav_history': {
      AppLanguage.en: 'History',
      AppLanguage.hi: 'इतिहास',
      AppLanguage.mr: 'इतिहास',
    },
    'nav_platform': {
      AppLanguage.en: 'Platform',
      AppLanguage.hi: 'प्लेटफॉर्म',
      AppLanguage.mr: 'प्लॅटफॉर्म',
    },
    'nav_tenants': {
      AppLanguage.en: 'Tenants',
      AppLanguage.hi: 'नर्सरी ग्राहक',
      AppLanguage.mr: 'नर्सरी ग्राहक',
    },

    // ── Roles & Auth Selection ───────────────────────────────────────────────
    'role_who_logging': {
      AppLanguage.en: 'Who are you logging in as?',
      AppLanguage.hi: 'आप किस रूप में लॉगिन कर रहे हैं?',
      AppLanguage.mr: 'तुम्ही कोणाच्या स्वरूपात लॉगिन करत आहात?',
    },
    'role_select_account_desc': {
      AppLanguage.en: 'Select your account type to open your specialized workspace',
      AppLanguage.hi: 'अपनी विशेष कार्यक्षेत्र खोलने के लिए खाता प्रकार चुनें',
      AppLanguage.mr: 'तुमची विशेष कार्यप्रणाली उघडण्यासाठी खाते प्रकार निवडा',
    },
    'role_farmer_title': {
      AppLanguage.en: 'Farmer / Customer',
      AppLanguage.hi: 'किसान / ग्राहक',
      AppLanguage.mr: 'शेतकरी / ग्राहक',
    },
    'role_farmer_sub': {
      AppLanguage.en: 'Shop plants & seedlings',
      AppLanguage.hi: 'पौधे और रोपे खरीदें',
      AppLanguage.mr: 'रोपे आणि कलमे खरेदी करा',
    },
    'role_badge_pin': {
      AppLanguage.en: 'Mobile + PIN',
      AppLanguage.hi: 'मोबाइल + पिन',
      AppLanguage.mr: 'मोबाईल + पिन',
    },
    'role_owner_title': {
      AppLanguage.en: 'Nursery / Staff',
      AppLanguage.hi: 'नर्सरी / कर्मचारी',
      AppLanguage.mr: 'नर्सरी / कर्मचारी',
    },
    'role_owner_sub': {
      AppLanguage.en: 'Manage your nursery',
      AppLanguage.hi: 'अपनी नर्सरी प्रबंधित करें',
      AppLanguage.mr: 'तुमची नर्सरी व्यवस्थापित करा',
    },
    'role_badge_pwd': {
      AppLanguage.en: 'Email + Password',
      AppLanguage.hi: 'ईमेल + पासवर्ड',
      AppLanguage.mr: 'ईमेल + पासवर्ड',
    },
    'role_owner': {
      AppLanguage.en: 'Nursery Owner / Operator',
      AppLanguage.hi: 'नर्सरी संचालक / मालक',
      AppLanguage.mr: 'नर्सरी मालक / व्यवस्थापक',
    },
    'role_manager': {
      AppLanguage.en: 'Operations Manager',
      AppLanguage.hi: 'परिचालन प्रबंधक',
      AppLanguage.mr: 'कामकाज व्यवस्थापक',
    },
    'role_staff': {
      AppLanguage.en: 'Nursery Field Staff',
      AppLanguage.hi: 'नर्सरी क्षेत्र कर्मचारी',
      AppLanguage.mr: 'नर्सरी फील्ड कर्मचारी',
    },
    'role_delivery': {
      AppLanguage.en: 'Delivery Partner',
      AppLanguage.hi: 'वितरण भागीदार',
      AppLanguage.mr: 'डिलिव्हरी पार्टनर',
    },
    'role_admin': {
      AppLanguage.en: 'Commercial Platform Admin',
      AppLanguage.hi: 'वाणिज्यिक मंच व्यवस्थापक',
      AppLanguage.mr: 'प्लॅटफॉर्म प्रशासक',
    },

    // ── Auth Forms & Fields ──────────────────────────────────────────────────
    'farmer_sign_in_title': {
      AppLanguage.en: 'Farmer Sign In',
      AppLanguage.hi: 'किसान लॉगिन',
      AppLanguage.mr: 'शेतकरी लॉगिन',
    },
    'farmer_sign_in_sub': {
      AppLanguage.en: 'Enter your registered mobile & 6-digit PIN',
      AppLanguage.hi: 'पंजीकृत मोबाइल नंबर और 6-अंकों का पिन दर्ज करें',
      AppLanguage.mr: 'नोंदणीकृत मोबाईल नंबर आणि ६-अंकी पिन टाका',
    },
    'nursery_sign_in_title': {
      AppLanguage.en: 'Nursery & Staff Portal',
      AppLanguage.hi: 'नर्सरी एवं कर्मचारी पोर्टल',
      AppLanguage.mr: 'नर्सरी व कर्मचारी पोर्टल',
    },
    'nursery_sign_in_sub': {
      AppLanguage.en: 'Access commercial inventory, orders & billing',
      AppLanguage.hi: 'स्टॉक, ऑर्डर और बिलिंग तक पहुंचें',
      AppLanguage.mr: 'साठा, ऑर्डर्स आणि बिलिंग व्यवस्थापित करा',
    },
    'mobile_number': {
      AppLanguage.en: 'Mobile Number',
      AppLanguage.hi: 'मोबाइल नंबर',
      AppLanguage.mr: 'मोबाईल नंबर',
    },
    'security_pin': {
      AppLanguage.en: '6-digit Security PIN',
      AppLanguage.hi: '6-अंकों का सुरक्षा पिन',
      AppLanguage.mr: '६-अंकी सुरक्षा पिन',
    },
    'email_address': {
      AppLanguage.en: 'Registered Email',
      AppLanguage.hi: 'पंजीकृत ईमेल',
      AppLanguage.mr: 'नोंदणीकृत ईमेल',
    },
    'password': {
      AppLanguage.en: 'Password',
      AppLanguage.hi: 'पासवर्ड',
      AppLanguage.mr: 'पासवर्ड',
    },
    'sign_in_button': {
      AppLanguage.en: 'Sign In to Account',
      AppLanguage.hi: 'खाते में प्रवेश करें',
      AppLanguage.mr: 'खात्यात प्रवेश करा',
    },
    'create_farmer_account': {
      AppLanguage.en: 'New Farmer? Create Account (30 seconds)',
      AppLanguage.hi: 'नए किसान? खाता बनाएं (30 सेकंड)',
      AppLanguage.mr: 'नवीन शेतकरी? नवीन खाते तयार करा (३० सेकंद)',
    },
    'forgot_pin': {
      AppLanguage.en: 'Forgot PIN? Quick Reset',
      AppLanguage.hi: 'पिन भूल गए? तुरंत रीसेट करें',
      AppLanguage.mr: 'पिन विसरलात? त्वरित रीसेट करा',
    },
    'forgot_password': {
      AppLanguage.en: 'Forgot Password?',
      AppLanguage.hi: 'पासवर्ड भूल गए?',
      AppLanguage.mr: 'पासवर्ड विसरलात?',
    },
    'quick_demo_logins': {
      AppLanguage.en: 'Quick Demo 1-Tap Logins:',
      AppLanguage.hi: 'त्वरित डेमो 1-टैप लॉगिन:',
      AppLanguage.mr: 'त्वरित डेमो १-टॅप लॉगिन:',
    },

    // ── Registration ─────────────────────────────────────────────────────────
    'farmer_signup_title': {
      AppLanguage.en: 'Farmer Account Creation',
      AppLanguage.hi: 'किसान खाता निर्माण',
      AppLanguage.mr: 'शेतकरी खाते नोंदणी',
    },
    'fast_signup_banner': {
      AppLanguage.en: 'Fast & Simple Farmer Signup',
      AppLanguage.hi: 'सरल एवं त्वरित किसान पंजीकरण',
      AppLanguage.mr: 'सोपी आणि जलद शेतकरी नोंदणी',
    },
    'fast_signup_banner_sub': {
      AppLanguage.en: 'Set your 6-digit PIN once. No waiting for SMS OTP every time!',
      AppLanguage.hi: 'अपना 6-अंकीय पिन एक बार सेट करें। हर बार ओटीपी का इंतजार नहीं!',
      AppLanguage.mr: 'तुमचा ६-अंकी पिन एकदाच सेट करा. प्रत्येक वेळी ओटीपीची वाट पाहण्याची गरज नाही!',
    },
    'full_name_label': {
      AppLanguage.en: 'Your Full Name / Farm Name',
      AppLanguage.hi: 'आपका पूरा नाम / खेत का नाम',
      AppLanguage.mr: 'तुमचे पूर्ण नाव / शेताचे नाव',
    },
    'full_name_hint': {
      AppLanguage.en: 'e.g. Ramesh Patil / Patil Agro',
      AppLanguage.hi: 'उदा. रमेश पाटिल / पाटिल एग्रो',
      AppLanguage.mr: 'उदा. रमेश पाटील / पाटील ॲग्रो',
    },
    'create_pin_label': {
      AppLanguage.en: 'Create 6-digit Security PIN *',
      AppLanguage.hi: '6-अंकीय सुरक्षा पिन बनाएं *',
      AppLanguage.mr: '६-अंकी सुरक्षा पिन तयार करा *',
    },
    'confirm_pin_label': {
      AppLanguage.en: 'Confirm 6-digit Security PIN *',
      AppLanguage.hi: '6-अंकीय सुरक्षा पिन की पुष्टि करें *',
      AppLanguage.mr: '६-अंकी सुरक्षा पिन पुन्हा टाका *',
    },
    'confirm_pin_hint': {
      AppLanguage.en: 'Re-enter your 6-digit PIN',
      AppLanguage.hi: 'अपना 6-अंकीय पिन पुनः दर्ज करें',
      AppLanguage.mr: 'तुमचा ६-अंकी पिन पुन्हा टाका',
    },
    'btn_create_account': {
      AppLanguage.en: 'Create Farmer Account 🌱',
      AppLanguage.hi: 'किसान खाता बनाएं 🌱',
      AppLanguage.mr: 'शेतकरी खाते तयार करा 🌱',
    },
    'already_have_account_btn': {
      AppLanguage.en: 'Already have an account? Sign in with Mobile & PIN',
      AppLanguage.hi: 'पहले से खाता है? मोबाइल और पिन से लॉगिन करें',
      AppLanguage.mr: 'आधीच खाते आहे? मोबाईल आणि पिनने लॉगिन करा',
    },

    // ── Form Validations ─────────────────────────────────────────────────────
    'val_phone_required': {
      AppLanguage.en: 'Enter a valid 10-digit mobile number',
      AppLanguage.hi: 'मान्य 10-अंकीय मोबाइल नंबर दर्ज करें',
      AppLanguage.mr: 'वैध १०-अंकी मोबाईल नंबर टाका',
    },
    'val_pin_exact_6': {
      AppLanguage.en: 'PIN must be exactly 6 digits',
      AppLanguage.hi: 'पिन ठीक 6 अंकों का होना चाहिए',
      AppLanguage.mr: 'पिन नेमका ६ अंकी असावा',
    },
    'val_pins_mismatch': {
      AppLanguage.en: 'PINs do not match! Please check.',
      AppLanguage.hi: 'पिन मेल नहीं खाते! कृपया जांचें।',
      AppLanguage.mr: 'पिन जुळत नाहीत! कृपया तपासा.',
    },
    'val_email_required': {
      AppLanguage.en: 'Please enter registered email or phone',
      AppLanguage.hi: 'कृपया पंजीकृत ईमेल या फोन दर्ज करें',
      AppLanguage.mr: 'कृपया नोंदणीकृत ईमेल किंवा फोन टाका',
    },
    'val_password_required': {
      AppLanguage.en: 'Password must be at least 6 characters',
      AppLanguage.hi: 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए',
      AppLanguage.mr: 'पासवर्ड किमान ६ अक्षरांचा असावा',
    },
    'val_street_required': {
      AppLanguage.en: 'Please enter street, village or survey number',
      AppLanguage.hi: 'कृपया सड़क, गाँव या सर्वे नंबर दर्ज करें',
      AppLanguage.mr: 'कृपया रस्ता, गाव किंवा सर्व्हे नंबर टाका',
    },
    'val_city_required': {
      AppLanguage.en: 'Please enter city or taluka',
      AppLanguage.hi: 'कृपया शहर या तालुका दर्ज करें',
      AppLanguage.mr: 'कृपया शहर किंवा तालुका टाका',
    },
    'val_state_required': {
      AppLanguage.en: 'Please enter state',
      AppLanguage.hi: 'कृपया राज्य दर्ज करें',
      AppLanguage.mr: 'कृपया राज्य टाका',
    },
    'val_pincode_required': {
      AppLanguage.en: 'Please enter valid 6-digit postal pincode',
      AppLanguage.hi: 'कृपया मान्य 6-अंकीय पिनकोड दर्ज करें',
      AppLanguage.mr: 'कृपया वैध ६-अंकी पिनकोड टाका',
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
    'search_variety_hint': {
      AppLanguage.en: 'Search variety (e.g. Abhinav, Balram, Indra)...',
      AppLanguage.hi: 'किस्म खोजें (उदा. अभिनव, बलराम, इंद्रा)...',
      AppLanguage.mr: 'वाण शोधा (उदा. अभिनव, बलराम, इंद्रा)...',
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

    // ── Categories ───────────────────────────────────────────────────────────
    'cat_all': {
      AppLanguage.en: 'All Plants',
      AppLanguage.hi: 'सभी पौधे',
      AppLanguage.mr: 'सर्व रोपे',
    },
    'cat_vegetables': {
      AppLanguage.en: 'Vegetable Plants',
      AppLanguage.hi: 'सब्जी के पौधे',
      AppLanguage.mr: 'भाजीपाला रोपे',
    },
    'cat_flowers': {
      AppLanguage.en: 'Flower Plants',
      AppLanguage.hi: 'फूलों के पौधे',
      AppLanguage.mr: 'फुलांची रोपे',
    },
    'cat_fruits': {
      AppLanguage.en: 'Fruit Plants',
      AppLanguage.hi: 'फलों के पौधे / कलमें',
      AppLanguage.mr: 'फळझाडे / कलमे',
    },
    'cat_medicinal': {
      AppLanguage.en: 'Medicinal Plants',
      AppLanguage.hi: 'औषधी पौधे',
      AppLanguage.mr: 'औषधी वनस्पती',
    },
    'cat_indoor': {
      AppLanguage.en: 'Indoor Plants',
      AppLanguage.hi: 'इनडोर पौधे',
      AppLanguage.mr: 'शोभेची रोपे',
    },
    'cat_other': {
      AppLanguage.en: 'Other Nursery Products',
      AppLanguage.hi: 'अन्य नर्सरी सामग्री',
      AppLanguage.mr: 'खते व साधने',
    },

    // ── Availability & Stock Statuses ────────────────────────────────────────
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
    'varieties_available': {
      AppLanguage.en: 'Varieties Available',
      AppLanguage.hi: 'किस्में उपलब्ध हैं',
      AppLanguage.mr: 'प्रकार उपलब्ध आहेत',
    },
    'all_regional_varieties': {
      AppLanguage.en: 'All Regional Varieties',
      AppLanguage.hi: 'सभी क्षेत्रीय किस्में',
      AppLanguage.mr: 'सर्व प्रादेशिक प्रकार',
    },
    'filtering_crop': {
      AppLanguage.en: 'Filtering',
      AppLanguage.hi: 'फ़िल्टर',
      AppLanguage.mr: 'फिल्टर',
    },
    'marketplace_unavailable': {
      AppLanguage.en: 'Marketplace is unavailable. Check your connection and try again.',
      AppLanguage.hi: 'मार्केटप्लेस अनुपलब्ध है। कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।',
      AppLanguage.mr: 'मार्केटप्लेस उपलब्ध नाही. कृपया आपले कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.',
    },
    'no_varieties_criteria': {
      AppLanguage.en: 'No varieties found matching your criteria',
      AppLanguage.hi: 'आपके मापदंड से मेल खाती कोई किस्म नहीं मिली',
      AppLanguage.mr: 'आपल्या निकषांशी जुळणारे कोणतेही प्रकार सापडले नाहीत',
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
    'cancel': {
      AppLanguage.en: 'Cancel',
      AppLanguage.hi: 'रद्द करें',
      AppLanguage.mr: 'रद्द करा',
    },
    'retry': {
      AppLanguage.en: 'Retry',
      AppLanguage.hi: 'पुनः प्रयास करें',
      AppLanguage.mr: 'पुन्हा प्रयत्न करा',
    },
    'save': {
      AppLanguage.en: 'Save',
      AppLanguage.hi: 'सहेजें',
      AppLanguage.mr: 'जतन करा',
    },
    'saved_successfully': {
      AppLanguage.en: 'Saved successfully',
      AppLanguage.hi: 'सफलतापूर्वक सहेजा गया',
      AppLanguage.mr: 'यशस्वीरित्या जतन केले',
    },
    'refresh': {
      AppLanguage.en: 'Refresh',
      AppLanguage.hi: 'ताज़ा करें',
      AppLanguage.mr: 'ताजे करा',
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
    'min_10_plants': {
      AppLanguage.en: 'Min 10 plants',
      AppLanguage.hi: 'न्यूनतम 10 पौधे',
      AppLanguage.mr: 'किमान 10 रोपे',
    },
    'plants_per_tray': {
      AppLanguage.en: 'plants/tray',
      AppLanguage.hi: 'पौधे/ट्रे',
      AppLanguage.mr: 'रोपे/ट्रे',
    },
    'bulk_seedlings_sub': {
      AppLanguage.en: '1,000+ seedlings',
      AppLanguage.hi: '1,000+ रोपे',
      AppLanguage.mr: '1,000+ रोपे',
    },
    'stock_dispatch_sched': {
      AppLanguage.en: 'Stock & Dispatch Schedule',
      AppLanguage.hi: 'स्टॉक व प्रेषण अनुसूची',
      AppLanguage.mr: 'साठा व पाठवण्याचे वेळापत्रक',
    },
    'order_qty_units': {
      AppLanguage.en: 'Order Quantity & Units',
      AppLanguage.hi: 'ऑर्डर मात्रा व प्रकार',
      AppLanguage.mr: 'ऑर्डर प्रमाण आणि युनिट',
    },
    'about_this_variety': {
      AppLanguage.en: 'About This Variety',
      AppLanguage.hi: 'इस किस्म के बारे में',
      AppLanguage.mr: 'या वाणाबद्दल माहिती',
    },
    'view_offer': {
      AppLanguage.en: 'View Offer',
      AppLanguage.hi: 'ऑफ़र देखें',
      AppLanguage.mr: 'ऑफर पहा',
    },
    'photo_info': {
      AppLanguage.en: 'Photo Info',
      AppLanguage.hi: 'फोटो जानकारी',
      AppLanguage.mr: 'फोटो माहिती',
    },

    // ── Homepage & Marketplace Sections ──────────────────────────────────────
    'farmer_marketplace': {
      AppLanguage.en: 'Farmer Marketplace',
      AppLanguage.hi: 'किसान बाजारपेठ',
      AppLanguage.mr: 'शेतकरी बाजारपेठ',
    },
    'filtering_label': {
      AppLanguage.en: 'Filtering:',
      AppLanguage.hi: 'फ़िल्टर:',
      AppLanguage.mr: 'फिल्टर:',
    },
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
    'my_garden_cart': {
      AppLanguage.en: 'My Plant Cart',
      AppLanguage.hi: 'मेरी पौध कार्ट',
      AppLanguage.mr: 'माझी रोप कार्ट',
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
      AppLanguage.en: 'Delivery & Handling',
      AppLanguage.hi: 'वितरण व हाताळणी',
      AppLanguage.mr: 'डिलिव्हरी व हाताळणी',
    },
    'total': {
      AppLanguage.en: 'Total Payable',
      AppLanguage.hi: 'कुल देय राशि',
      AppLanguage.mr: 'एकूण देय रक्कम',
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
    'clear_cart_tooltip': {
      AppLanguage.en: 'Clear Cart',
      AppLanguage.hi: 'कार्ट खाली करें',
      AppLanguage.mr: 'कार्ट रिकामी करा',
    },
    'clear_cart_dialog_title': {
      AppLanguage.en: 'Clear Cart?',
      AppLanguage.hi: 'कार्ट खाली करें?',
      AppLanguage.mr: 'कार्ट रिकामी करायची का?',
    },
    'clear_cart_dialog_msg': {
      AppLanguage.en: 'Are you sure you want to remove all seedlings and plants from your cart?',
      AppLanguage.hi: 'क्या आप वाकई अपनी कार्ट से सभी रोपे हटाना चाहते हैं?',
      AppLanguage.mr: 'तुम्हाला खात्री आहे का की कार्टमधून सर्व रोपे काढून टाकायची आहेत?',
    },
    'clear_all': {
      AppLanguage.en: 'Clear All',
      AppLanguage.hi: 'सब हटाएं',
      AppLanguage.mr: 'सर्व काढा',
    },
    'different_nursery': {
      AppLanguage.en: 'Different Nursery',
      AppLanguage.hi: 'भिन्न नर्सरी',
      AppLanguage.mr: 'वेगळी नर्सरी',
    },
    'different_nursery_msg': {
      AppLanguage.en: 'Your cart contains items from another nursery. Each order is fulfilled directly by a single regional nursery.\n\nClear cart and start an order from this nursery?',
      AppLanguage.hi: 'आपकी कार्ट में दूसरी नर्सरी की वस्तुएं हैं। प्रत्येक ऑर्डर एक ही क्षेत्रीय नर्सरी द्वारा पूरा किया जाता है।\n\nकार्ट खाली करें और इस नर्सरी से नया ऑर्डर शुरू करें?',
      AppLanguage.mr: 'तुमच्या कार्टमध्ये दुसऱ्या नर्सरीतील वस्तू आहेत. प्रत्येक ऑर्डर एकाच प्रादेशिक नर्सरीद्वारे पूर्ण केली जाते.\n\nकार्ट रिकामे करा आणि या नर्सरीकडून नवीन ऑर्डर सुरू करायची का?',
    },
    'keep_current_cart': {
      AppLanguage.en: 'Keep Current Cart',
      AppLanguage.hi: 'वर्तमान कार्ट रखें',
      AppLanguage.mr: 'चालू कार्ट ठेवा',
    },
    'clear_and_switch': {
      AppLanguage.en: 'Clear & Switch',
      AppLanguage.hi: 'खाली करें और बदलें',
      AppLanguage.mr: 'कार्ट रिकामे करा व बदला',
    },
    'cart_empty_title': {
      AppLanguage.en: 'Your cart is completely empty!',
      AppLanguage.hi: 'आपकी कार्ट पूरी तरह खाली है!',
      AppLanguage.mr: 'तुमची कार्ट पूर्णपणे रिकामी आहे!',
    },
    'cart_empty_sub': {
      AppLanguage.en: 'Explore healthy nursery seedlings and seasonal crops from verified nurseries.',
      AppLanguage.hi: 'प्रमाणित नर्सरियों से स्वस्थ रोपे और मौसमी फसलें देखें।',
      AppLanguage.mr: 'प्रमाणित नर्सरींमधून निरोगी रोपे आणि हंगामी पिके शोधा.',
    },
    'browse_storefront_btn': {
      AppLanguage.en: 'Browse Storefront',
      AppLanguage.hi: 'स्टोर ब्राउज़ करें',
      AppLanguage.mr: 'दुकान पहा',
    },
    'order_summary': {
      AppLanguage.en: 'Order Summary',
      AppLanguage.hi: 'ऑर्डर सारांश',
      AppLanguage.mr: 'ऑर्डर तपशील',
    },
    'shipping_address': {
      AppLanguage.en: 'Farm / Delivery Address',
      AppLanguage.hi: 'खेत / प्रेषण का पता',
      AppLanguage.mr: 'शेताचा / पोहोच पत्ता',
    },
    'street_address': {
      AppLanguage.en: 'Street / Village / Survey No.',
      AppLanguage.hi: 'सड़क / गाँव / सर्वे नं.',
      AppLanguage.mr: 'रस्ता / गाव / सर्व्हे नं.',
    },
    'city_taluka': {
      AppLanguage.en: 'City / Taluka',
      AppLanguage.hi: 'शहर / तालुका',
      AppLanguage.mr: 'शहर / तालुका',
    },
    'state': {
      AppLanguage.en: 'State',
      AppLanguage.hi: 'राज्य',
      AppLanguage.mr: 'राज्य',
    },
    'pincode': {
      AppLanguage.en: 'Pincode (6 digits)',
      AppLanguage.hi: 'पिनकोड (6 अंक)',
      AppLanguage.mr: 'पिनकोड (६ अंक)',
    },
    'payment_method': {
      AppLanguage.en: 'Payment Method',
      AppLanguage.hi: 'भुगतान विधि',
      AppLanguage.mr: 'पेमेंट पद्धत',
    },
    'pay_upi': {
      AppLanguage.en: 'UPI (GPay / PhonePe / Paytm / BHIM)',
      AppLanguage.hi: 'यूपीआई (GPay / PhonePe / Paytm / BHIM)',
      AppLanguage.mr: 'यूपीआय (GPay / PhonePe / Paytm / BHIM)',
    },
    'pay_cod': {
      AppLanguage.en: 'Cash on Delivery (Pay on Farm Delivery)',
      AppLanguage.hi: 'कैश ऑन डिलीवरी (डिलीवरी पर नकद)',
      AppLanguage.mr: 'कॅश ऑन डिलिव्हरी (डिलिव्हरीच्या वेळी रोख)',
    },
    'pay_card': {
      AppLanguage.en: 'Debit / Credit Card / Net Banking',
      AppLanguage.hi: 'डेबिट / क्रेडिट कार्ड / नेट बैंकिंग',
      AppLanguage.mr: 'डेबिट / क्रेडिट कार्ड / नेट बँकिंग',
    },
    'proceed_checkout': {
      AppLanguage.en: 'Proceed to Checkout',
      AppLanguage.hi: 'चेकआउट के लिए आगे बढ़ें',
      AppLanguage.mr: 'खरेदी पूर्ण करण्यासाठी पुढे जा',
    },
    'field_required': {
      AppLanguage.en: 'Required',
      AppLanguage.hi: 'आवश्यक',
      AppLanguage.mr: 'आवश्यक',
    },
    'confirm_order_and_pay': {
      AppLanguage.en: 'Confirm Order & Pay',
      AppLanguage.hi: 'ऑर्डर पक्का करें और भुगतान करें',
      AppLanguage.mr: 'ऑर्डर निश्चित करा व पैसे भरा',
    },
    'confirming_order': {
      AppLanguage.en: 'Confirming Order...',
      AppLanguage.hi: 'ऑर्डर की पुष्टि हो रही है...',
      AppLanguage.mr: 'ऑर्डर निश्चित होत आहे...',
    },

    // ── Orders & Invoices ────────────────────────────────────────────────────
    'orders': {
      AppLanguage.en: 'Orders',
      AppLanguage.hi: 'ऑर्डर्स',
      AppLanguage.mr: 'ऑर्डर्स',
    },
    'my_plant_orders': {
      AppLanguage.en: 'My Plant Orders',
      AppLanguage.hi: 'मेरे पौधों के ऑर्डर्स',
      AppLanguage.mr: 'माझे रोपांचे ऑर्डर्स',
    },
    'nursery_commercial_orders': {
      AppLanguage.en: 'Nursery Commercial Orders',
      AppLanguage.hi: 'नर्सरी व्यावसायिक ऑर्डर्स',
      AppLanguage.mr: 'नर्सरी व्यावसायिक ऑर्डर्स',
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
    'no_orders_yet': {
      AppLanguage.en: 'No Orders Placed Yet',
      AppLanguage.hi: 'अभी तक कोई ऑर्डर नहीं दिया गया',
      AppLanguage.mr: 'अद्याप कोणतीही ऑर्डर दिलेली नाही',
    },
    'no_orders_yet_sub': {
      AppLanguage.en: 'You have not ordered any seedling trays yet.',
      AppLanguage.hi: 'आपने अभी तक कोई ट्रे ऑर्डर नहीं की है।',
      AppLanguage.mr: 'तुम्ही अद्याप कोणत्याही ट्रेची ऑर्डर दिलेली नाही.',
    },
    'order_now_btn': {
      AppLanguage.en: 'Order Nursery Plants Now',
      AppLanguage.hi: 'अभी पौधे ऑर्डर करें',
      AppLanguage.mr: 'आत्ताच रोपांची ऑर्डर द्या',
    },
    'items_count_label': {
      AppLanguage.en: 'Items',
      AppLanguage.hi: 'वस्तुएं',
      AppLanguage.mr: 'वस्तू',
    },
    'status_label': {
      AppLanguage.en: 'Status',
      AppLanguage.hi: 'स्थिति',
      AppLanguage.mr: 'स्थिती',
    },
    'status_confirmed': {
      AppLanguage.en: 'Confirmed',
      AppLanguage.hi: 'स्वीकृत',
      AppLanguage.mr: 'निश्चित',
    },
    'status_processing': {
      AppLanguage.en: 'Processing Batch',
      AppLanguage.hi: 'प्रक्रियाधीन बैच',
      AppLanguage.mr: 'प्रक्रियेत',
    },
    'status_dispatched': {
      AppLanguage.en: 'Dispatched',
      AppLanguage.hi: 'प्रेषित',
      AppLanguage.mr: 'पाठवले',
    },
    'status_delivered': {
      AppLanguage.en: 'Delivered',
      AppLanguage.hi: 'वितरित',
      AppLanguage.mr: 'पोहोचवले',
    },
    'status_cancelled': {
      AppLanguage.en: 'Cancelled',
      AppLanguage.hi: 'रद्द',
      AppLanguage.mr: 'रद्द',
    },

    // ── Farmer Profile & Pre-Bookings ─────────────────────────────────────────
    'farmer_profile_badge': {
      AppLanguage.en: '🌾 Registered Farmer • 6-Digit PIN Secured',
      AppLanguage.hi: '🌾 पंजीकृत किसान • 6-अंकीय पिन सुरक्षित',
      AppLanguage.mr: '🌾 नोंदणीकृत शेतकरी • ६-अंकी पिन सुरक्षित',
    },
    'active_farming_location': {
      AppLanguage.en: 'Active Farming Location',
      AppLanguage.hi: 'सक्रिय कृषि स्थान',
      AppLanguage.mr: 'सक्रिय शेती ठिकाण',
    },
    'farming_location_desc': {
      AppLanguage.en: 'Used to match nearby certified seedling nurseries in Maharashtra.',
      AppLanguage.hi: 'महाराष्ट्र में प्रमाणित रोपे नर्सरियों से मिलाने के लिए उपयोग किया जाता है।',
      AppLanguage.mr: 'महाराष्ट्रातील प्रमाणित रोपवाटिकांशी जोडण्यासाठी वापरले जाते.',
    },
    'my_advance_prebookings': {
      AppLanguage.en: 'My Advance Pre-Bookings',
      AppLanguage.hi: 'मेरी अग्रिम प्री-बुकिंग',
      AppLanguage.mr: 'माझी आगाऊ पूर्व-नोंदणी',
    },
    'prebookings_sub': {
      AppLanguage.en: 'Track reserved polyhouse batches & dispatch dates',
      AppLanguage.hi: 'आरक्षित पॉलीहाउस बैच एवं प्रेषण तिथि ट्रैक करें',
      AppLanguage.mr: 'आरक्षित पॉलिहाऊस बॅच आणि पाठवण्याची तारीख तपासा',
    },
    'orders_list_sub': {
      AppLanguage.en: 'View invoices, order status & seedling tracking',
      AppLanguage.hi: 'इनवॉइस, ऑर्डर स्थिति और रोपे ट्रैकिंग देखें',
      AppLanguage.mr: 'बीजक, ऑर्डर स्थिती आणि रोपे ट्रॅकिंग पहा',
    },
    'nursery_tech_support': {
      AppLanguage.en: 'Nursery Technical Support',
      AppLanguage.hi: 'नर्सरी तकनीकी सहायता',
      AppLanguage.mr: 'नर्सरी तांत्रिक सहाय्य',
    },
    'nursery_support_sub': {
      AppLanguage.en: 'WhatsApp or call agronomy support: +91 9900000002',
      AppLanguage.hi: 'कृषि सहायता से संपर्क करें: +91 9900000002',
      AppLanguage.mr: 'कृषी मार्गदर्शकांशी संपर्क: +९१ ९९०००००००२',
    },
    'language_menu_title': {
      AppLanguage.en: 'Language / भाषा / भाषा निवडा',
      AppLanguage.hi: 'Language / भाषा / भाषा निवडा',
      AppLanguage.mr: 'Language / भाषा / भाषा निवडा',
    },
    'select_language_dialog': {
      AppLanguage.en: 'Select Application Language',
      AppLanguage.hi: 'एप्लिकेशन भाषा चुनें',
      AppLanguage.mr: 'ॲप्लिकेशनची भाषा निवडा',
    },
    'sign_out': {
      AppLanguage.en: 'Sign Out / Logout',
      AppLanguage.hi: 'लॉगआउट करें',
      AppLanguage.mr: 'बाहेर पडा / लॉगआउट',
    },

    // ── Owner Business & Dashboard ───────────────────────────────────────────
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
    'today_revenue': {
      AppLanguage.en: "Today's Revenue",
      AppLanguage.hi: 'आज का राजस्व',
      AppLanguage.mr: 'आजचा महसूल',
    },
    'active_orders': {
      AppLanguage.en: 'Active Orders',
      AppLanguage.hi: 'सक्रिय ऑर्डर्स',
      AppLanguage.mr: 'सक्रिय ऑर्डर्स',
    },
    'total_varieties': {
      AppLanguage.en: 'Total Varieties',
      AppLanguage.hi: 'कुल किस्में',
      AppLanguage.mr: 'एकूण वाण',
    },
    'low_stock_alert': {
      AppLanguage.en: 'Low Stock Alerts',
      AppLanguage.hi: 'कम स्टॉक चेतावनी',
      AppLanguage.mr: 'कमी साठा सूचना',
    },
    'quick_actions': {
      AppLanguage.en: 'Nursery Quick Actions',
      AppLanguage.hi: 'नर्सरी त्वरित कार्य',
      AppLanguage.mr: 'नर्सरी त्वरित कृती',
    },
    'add_variety_action': {
      AppLanguage.en: '+ Add Variety',
      AppLanguage.hi: '+ नई किस्म जोड़ें',
      AppLanguage.mr: '+ नवीन वाण जोडा',
    },
    'create_offer_action': {
      AppLanguage.en: '+ Create Offer',
      AppLanguage.hi: '+ नया ऑफर बनाएं',
      AppLanguage.mr: '+ नवीन ऑफर तयार करा',
    },
    'manage_location_action': {
      AppLanguage.en: 'Manage Location',
      AppLanguage.hi: 'स्थान प्रबंधित करें',
      AppLanguage.mr: 'ठिकाण व्यवस्थापन',
    },
    'stock_adjust_action': {
      AppLanguage.en: 'Stock Adjust',
      AppLanguage.hi: 'स्टॉक समायोजन',
      AppLanguage.mr: 'साठा समायोजन',
    },
    'all_orders_action': {
      AppLanguage.en: 'All Orders',
      AppLanguage.hi: 'सभी ऑर्डर्स',
      AppLanguage.mr: 'सर्व ऑर्डर्स',
    },
    'live_deliveries_action': {
      AppLanguage.en: 'Live Deliveries',
      AppLanguage.hi: 'लाइव डिलीवरी',
      AppLanguage.mr: 'थेट डिलिव्हरी',
    },
    'preview_storefront_action': {
      AppLanguage.en: 'Preview Storefront',
      AppLanguage.hi: 'स्टोर पूर्वावलोकन',
      AppLanguage.mr: 'दुकान पूर्वावलोकन',
    },
    'recent_orders': {
      AppLanguage.en: 'Recent Orders',
      AppLanguage.hi: 'हालिया ऑर्डर्स',
      AppLanguage.mr: 'नुकत्याच आलेल्या ऑर्डर्स',
    },
    'top_selling_plants': {
      AppLanguage.en: 'Top Selling Varieties',
      AppLanguage.hi: 'सर्वाधिक बिकने वाली किस्में',
      AppLanguage.mr: 'सर्वाधिक विक्री होणारे वाण',
    },
    'business_profile': {
      AppLanguage.en: 'Business Profile',
      AppLanguage.hi: 'व्यावसायिक प्रोफ़ाइल',
      AppLanguage.mr: 'व्यावसायिक माहिती',
    },
    'profile_completeness': {
      AppLanguage.en: 'Profile Completeness',
      AppLanguage.hi: 'प्रोफ़ाइल पूर्णता',
      AppLanguage.mr: 'माहिती पूर्णता',
    },
    'nursery_name_label': {
      AppLanguage.en: 'Nursery Trade Name',
      AppLanguage.hi: 'नर्सरी व्यापार नाम',
      AppLanguage.mr: 'नर्सरीचे व्यावसायिक नाव',
    },
    'nursery_desc_label': {
      AppLanguage.en: 'Business Description',
      AppLanguage.hi: 'व्यवसाय विवरण',
      AppLanguage.mr: 'व्यवसाय माहिती',
    },
    'contact_phone_label': {
      AppLanguage.en: 'Farmer Support Phone',
      AppLanguage.hi: 'किसान सहायता फोन',
      AppLanguage.mr: 'शेतकरी मदत फोन',
    },
    'operating_hours_label': {
      AppLanguage.en: 'Operating Hours',
      AppLanguage.hi: 'खुलने का समय',
      AppLanguage.mr: 'कामकाजाची वेळ',
    },

    // ── Inventory Command Center ─────────────────────────────────────────────
    'nursery_supply_inventory': {
      AppLanguage.en: 'Nursery Supply & Inventory',
      AppLanguage.hi: 'नर्सरी आपूर्ति एवं स्टॉक',
      AppLanguage.mr: 'नर्सरी साठा व पुरवठा केंद्र',
    },
    'tab_ready_stock': {
      AppLanguage.en: 'Ready Stock',
      AppLanguage.hi: 'उपलब्ध स्टॉक',
      AppLanguage.mr: 'तयार साठा',
    },
    'tab_future_batches': {
      AppLanguage.en: 'Future Batches',
      AppLanguage.hi: 'भावी बैच',
      AppLanguage.mr: 'आगामी बॅचेस',
    },
    'tab_prebookings': {
      AppLanguage.en: 'Pre-Bookings',
      AppLanguage.hi: 'प्री-बुकिंग्स',
      AppLanguage.mr: 'पूर्व-नोंदण्या',
    },
    'tab_broadcasts': {
      AppLanguage.en: 'Broadcasts',
      AppLanguage.hi: 'प्रसारण सूचना',
      AppLanguage.mr: 'शेतकरी घोषणा',
    },
    'publish_announcement_tooltip': {
      AppLanguage.en: 'Publish Announcement',
      AppLanguage.hi: 'घोषणा प्रकाशित करें',
      AppLanguage.mr: 'शेतकरी घोषणा प्रसिद्ध करा',
    },
    'refresh_inventory_tooltip': {
      AppLanguage.en: 'Refresh Inventory',
      AppLanguage.hi: 'स्टॉक ताज़ा करें',
      AppLanguage.mr: 'साठा ताजा करा',
    },

    // ── Offers & Marketing ───────────────────────────────────────────────────
    'offers_campaigns_title': {
      AppLanguage.en: 'Offers & Marketing Campaigns',
      AppLanguage.hi: 'ऑफ़र्स एवं विपणन अभियान',
      AppLanguage.mr: 'ऑफर आणि विपणन योजना',
    },
    'create_offer_btn': {
      AppLanguage.en: 'Create Offer',
      AppLanguage.hi: 'ऑफ़र बनाएं',
      AppLanguage.mr: 'ऑफर तयार करा',
    },
    'tab_all': {
      AppLanguage.en: 'All',
      AppLanguage.hi: 'सभी',
      AppLanguage.mr: 'सर्व',
    },
    'tab_active': {
      AppLanguage.en: 'Active',
      AppLanguage.hi: 'सक्रिय',
      AppLanguage.mr: 'सक्रिय',
    },
    'tab_scheduled': {
      AppLanguage.en: 'Scheduled',
      AppLanguage.hi: 'निर्धारित',
      AppLanguage.mr: 'नियोजित',
    },
    'tab_draft': {
      AppLanguage.en: 'Draft',
      AppLanguage.hi: 'ड्राफ्ट',
      AppLanguage.mr: 'मसुदा',
    },
    'tab_expired': {
      AppLanguage.en: 'Expired',
      AppLanguage.hi: 'समाप्त',
      AppLanguage.mr: 'मुदत संपलेली',
    },

    // ── Reports & Analytics ──────────────────────────────────────────────────
    'reports_analytics_title': {
      AppLanguage.en: 'Nursery Reports & Analytics',
      AppLanguage.hi: 'नर्सरी रिपोर्ट्स और एनालिटिक्स',
      AppLanguage.mr: 'नर्सरी अहवाल व विश्लेषण',
    },
    'export_gst_csv': {
      AppLanguage.en: 'Export Nursery GST CSV',
      AppLanguage.hi: 'जीएसटी सीएसवी निर्यात करें',
      AppLanguage.mr: 'जीएसटी सीएसव्ही निर्यात करा',
    },
    'date_range_label': {
      AppLanguage.en: 'Date Range:',
      AppLanguage.hi: 'दिनांक सीमा:',
      AppLanguage.mr: 'कालावधी:',
    },
    'range_today': {
      AppLanguage.en: 'Today',
      AppLanguage.hi: 'आज',
      AppLanguage.mr: 'आज',
    },
    'range_this_week': {
      AppLanguage.en: 'This Week',
      AppLanguage.hi: 'इस सप्ताह',
      AppLanguage.mr: 'या आठवड्यात',
    },
    'range_this_month': {
      AppLanguage.en: 'This Month',
      AppLanguage.hi: 'इस महीने',
      AppLanguage.mr: 'या महिन्यात',
    },
    'range_year_to_date': {
      AppLanguage.en: 'Year to Date',
      AppLanguage.hi: 'साल से अब तक',
      AppLanguage.mr: 'वर्षापासून आजपर्यंत',
    },

    // ── Delivery Dashboard & Tracking ────────────────────────────────────────
    'delivery_fleet_title': {
      AppLanguage.en: 'Nursery Delivery Fleet 🚚',
      AppLanguage.hi: 'नर्सरी वितरण बेड़ा 🚚',
      AppLanguage.mr: 'नर्सरी डिलिव्हरी फ्लीट 🚚',
    },
    'live_tracking_title': {
      AppLanguage.en: 'Live Seedling Delivery Tracking',
      AppLanguage.hi: 'लाइव रोपे प्रेषण ट्रैकिंग',
      AppLanguage.mr: 'थेट रोपे डिलिव्हरी ट्रॅकिंग',
    },

    // ── States & Feedback ────────────────────────────────────────────────────
    'loading_text': {
      AppLanguage.en: 'Loading nursery data...',
      AppLanguage.hi: 'नर्सरी डेटा लोड हो रहा है...',
      AppLanguage.mr: 'नर्सरी माहिती लोड होत आहे...',
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
    // ── Missing Role Keys & Aliases ─────────────────────────────────────────
    'role_super_admin': {
      AppLanguage.en: 'Commercial Platform Admin',
      AppLanguage.hi: 'वाणिज्यिक मंच व्यवस्थापक',
      AppLanguage.mr: 'प्लॅटफॉर्म प्रशासक',
    },
    'role_nursery_owner': {
      AppLanguage.en: 'Nursery Owner / Operator',
      AppLanguage.hi: 'नर्सरी संचालक / मालक',
      AppLanguage.mr: 'नर्सरी मालक / व्यवस्थापक',
    },
    'role_nursery_manager': {
      AppLanguage.en: 'Operations Manager',
      AppLanguage.hi: 'परिचालन प्रबंधक',
      AppLanguage.mr: 'कामकाज व्यवस्थापक',
    },
    'role_nursery_staff': {
      AppLanguage.en: 'Nursery Field Staff',
      AppLanguage.hi: 'नर्सरी क्षेत्र कर्मचारी',
      AppLanguage.mr: 'नर्सरी फील्ड कर्मचारी',
    },
    'role_delivery_partner': {
      AppLanguage.en: 'Delivery Partner',
      AppLanguage.hi: 'वितरण भागीदार',
      AppLanguage.mr: 'डिलिव्हरी पार्टनर',
    },
    'role_farmer': {
      AppLanguage.en: 'Farmer / Customer',
      AppLanguage.hi: 'किसान / ग्राहक',
      AppLanguage.mr: 'शेतकरी / ग्राहक',
    },
    'no_products_found': {
      AppLanguage.en: 'No products found',
      AppLanguage.hi: 'कोई उत्पाद नहीं मिला',
      AppLanguage.mr: 'कोणतीही उत्पादने आढळली नाहीत',
    },

    // ── Discovery, Sorting & Ranking ─────────────────────────────────────────
    'sort_rank': {
      AppLanguage.en: 'Multi-Factor Rank',
      AppLanguage.hi: 'बहु-कारक रैंक',
      AppLanguage.mr: 'मल्टी-फॅक्टर रँक',
    },
    'sort_distance': {
      AppLanguage.en: 'Nearest Distance',
      AppLanguage.hi: 'निकटतम दूरी',
      AppLanguage.mr: 'जवळचे अंतर',
    },
    'sort_rating': {
      AppLanguage.en: 'Highest Rating',
      AppLanguage.hi: 'सर्वोच्च रेटिंग',
      AppLanguage.mr: 'सर्वोच्च रेटिंग',
    },
    'sort_varieties': {
      AppLanguage.en: 'Most Varieties',
      AppLanguage.hi: 'सर्वाधिक किस्में',
      AppLanguage.mr: 'सर्वाधिक वाण',
    },
    'ranking_info': {
      AppLanguage.en: 'Ranking Info',
      AppLanguage.hi: 'रैंकिंग जानकारी',
      AppLanguage.mr: 'रँकिंग माहिती',
    },
    'ranking_dialog_title': {
      AppLanguage.en: 'How Nurseries are Ranked',
      AppLanguage.hi: 'नर्सरियों की रैंकिंग कैसे होती है',
      AppLanguage.mr: 'रोपवाटिकांचे रँकिंग कसे ठरते',
    },
    'ranking_dialog_desc': {
      AppLanguage.en: 'Nurseries are ranked based on proximity to your farm, seedling quality ratings, stock readiness, and order fulfillment speed.',
      AppLanguage.hi: 'नर्सरियों को आपके खेत से दूरी, पौधों की गुणवत्ता, स्टॉक उपलब्धता और समय पर डिलीवरी के आधार पर रैंक किया जाता है।',
      AppLanguage.mr: 'तुमच्या शेतापासूनचे अंतर, रोपांचा दर्जा, स्टॉकची उपलब्धता आणि जलद डिलिव्हरीच्या आधारावर रोपवाटिकांचे रँकिंग ठरवले जाते.',
    },
    'got_it': {
      AppLanguage.en: 'Got it',
      AppLanguage.hi: 'समझ गया',
      AppLanguage.mr: 'समजले',
    },
    'search_hint_general': {
      AppLanguage.en: 'Search nurseries, crops (Chilli, Tomato), varieties, seedling trays...',
      AppLanguage.hi: 'नर्सरी, फसलें (मिर्च, टमाटर), किस्में, पौध ट्रे खोजें...',
      AppLanguage.mr: 'रोपवाटिका, पिके (मिरची, टोमॅटो), वाण, रोपांचे ट्रे शोधा...',
    },
    'search_hint_nursery_prefix': {
      AppLanguage.en: 'Search varieties in',
      AppLanguage.hi: 'में किस्में खोजें:',
      AppLanguage.mr: 'मध्ये वाण शोधा:',
    },
    'crops_for': {
      AppLanguage.en: 'Crops for',
      AppLanguage.hi: 'के लिए फसलें',
      AppLanguage.mr: 'साठी पिके',
    },
    'popular_crops_regional': {
      AppLanguage.en: 'Popular Agricultural Crops (Regional)',
      AppLanguage.hi: 'लोकप्रिय कृषि फसलें (क्षेत्रीय)',
      AppLanguage.mr: 'लोकप्रिय कृषी पिके (प्रादेशिक)',
    },
    'farmer_best_sellers': {
      AppLanguage.en: 'Farmer Best Sellers & High Demand',
      AppLanguage.hi: 'सर्वाधिक लोकप्रिय एवं मांग वाले पौधे',
      AppLanguage.mr: 'शेतकऱ्यांची सर्वाधिक पसंती व मागणी',
    },
    'view_all_varieties': {
      AppLanguage.en: 'View All Varieties',
      AppLanguage.hi: 'सभी किस्में देखें',
      AppLanguage.mr: 'सर्व वाण पहा',
    },
    'no_registered_nurseries_in': {
      AppLanguage.en: 'No registered nurseries found in',
      AppLanguage.hi: 'में कोई पंजीकृत नर्सरी नहीं मिली',
      AppLanguage.mr: 'मध्ये कोणतीही नोंदणीकृत रोपवाटिका आढळली नाही',
    },
    'free_delivery_unlocked': {
      AppLanguage.en: '🎉 You unlocked FREE Farm-Direct Nursery Delivery!',
      AppLanguage.hi: '🎉 आपको मुफ़्त फार्म-डायरेक्ट डिलीवरी मिली!',
      AppLanguage.mr: '🎉 तुम्हाला मोफत फार्म-डायरेक्ट डिलिव्हरी मिळाली आहे!',
    },
    'add_more_for_free_delivery': {
      AppLanguage.en: 'more for FREE Nursery Delivery!',
      AppLanguage.hi: 'और जोड़ें मुफ़्त डिलीवरी के लिए!',
      AppLanguage.mr: 'आणखी खरेदी करा मोफत डिलिव्हरीसाठी!',
    },
    'add_word': {
      AppLanguage.en: 'Add',
      AppLanguage.hi: 'जोड़ें',
      AppLanguage.mr: 'आणखी',
    },
    'fulfilling_nursery_prefix': {
      AppLanguage.en: 'Fulfilling Nursery:',
      AppLanguage.hi: 'आपूर्तिकर्ता नर्सरी:',
      AppLanguage.mr: 'पुरवठादार रोपवाटिका:',
    },
    'browse_nursery_products': {
      AppLanguage.en: 'Browse Nursery Products',
      AppLanguage.hi: 'नर्सरी उत्पाद देखें',
      AppLanguage.mr: 'रोपवाटिकेची उत्पादने पहा',
    },
    'rating_breakdown': {
      AppLanguage.en: 'Rating Breakdown',
      AppLanguage.hi: 'रेटिंग विवरण',
      AppLanguage.mr: 'रेटिंग तपशील',
    },
    'verified_badge': {
      AppLanguage.en: 'Verified',
      AppLanguage.hi: 'सत्यापित',
      AppLanguage.mr: 'सत्यापित',
    },
    'about_us': {
      AppLanguage.en: 'About Us',
      AppLanguage.hi: 'हमारे बारे में',
      AppLanguage.mr: 'आमच्याबद्दल',
    },
    'about_nursery_sub': {
      AppLanguage.en: 'Providing high quality seedlings to farmers across the region. Approved and verified by AVR Green.',
      AppLanguage.hi: 'क्षेत्र के किसानों को उच्च गुणवत्ता वाले पौधे प्रदान करना। एवीआर ग्रीन द्वारा प्रमाणित।',
      AppLanguage.mr: 'परिसरातील शेतकऱ्यांना उच्च दर्जाची रोपे पुरवणे. एव्हीआर ग्रीन द्वारे प्रमाणित.',
    },
    'view_available_varieties': {
      AppLanguage.en: 'View Available Varieties',
      AppLanguage.hi: 'उपलब्ध किस्में देखें',
      AppLanguage.mr: 'उपलब्ध वाण पहा',
    },
    'expected_batch_date': {
      AppLanguage.en: 'Expected Batch Readiness Date',
      AppLanguage.hi: 'बैच तैयार होने की अपेक्षित तिथि',
      AppLanguage.mr: 'बॅच तयार होण्याची अपेक्षित तारीख',
    },
    'prebooking_confirmed_title': {
      AppLanguage.en: 'Pre-Booking Confirmed!',
      AppLanguage.hi: 'प्री-बुकिंग की पुष्टि हो गई!',
      AppLanguage.mr: 'पूर्व-नोंदणी निश्चित झाली!',
    },
    'prebooking_confirmed_desc': {
      AppLanguage.en: 'The nursery manager will contact you once seedlings are ready for dispatch.',
      AppLanguage.hi: 'पौधे तैयार होने पर नर्सरी प्रबंधक आपसे संपर्क करेंगे।',
      AppLanguage.mr: 'रोपे तयार झाल्यावर रोपवाटिका व्यवस्थापक तुमच्याशी संपर्क साधतील.',
    },
    'back_to_store': {
      AppLanguage.en: 'Back to Store',
      AppLanguage.hi: 'स्टोर पर वापस जाएं',
      AppLanguage.mr: 'स्टोअरवर परत जा',
    },
    'notify_when_available': {
      AppLanguage.en: 'Notify When Available',
      AppLanguage.hi: 'उपलब्ध होने पर सूचित करें',
      AppLanguage.mr: 'उपलब्ध झाल्यावर कळवा',
    },
    'notify_modal_desc': {
      AppLanguage.en: 'We will alert you via WhatsApp / SMS as soon as fresh seedling batches are potted.',
      AppLanguage.hi: 'नई पौध तैयार होते ही हम आपको व्हाट्सएप/एसएमएस से सूचित करेंगे।',
      AppLanguage.mr: 'नवीन रोपांची बॅच तयार होताच आम्ही तुम्हाला व्हॉट्सॲप/एसएमएस द्वारे कळवू.',
    },
    'plants_unit': {
      AppLanguage.en: 'Plants',
      AppLanguage.hi: 'पौधे',
      AppLanguage.mr: 'रोपे',
    },
    'save_bulk_discounts': {
      AppLanguage.en: 'Save on bulk seedling trays and advance crop bookings directly from verified regional nurseries.',
      AppLanguage.hi: 'प्रमाणित क्षेत्रीय नर्सरियों से थोक ट्रे और अग्रिम बुकिंग पर छूट पाएं।',
      AppLanguage.mr: 'प्रमाणित प्रादेशिक रोपवाटिकांकडून ठोक ट्रे आणि पूर्व-नोंदणीवर सवलत मिळवा.'
    },
    'official_nursery_campaigns': {
      AppLanguage.en: 'OFFICIAL NURSERY CAMPAIGNS',
      AppLanguage.hi: 'आधिकारिक नर्सरी अभियान',
      AppLanguage.mr: 'अधिकृत रोपवाटिका मोहिमा',
    },
    'verified_plantation_discounts': {
      AppLanguage.en: 'Verified Plantation Discounts',
      AppLanguage.hi: 'सत्यापित रोपण छूट',
      AppLanguage.mr: 'प्रमाणित लागवड सवलत',
    },
    'campaign_active': {
      AppLanguage.en: 'Campaign Active',
      AppLanguage.hi: 'सक्रिय अभियान',
      AppLanguage.mr: 'सक्रिय मोहीम',
    },
    'claim_discount_prebook': {
      AppLanguage.en: 'Claim Discount & Pre-Book',
      AppLanguage.hi: 'छूट प्राप्त करें एवं प्री-बुक करें',
      AppLanguage.mr: 'सवलत मिळवा व पूर्व-नोंदणी करा',
    },
    'cart_empty_toast': {
      AppLanguage.en: 'Cart is empty!',
      AppLanguage.hi: 'कार्ट खाली है!',
      AppLanguage.mr: 'कार्ट रिकामी आहे!',
    },
    'invoice_auto_generated_note': {
      AppLanguage.en: 'Your tax invoice is automatically generated and ready in Orders.',
      AppLanguage.hi: 'आपका कर चालान स्वचालित रूप से जनरेट होकर ऑर्डर्स में उपलब्ध है।',
      AppLanguage.mr: 'तुमचे कर बीजक आपोआप तयार होऊन ऑर्डर्स विभागात उपलब्ध आहे.',
    },
    'cards_accepted_label': {
      AppLanguage.en: 'Visa, MasterCard, RuPay accepted',
      AppLanguage.hi: 'वीज़ा, मास्टरकार्ड, रुपे स्वीकार्य',
      AppLanguage.mr: 'व्हिसा, मास्टरकार्ड, रुपे स्वीकारले जातात',
    },
    'pay_cod_desc': {
      AppLanguage.en: 'Pay when plants arrive at your farm or home',
      AppLanguage.hi: 'पौध आपके खेत या घर पहुंचने पर भुगतान करें',
      AppLanguage.mr: 'रोपे शेतात किंवा घरी पोहोचल्यावर पैसे द्या',
    },
    'profile_updated_success': {
      AppLanguage.en: 'Profile details updated successfully',
      AppLanguage.hi: 'प्रोफ़ाइल विवरण सफलतापूर्वक अपडेट किया गया',
      AppLanguage.mr: 'प्रोफाइल तपशील यशस्वीरित्या अपडेट केले',
    },
    'connecting_helpline': {
      AppLanguage.en: 'Connecting to AVR Green Agronomy Helpline...',
      AppLanguage.hi: 'एवीआर ग्रीन कृषि हेल्पलाइन से संपर्क हो रहा है...',
      AppLanguage.mr: 'एव्हीआर ग्रीन कृषी हेल्पलाइनशी संपर्क साधत आहे...',
    },
    'farming_location_purpose': {
      AppLanguage.en: 'Used to match nearby certified seedling nurseries in Maharashtra.',
      AppLanguage.hi: 'महाराष्ट्र में निकटतम प्रमाणित पौधशालाओं से जोड़ने के लिए उपयोग किया जाता है।',
      AppLanguage.mr: 'महाराष्ट्रातील जवळच्या प्रमाणित रोपवाटिकांशी जोडण्यासाठी वापरले जाते.',
    },
    'photo_provenance_title': {
      AppLanguage.en: 'Agricultural Photo Provenance',
      AppLanguage.hi: 'कृषि छायाचित्र प्रामाणिकता',
      AppLanguage.mr: 'कृषी छायाचित्र प्रामाणिकता',
    },
    'photo_provenance_desc': {
      AppLanguage.en: 'This image depicts actual botanical seedling stock grown at participating nurseries under AVR Green standards.',
      AppLanguage.hi: 'यह चित्र एवीआर ग्रीन मानकों के तहत भाग लेने वाली नर्सरियों में उगाए गए वास्तविक पौधों का है।',
      AppLanguage.mr: 'हे छायाचित्र एव्हीआर ग्रीन मानकांनुसार सहभागी रोपवाटिकांमध्ये वाढवलेल्या प्रत्यक्ष रोपांचे आहे.',
    },
    'close_verification': {
      AppLanguage.en: 'Close Verification',
      AppLanguage.hi: 'सत्यापन बंद करें',
      AppLanguage.mr: 'पडताळणी बंद करा',
    },
    'cart_contains_plants_from': {
      AppLanguage.en: 'Your cart currently contains plants from',
      AppLanguage.hi: 'आपकी कार्ट में वर्तमान में पौधे हैं:',
      AppLanguage.mr: 'तुमच्या कार्टमध्ये सध्या रोपे आहेत:',
    },
    'single_nursery_rule_msg': {
      AppLanguage.en: 'To maintain biosecurity and direct delivery, you can only order from one nursery at a time.',
      AppLanguage.hi: 'सुरक्षा और सीधी डिलीवरी के लिए, आप एक समय में केवल एक नर्सरी से ऑर्डर कर सकते हैं।',
      AppLanguage.mr: 'सुरक्षितता आणि थेट डिलिव्हरीसाठी, तुम्ही एका वेळी एकाच रोपवाटिकेकडून ऑर्डर करू शकता.',
    },

    // ── Owner Operations & Management ───────────────────────────────────────
    'namaste_greeting': {
      AppLanguage.en: 'Namaste,',
      AppLanguage.hi: 'नमस्ते,',
      AppLanguage.mr: 'नमस्ते,',
    },
    'grower_name': {
      AppLanguage.en: 'Grower',
      AppLanguage.hi: 'कृषक',
      AppLanguage.mr: 'शेतकरी मित्र',
    },
    'quick_action_add_variety': {
      AppLanguage.en: '+ Add Variety',
      AppLanguage.hi: '+ नई किस्म जोड़ें',
      AppLanguage.mr: '+ नवीन वाण जोडा',
    },
    'quick_action_create_offer': {
      AppLanguage.en: '+ Create Offer',
      AppLanguage.hi: '+ नया ऑफ़र बनाएं',
      AppLanguage.mr: '+ नवीन ऑफर तयार करा',
    },
    'quick_action_manage_location': {
      AppLanguage.en: 'Manage Location',
      AppLanguage.hi: 'स्थान प्रबंधन',
      AppLanguage.mr: 'स्थान व्यवस्थापन',
    },
    'quick_action_stock_adjust': {
      AppLanguage.en: 'Stock Adjust',
      AppLanguage.hi: 'स्टॉक समायोजन',
      AppLanguage.mr: 'साठा समायोजन',
    },
    'quick_action_all_orders': {
      AppLanguage.en: 'All Orders',
      AppLanguage.hi: 'सभी ऑर्डर्स',
      AppLanguage.mr: 'सर्व ऑर्डर्स',
    },
    'quick_action_deliveries': {
      AppLanguage.en: 'Deliveries',
      AppLanguage.hi: 'वितरण',
      AppLanguage.mr: 'डिलिव्हरी',
    },
    'no_nursery_orders_yet': {
      AppLanguage.en: 'No nursery orders received yet',
      AppLanguage.hi: 'अभी तक कोई ऑर्डर प्राप्त नहीं हुआ',
      AppLanguage.mr: 'अद्याप कोणतीही ऑर्डर मिळालेली नाही',
    },
    'orders_auto_appear': {
      AppLanguage.en: 'Orders placed by farmers will automatically appear here.',
      AppLanguage.hi: 'किसानों द्वारा दिए गए ऑर्डर यहां दिखाई देंगे।',
      AppLanguage.mr: 'शेतकऱ्यांनी दिलेले ऑर्डर्स येथे दिसतील.',
    },
    'all_prebookings_processed': {
      AppLanguage.en: 'All farmer pre-bookings have been processed! No pending approvals.',
      AppLanguage.hi: 'सभी किसान प्री-बुकिंग स्वीकृत हो चुकी हैं! कोई लंबित नहीं।',
      AppLanguage.mr: 'सर्व शेतकरी पूर्व-नोंदणी मंजूर झाल्या आहेत! कोणतीही प्रलंबित नाही.',
    },
    'publish_announcements_hint': {
      AppLanguage.en: 'Publish production announcements so farmers can pre-book next batches.',
      AppLanguage.hi: 'उत्पादन घोषणाएं प्रकाशित करें ताकि किसान अगली पौध की अग्रिम बुकिंग कर सकें।',
      AppLanguage.mr: 'उत्पादन घोषणा प्रकाशित करा जेणेकरून शेतकरी पुढील रोपांची पूर्व-नोंदणी करू शकतील.',
    },
    'location_updated_msg': {
      AppLanguage.en: 'Location updated successfully',
      AppLanguage.hi: 'स्थान सफलतापूर्वक अपडेट किया गया',
      AppLanguage.mr: 'स्थान यशस्वीरित्या अपडेट केले',
    },
    'manage_location_title': {
      AppLanguage.en: 'Manage Location',
      AppLanguage.hi: 'स्थान प्रबंधन',
      AppLanguage.mr: 'स्थान व्यवस्थापन',
    },
    'no_locations_found': {
      AppLanguage.en: 'No locations found.',
      AppLanguage.hi: 'कोई स्थान नहीं मिला।',
      AppLanguage.mr: 'कोणतेही स्थान आढळले नाही.',
    },
    'nursery_branch_details': {
      AppLanguage.en: 'Nursery Branch Details',
      AppLanguage.hi: 'नर्सरी शाखा विवरण',
      AppLanguage.mr: 'रोपवाटिका शाखा तपशील',
    },
    'marketplace_visibility': {
      AppLanguage.en: 'Marketplace Visibility',
      AppLanguage.hi: 'मार्केटप्लेस दृश्यता',
      AppLanguage.mr: 'मार्केटप्लेस दृश्यमानता',
    },
    'business_profile_title': {
      AppLanguage.en: 'Business Profile',
      AppLanguage.hi: 'व्यावसायिक प्रोफ़ाइल',
      AppLanguage.mr: 'व्यवसाय प्रोफाइल',
    },
    'profile_saved_success': {
      AppLanguage.en: 'Business profile saved successfully!',
      AppLanguage.hi: 'व्यावसायिक प्रोफ़ाइल सहेजी गई!',
      AppLanguage.mr: 'व्यवसाय प्रोफाइल सेव्ह केले!',
    },
    'business_information': {
      AppLanguage.en: 'Business Information',
      AppLanguage.hi: 'व्यावसायिक जानकारी',
      AppLanguage.mr: 'व्यवसाय माहिती',
    },
    'create_offer_title': {
      AppLanguage.en: 'Create Offer',
      AppLanguage.hi: 'नया ऑफ़र बनाएं',
      AppLanguage.mr: 'नवीन ऑफर तयार करा',
    },
    'create_first_offer_sub': {
      AppLanguage.en: 'Create Your First Offer',
      AppLanguage.hi: 'अपना पहला ऑफ़र बनाएं',
      AppLanguage.mr: 'तुमची पहिली ऑफर तयार करा',
    },
    'pause_btn': {
      AppLanguage.en: 'Pause',
      AppLanguage.hi: 'रोकें',
      AppLanguage.mr: 'थांबवा',
    },
    'resume_btn': {
      AppLanguage.en: 'Resume',
      AppLanguage.hi: 'सक्रिय करें',
      AppLanguage.mr: 'सुरू करा',
    },
    'delete_btn': {
      AppLanguage.en: 'Delete',
      AppLanguage.hi: 'हटाएं',
      AppLanguage.mr: 'हटवा',
    },
    'offer_status_active': {
      AppLanguage.en: 'Active',
      AppLanguage.hi: 'सक्रिय',
      AppLanguage.mr: 'सक्रिय',
    },
    'offer_status_paused': {
      AppLanguage.en: 'Paused',
      AppLanguage.hi: 'रोका गया',
      AppLanguage.mr: 'थांबवले',
    },
    'edit_offer': {
      AppLanguage.en: 'Edit Offer',
      AppLanguage.hi: 'ऑफ़र संपादित करें',
      AppLanguage.mr: 'ऑफर संपादित करा',
    },
    'all_states_tab': {
      AppLanguage.en: 'All States',
      AppLanguage.hi: 'सभी स्थितियाँ',
      AppLanguage.mr: 'सर्व स्थिती',
    },
    'ready_now_upper': {
      AppLanguage.en: 'READY NOW',
      AppLanguage.hi: 'तत्काल उपलब्ध',
      AppLanguage.mr: 'सध्या उपलब्ध',
    },
    'limited_stock_upper': {
      AppLanguage.en: 'LIMITED STOCK',
      AppLanguage.hi: 'सीमित स्टॉक',
      AppLanguage.mr: 'मर्यादित साठा',
    },
    'coming_soon_upper': {
      AppLanguage.en: 'COMING SOON',
      AppLanguage.hi: 'शीघ्र आ रहा है',
      AppLanguage.mr: 'लवकरच येत आहे',
    },
    'sold_out_upper': {
      AppLanguage.en: 'SOLD OUT',
      AppLanguage.hi: 'स्टॉक समाप्त',
      AppLanguage.mr: 'साठा संपला',
    },
    'prebook_avail_upper': {
      AppLanguage.en: 'PRE-BOOK AVAILABLE',
      AppLanguage.hi: 'प्री-बुकिंग उपलब्ध',
      AppLanguage.mr: 'पूर्व-नोंदणी उपलब्ध',
    },
    'adjust_stock': {
      AppLanguage.en: 'Adjust Stock',
      AppLanguage.hi: 'स्टॉक समायोजित करें',
      AppLanguage.mr: 'साठा समायोजित करा',
    },
    'update_inventory': {
      AppLanguage.en: 'Update Inventory',
      AppLanguage.hi: 'इन्वेंट्री अपडेट करें',
      AppLanguage.mr: 'साठा अपडेट करा',
    },
    'save_changes': {
      AppLanguage.en: 'Save Changes',
      AppLanguage.hi: 'परिवर्तन सहेजें',
      AppLanguage.mr: 'बदल सेव्ह करा',
    },
    'today_range': {
      AppLanguage.en: 'Today',
      AppLanguage.hi: 'आज',
      AppLanguage.mr: 'आज',
    },
    'this_week_range': {
      AppLanguage.en: 'This Week',
      AppLanguage.hi: 'इस सप्ताह',
      AppLanguage.mr: 'या आठवड्यात',
    },
    'this_month_range': {
      AppLanguage.en: 'This Month',
      AppLanguage.hi: 'इस महीने',
      AppLanguage.mr: 'या महिन्यात',
    },
    'year_to_date_range': {
      AppLanguage.en: 'Year to Date',
      AppLanguage.hi: 'इस वर्ष',
      AppLanguage.mr: 'या वर्षात',
    },
    'export_pdf': {
      AppLanguage.en: 'Export PDF Report',
      AppLanguage.hi: 'पीडीएफ रिपोर्ट डाउनलोड करें',
      AppLanguage.mr: 'पीडीएफ अहवाल डाउनलोड करा',
    },
    'fulfillment_timeline': {
      AppLanguage.en: 'Fulfillment Timeline',
      AppLanguage.hi: 'आपूर्ति समयरेखा',
      AppLanguage.mr: 'डिलिव्हरी कालमर्यादा',
    },
    'live_track_btn': {
      AppLanguage.en: 'Live Track',
      AppLanguage.hi: 'लाइव ट्रैक करें',
      AppLanguage.mr: 'थेट ट्रॅक करा',
    },
    'agent_en_route': {
      AppLanguage.en: 'Agent En Route',
      AppLanguage.hi: 'वितरक रास्ते में है',
      AppLanguage.mr: 'डिलिव्हरी प्रतिनिधी मार्गावर आहे',
    },
    'estimated_arrival': {
      AppLanguage.en: 'Estimated Arrival',
      AppLanguage.hi: 'अपेक्षित आगमन',
      AppLanguage.mr: 'अपेक्षित वेळ',
    },
    'live_gps_sync': {
      AppLanguage.en: 'LIVE GPS SYNC',
      AppLanguage.hi: 'लाइव जीपीएस सिंक',
      AppLanguage.mr: 'थेट जीपीएस सिंक',
    },
    'nursery_branch': {
      AppLanguage.en: 'Nursery Branch',
      AppLanguage.hi: 'नर्सरी शाखा',
      AppLanguage.mr: 'रोपवाटिका शाखा',
    },
    'customer_destination': {
      AppLanguage.en: 'Customer Farm / Delivery Point',
      AppLanguage.hi: 'ग्राहक खेत / वितरण स्थल',
      AppLanguage.mr: 'शेतकरी शेत / डिलिव्हरी ठिकाण',
    },
    'enter_phone_name_err': {
      AppLanguage.en: 'Please enter your name and phone number',
      AppLanguage.hi: 'कृपया अपना नाम और मोबाइल नंबर दर्ज करें',
      AppLanguage.mr: 'कृपया तुमचे नाव आणि मोबाईल नंबर टाका',
    },
    'platform_control_title': {
      AppLanguage.en: 'AVR Mitra SaaS Platform Control',
      AppLanguage.hi: 'एवीआर मित्र सास प्लेटफॉर्म नियंत्रण',
      AppLanguage.mr: 'एव्हीआर मित्र सास प्लॅटफॉर्म नियंत्रण',
    },
    'onboarded_nurseries_stat': {
      AppLanguage.en: 'Onboarded Nursery Businesses',
      AppLanguage.hi: 'पंजीकृत पौधशालाएं',
      AppLanguage.mr: 'नोंदणीकृत रोपवाटिका',
    },
    'active_subscriptions_stat': {
      AppLanguage.en: 'Active SaaS Subscription Plans',
      AppLanguage.hi: 'सक्रिय सास सदस्यता योजनाएं',
      AppLanguage.mr: 'सक्रिय सास सबस्क्रिप्शन प्लॅन',
    },
    'farmer_offers_title': {
      AppLanguage.en: 'Farmer Offers & Campaigns',
      AppLanguage.hi: 'किसान ऑफर्स और अभियान',
      AppLanguage.mr: 'शेतकरी ऑफर्स आणि मोहिमा',
    },
    'refresh_offers': {
      AppLanguage.en: 'Refresh Offers',
      AppLanguage.hi: 'ऑफर्स रिफ्रेश करें',
      AppLanguage.mr: 'ऑफर्स रिफ्रेश करा',
    },
    'farmer_campaign_subtitle': {
      AppLanguage.en: 'Save on bulk seedling trays and advance crop bookings directly from verified regional nurseries.',
      AppLanguage.hi: 'सत्यापित क्षेत्रीय पौधशालाओं से सीधे बल्क पौध ट्रे और अग्रिम फसल बुकिंग पर बचत करें।',
      AppLanguage.mr: 'सत्यापित प्रादेशिक रोपवाटिकांमधून थेट बियाणे ट्रे आणि आगाऊ पीक बुकिंगवर बचत करा.',
    },
    'no_offers_found_for': {
      AppLanguage.en: 'No active offers found for',
      AppLanguage.hi: 'इसके लिए कोई सक्रिय ऑफर नहीं मिली:',
      AppLanguage.mr: 'यासाठी कोणतीही सक्रिय ऑफर सापडली नाही:',
    },
    'pre_book': {
      AppLanguage.en: 'PRE-BOOK',
      AppLanguage.hi: 'प्री-बुक',
      AppLanguage.mr: 'प्री-बुक',
    },
    'crop_label': {
      AppLanguage.en: 'Crop',
      AppLanguage.hi: 'फसल',
      AppLanguage.mr: 'पीक',
    },
    'min_trays_label': {
      AppLanguage.en: 'Min {count} Trays',
      AppLanguage.hi: 'न्यूनतम {count} ट्रे',
      AppLanguage.mr: 'किमान {count} ट्रे',
    },
    'min_order_val_label': {
      AppLanguage.en: 'Min ₹{val}',
      AppLanguage.hi: 'न्यूनतम ₹{val}',
      AppLanguage.mr: 'किमान ₹{val}',
    },
    'prebook_offer_btn': {
      AppLanguage.en: 'Pre-Book Offer',
      AppLanguage.hi: 'प्री-बुक ऑफर',
      AppLanguage.mr: 'प्री-बुक ऑफर',
    },
    'shop_offer_btn': {
      AppLanguage.en: 'Shop Offer',
      AppLanguage.hi: 'ऑफर खरीदें',
      AppLanguage.mr: 'ऑफर खरेदी करा',
    },
    'nursery_storefront_desc': {
      AppLanguage.en: 'Providing high quality seedlings to farmers across the region. Approved and verified by AVR Green.',
      AppLanguage.hi: 'क्षेत्र के किसानों को उच्च गुणवत्ता वाली पौध उपलब्ध कराना। AVR Green द्वारा स्वीकृत और सत्यापित।',
      AppLanguage.mr: 'प्रदेशातील शेतकऱ्यांना उच्च दर्जाची रोपे पुरवणे. AVR Green द्वारे मंजूर आणि प्रमाणित.',
    },
    'error_loading_storefront': {
      AppLanguage.en: 'Error loading storefront',
      AppLanguage.hi: 'स्टोरफ्रंट लोड करने में त्रुटि',
      AppLanguage.mr: 'स्टोअरफ्रंट लोड करताना त्रुटी आली',
    },
    'botanical_transport_guarantee': {
      AppLanguage.en: 'Botanical Transport Guarantee: Seedlings packed in ventilated, root-safe biodegradable wraps.',
      AppLanguage.hi: 'वानस्पतिक परिवहन गारंटी: पौध हवादार, जड़-सुरक्षित बायोडिग्रेडेबल आवरण में पैक की जाती है।',
      AppLanguage.mr: 'वनस्पती वाहतूक हमी: रोपे हवेशीर, मुळांना सुरक्षित ठेवणाऱ्या बायोडीग्रेडेबल रॅप्समध्ये पॅक केली जातात.',
    },
    'instant_conf_invoice': {
      AppLanguage.en: 'Instant confirmation & digital invoice',
      AppLanguage.hi: 'त्वरित पुष्टि और डिजिटल इनवॉइस',
      AppLanguage.mr: 'झटपट पुष्टीकरण आणि डिजिटल बीजक',
    },
    'credit_debit_card': {
      AppLanguage.en: 'Credit / Debit Card',
      AppLanguage.hi: 'क्रेडिट / डेबिट कार्ड',
      AppLanguage.mr: 'क्रेडिट / डेबिट कार्ड',
    },
    'card_networks': {
      AppLanguage.en: 'Visa, MasterCard, RuPay',
      AppLanguage.hi: 'Visa, MasterCard, RuPay',
      AppLanguage.mr: 'Visa, MasterCard, RuPay',
    },
    'cod_label': {
      AppLanguage.en: 'Cash on Delivery (COD)',
      AppLanguage.hi: 'कैश ऑन डिलीवरी (COD)',
      AppLanguage.mr: 'कॅश ऑन डिलिव्हरी (COD)',
    },
    'cod_subtitle': {
      AppLanguage.en: 'Pay when plants arrive at your farm or home',
      AppLanguage.hi: 'पौध आपके खेत या घर पहुंचने पर भुगतान करें',
      AppLanguage.mr: 'रोपे शेतात किंवा घरी पोहोचल्यावर पैसे द्या',
    },
    'tax_invoice_ready_msg': {
      AppLanguage.en: 'Your tax invoice is automatically generated and ready in Orders.',
      AppLanguage.hi: 'आपका कर इनवॉइस स्वचालित रूप से जनरेट हो गया है और ऑर्डर्स में उपलब्ध है।',
      AppLanguage.mr: 'तुमचे कर बीजक स्वयंचलितपणे तयार झाले आहे आणि ऑर्डर विभागात उपलब्ध आहे.',
    },
    'cart_is_empty': {
      AppLanguage.en: 'Cart is empty!',
      AppLanguage.hi: 'कार्ट खाली है!',
      AppLanguage.mr: 'कार्ट रिकामी आहे!',
    },
    'advance_prebooking': {
      AppLanguage.en: 'ADVANCE PRE-BOOKING',
      AppLanguage.hi: 'अग्रिम प्री-बुकिंग',
      AppLanguage.mr: 'आगाऊ प्री-बुकिंग',
    },
    'expected_batch_readiness': {
      AppLanguage.en: 'Expected Batch Readiness Date',
      AppLanguage.hi: 'अपेक्षित बैच तैयार होने की तिथि',
      AppLanguage.mr: 'अपेक्षित बॅच तयार होण्याची तारीख',
    },
    'fresh_polyhouse_lot_desc': {
      AppLanguage.en: '10-15 Days (Fresh Polyhouse Lot)',
      AppLanguage.hi: '10-15 दिन (नया पॉलीहाउस लॉट)',
      AppLanguage.mr: '१०-१५ दिवस (नवीन पॉलीहाऊस लॉट)',
    },
    'next_batch_capacity': {
      AppLanguage.en: 'Next batch capacity',
      AppLanguage.hi: 'अगली बैच क्षमता',
      AppLanguage.mr: 'पुढील बॅच क्षमता',
    },
    'plants_scheduled': {
      AppLanguage.en: 'plants scheduled',
      AppLanguage.hi: 'पौधे निर्धारित',
      AppLanguage.mr: 'रोपे नियोजित',
    },
    'select_prebooking_unit': {
      AppLanguage.en: '1. Select Pre-Booking Unit',
      AppLanguage.hi: '1. प्री-बुकिंग इकाई चुनें',
      AppLanguage.mr: '१. प्री-बुकिंग युनिट निवडा',
    },
    'bulk_lot': {
      AppLanguage.en: 'Bulk Lot',
      AppLanguage.hi: 'थोक लॉट',
      AppLanguage.mr: 'बल्क लॉट',
    },
    'choose_quantity': {
      AppLanguage.en: '2. Choose Quantity',
      AppLanguage.hi: '2. मात्रा चुनें',
      AppLanguage.mr: '२. प्रमाण निवडा',
    },
    'farmer_contact_delivery_details': {
      AppLanguage.en: '3. Farmer Contact & Delivery Details',
      AppLanguage.hi: '3. किसान संपर्क और डिलीवरी विवरण',
      AppLanguage.mr: '३. शेतकरी संपर्क आणि वितरण तपशील',
    },
    'farmer_name': {
      AppLanguage.en: 'Farmer Name',
      AppLanguage.hi: 'किसान का नाम',
      AppLanguage.mr: 'शेतकऱ्याचे नाव',
    },
    'phone_number': {
      AppLanguage.en: 'Phone Number',
      AppLanguage.hi: 'फ़ोन नंबर',
      AppLanguage.mr: 'फोन नंबर',
    },
    'delivery_location_hint': {
      AppLanguage.en: 'Village / Taluka / Delivery Location',
      AppLanguage.hi: 'गाँव / तालुका / डिलीवरी स्थान',
      AppLanguage.mr: 'गाव / तालुका / वितरणाचे ठिकाण',
    },
    'total_plants_reserved': {
      AppLanguage.en: 'Total Plants Reserved:',
      AppLanguage.hi: 'कुल आरक्षित पौधे:',
      AppLanguage.mr: 'एकूण आरक्षित रोपे:',
    },
    'estimated_total_amount': {
      AppLanguage.en: 'Estimated Total Amount:',
      AppLanguage.hi: 'अनुमानित कुल राशि:',
      AppLanguage.mr: 'अंदाजे एकूण रक्कम:',
    },
    'advance_payable': {
      AppLanguage.en: 'Advance Payable (20%):',
      AppLanguage.hi: 'अग्रिम देय (20%):',
      AppLanguage.mr: 'आगाऊ देय रक्कम (२०%):',
    },
    'balance_due_delivery': {
      AppLanguage.en: 'Balance Due at Pickup/Delivery (80%):',
      AppLanguage.hi: 'डिलीवरी के समय शेष राशि (80%):',
      AppLanguage.mr: 'वितरणाच्या वेळी उर्वरित रक्कम (८०%):',
    },
    'confirm_prebooking': {
      AppLanguage.en: 'Confirm Pre-Booking',
      AppLanguage.hi: 'प्री-बुकिंग कन्फर्म करें',
      AppLanguage.mr: 'प्री-बुकिंग निश्चित करा',
    },
    'reserving_batch': {
      AppLanguage.en: 'Reserving Polyhouse Batch...',
      AppLanguage.hi: 'पॉलीहाउस बैच आरक्षित की जा रही है...',
      AppLanguage.mr: 'पॉलीहाऊस बॅच आरक्षित करत आहे...',
    },
    'verified_reservation_note': {
      AppLanguage.en: 'Verified Nursery Reservation • Zero ready inventory deducted',
      AppLanguage.hi: 'सत्यापित पौधशाला आरक्षण • तैयार स्टॉक से कोई कटौती नहीं',
      AppLanguage.mr: 'प्रमाणित रोपवाटिका आरक्षण • तयार स्टॉकमधून कोणतीही वजावट नाही',
    },
    'farmer_mobile_number': {
      AppLanguage.en: 'Farmer Mobile Number *',
      AppLanguage.hi: 'किसान का मोबाइल नंबर *',
      AppLanguage.mr: 'शेतकऱ्याचा मोबाईल नंबर *',
    },
    'phone_alert_hint': {
      AppLanguage.en: 'Enter 10-digit number for SMS / WhatsApp alert',
      AppLanguage.hi: 'SMS / WhatsApp अलर्ट के लिए 10-अंकीय नंबर दर्ज करें',
      AppLanguage.mr: 'SMS / WhatsApp सूचनांसाठी १० अंकी नंबर प्रविष्ट करा',
    },
    'estimated_quantity': {
      AppLanguage.en: 'Estimated Quantity',
      AppLanguage.hi: 'अनुमानित मात्रा',
      AppLanguage.mr: 'अंदाजे प्रमाण',
    },
    'unit_label': {
      AppLanguage.en: 'Unit',
      AppLanguage.hi: 'इकाई',
      AppLanguage.mr: 'युनिट',
    },
    'alert_me_when_ready': {
      AppLanguage.en: 'Alert Me When Ready',
      AppLanguage.hi: 'तैयार होने पर मुझे बताएं',
      AppLanguage.mr: 'तयार झाल्यावर मला सूचना द्या',
    },
    'registering': {
      AppLanguage.en: 'Registering...',
      AppLanguage.hi: 'पंजीकरण हो रहा है...',
      AppLanguage.mr: 'नोंदणी करत आहे...',
    },
    'notification_set_success': {
      AppLanguage.en: 'Notification set! We will alert you when plants are ready.',
      AppLanguage.hi: 'अलर्ट सेट हो गया! पौधे तैयार होने पर हम आपको सूचित करेंगे।',
      AppLanguage.mr: 'सूचना सेट केली! रोपे तयार झाल्यावर आम्ही आपल्याला कळवू.',
    },
    'verified_farmer_reviews': {
      AppLanguage.en: 'verified farmer reviews',
      AppLanguage.hi: 'सत्यापित किसान समीक्षाएं',
      AppLanguage.mr: 'सत्यापित शेतकरी पुनरावलोकने',
    },
    'plant_quality': {
      AppLanguage.en: 'Plant Quality',
      AppLanguage.hi: 'पौधों की गुणवत्ता',
      AppLanguage.mr: 'रोपांची गुणवत्ता',
    },
    'packaging': {
      AppLanguage.en: 'Packaging',
      AppLanguage.hi: 'पैकेजिंग',
      AppLanguage.mr: 'पॅकेजिंग',
    },
    'value_for_money': {
      AppLanguage.en: 'Value for Money',
      AppLanguage.hi: 'किफायती',
      AppLanguage.mr: 'किफायतशीर',
    },
    'marketplace_ranking': {
      AppLanguage.en: 'Marketplace Ranking',
      AppLanguage.hi: 'मार्केटप्लेस रैंकिंग',
      AppLanguage.mr: 'मार्केटप्लेस रँकिंग',
    },
    'nursery_delivery_fleet': {
      AppLanguage.en: 'Nursery Delivery Fleet 🚚',
      AppLanguage.hi: 'पौधशाला डिलीवरी बेड़ा 🚚',
      AppLanguage.mr: 'रोपवाटिका वितरण फ्लीट 🚚',
    },
    'superadmin_title': {
      AppLanguage.en: 'AVR Mitra — Super Admin 🛡️',
      AppLanguage.hi: 'AVR Mitra — सुपर एडमिन 🛡️',
      AppLanguage.mr: 'AVR Mitra — सुपर ॲडमिन 🛡️',
    },
    'trust_badge': {
      AppLanguage.en: 'Trust',
      AppLanguage.hi: 'भरोसा',
      AppLanguage.mr: 'विश्वास',
    },
    'browse_badge': {
      AppLanguage.en: 'Browse',
      AppLanguage.hi: 'देखें',
      AppLanguage.mr: 'ब्राउझ करा',
    },
    'clear_btn': {
      AppLanguage.en: 'Clear',
      AppLanguage.hi: 'हटाएं',
      AppLanguage.mr: 'साफ करा',
    },
    'live_nursery_production_updates': {
      AppLanguage.en: 'Live Nursery Production Updates',
      AppLanguage.hi: 'लाइव पौधशाला उत्पादन अपडेट्स',
      AppLanguage.mr: 'थेट रोपवाटिका उत्पादन अपडेट्स',
    },
    'broadcast_badge': {
      AppLanguage.en: 'BROADCAST',
      AppLanguage.hi: 'प्रसारण',
      AppLanguage.mr: 'प्रसारण',
    },
    'ranking_criteria_title': {
      AppLanguage.en: 'Nursery Ranking Criteria',
      AppLanguage.hi: 'नर्सरी रैंकिंग मानदंड',
      AppLanguage.mr: 'रोपवाटिका रँकिंग निकष',
    },
    'farmer_special_offers': {
      AppLanguage.en: 'Farmer Special Offers',
      AppLanguage.hi: 'विशेष किसान ऑफ़र्स',
      AppLanguage.mr: 'विशेष शेतकरी ऑफर्स',
    },
    'live_track': {
      AppLanguage.en: 'Live Track',
      AppLanguage.hi: 'लाइव ट्रैक',
      AppLanguage.mr: 'थेट ट्रॅक',
    },
    'complete_pod': {
      AppLanguage.en: 'Complete (POD)',
      AppLanguage.hi: 'वितरण पूर्ण करें (POD)',
      AppLanguage.mr: 'वितरण पूर्ण (POD)',
    },
    'verify_otp': {
      AppLanguage.en: 'Verify OTP',
      AppLanguage.hi: 'ओटीपी सत्यापित करें',
      AppLanguage.mr: 'ओटीपी पडताळा',
    },
    'customer_home': {
      AppLanguage.en: 'Customer Farm / Home',
      AppLanguage.hi: 'किसान खेत / घर',
      AppLanguage.mr: 'शेतकरी शेत / घर',
    },
    'location_match_desc': {
      AppLanguage.en: 'Used to match nearby certified seedling nurseries in Maharashtra.',
      AppLanguage.hi: 'महाराष्ट्र में निकटतम प्रमाणित पौधशालाओं को खोजने के लिए उपयोग किया जाता है।',
      AppLanguage.mr: 'महाराष्ट्रातील जवळच्या प्रमाणित रोपवाटिका शोधण्यासाठी वापरले जाते.',
    },
    'connecting_agronomy_helpline': {
      AppLanguage.en: 'Connecting to AVR Green Agronomy Helpline...',
      AppLanguage.hi: 'एवीआर ग्रीन कृषि हेल्पलाइन से जुड़ रहे हैं...',
      AppLanguage.mr: 'एव्हीआर ग्रीन कृषी हेल्पलाइनशी जोडत आहे...',
    },
    'delete_offer_title': {
      AppLanguage.en: 'Delete Offer Campaign',
      AppLanguage.hi: 'ऑफर अभियान हटाएं',
      AppLanguage.mr: 'ऑफर मोहीम हटवा',
    },
    'confirm_delete_offer_prefix': {
      AppLanguage.en: 'Are you sure you want to delete',
      AppLanguage.hi: 'क्या आप वाकई हटाना चाहते हैं',
      AppLanguage.mr: 'तुम्हाला नक्की हटवायचे आहे का',
    },
    'confirm_delete_offer_suffix': {
      AppLanguage.en: 'Farmers will no longer see this offer.',
      AppLanguage.hi: 'किसान अब यह ऑफर नहीं देख पाएंगे।',
      AppLanguage.mr: 'शेतकऱ्यांना ही ऑफर आता दिसणार नाही.',
    },
    'offer_deleted_success': {
      AppLanguage.en: 'Offer deleted successfully',
      AppLanguage.hi: 'ऑफर सफलतापूर्वक हटा दी गई',
      AppLanguage.mr: 'ऑफर यशस्वीरित्या हटवली गेली',
    },
    'no_campaigns_found': {
      AppLanguage.en: 'No campaigns found',
      AppLanguage.hi: 'कोई अभियान नहीं मिला',
      AppLanguage.mr: 'कोणतीही मोहीम सापडली नाही',
    },
    'create_first_offer': {
      AppLanguage.en: 'Create Your First Offer',
      AppLanguage.hi: 'अपना पहला ऑफर बनाएं',
      AppLanguage.mr: 'तुमची पहिली ऑफर तयार करा',
    },
    'create_nursery_offer': {
      AppLanguage.en: 'Create Nursery Offer',
      AppLanguage.hi: 'नर्सरी ऑफर बनाएं',
      AppLanguage.mr: 'रोपवाटिका ऑफर तयार करा',
    },
    'live_preview_farmers': {
      AppLanguage.en: 'LIVE PREVIEW (How Farmers See It)',
      AppLanguage.hi: 'लाइव पूर्वावलोकन (किसान इसे कैसे देखते हैं)',
      AppLanguage.mr: 'थेट पूर्वावलोकन (शेतकऱ्यांना कसे दिसेल)',
    },
    'manage_stock': {
      AppLanguage.en: 'Manage Stock',
      AppLanguage.hi: 'स्टॉक प्रबंधित करें',
      AppLanguage.mr: 'साठा व्यवस्थापित करा',
    },
    'update_batch': {
      AppLanguage.en: 'Update Batch',
      AppLanguage.hi: 'बैच अपडेट करें',
      AppLanguage.mr: 'बॅच अपडेट करा',
    },
    'no_prebookings_placed': {
      AppLanguage.en: 'No advance pre-bookings placed yet.',
      AppLanguage.hi: 'अभी तक कोई अग्रिम प्री-बुकिंग नहीं हुई है।',
      AppLanguage.mr: 'अद्याप कोणतीही आगाऊ प्री-बुकिंग केलेली नाही.',
    },
    'decline': {
      AppLanguage.en: 'Decline',
      AppLanguage.hi: 'अस्वीकार करें',
      AppLanguage.mr: 'नकारा',
    },
    'reserved_stock': {
      AppLanguage.en: 'Reserved Stock',
      AppLanguage.hi: 'आरक्षित स्टॉक',
      AppLanguage.mr: 'आरक्षित साठा',
    },
    'prebooked_qty': {
      AppLanguage.en: 'Pre-booked Qty',
      AppLanguage.hi: 'प्री-बुक मात्रा',
      AppLanguage.mr: 'प्री-बुक प्रमाण',
    },
    'next_batch_date': {
      AppLanguage.en: 'Next Batch Date',
      AppLanguage.hi: 'अगली बैच तिथि',
      AppLanguage.mr: 'पुढील बॅच तारीख',
    },
    'pending_prebooks': {
      AppLanguage.en: 'Pending Pre-books',
      AppLanguage.hi: 'लंबित प्री-बुकिंग्स',
      AppLanguage.mr: 'प्रलंबित प्री-बुकिंग्ज',
    },
    'expected_ready_date': {
      AppLanguage.en: 'Expected Date',
      AppLanguage.hi: 'अपेक्षित तिथि',
      AppLanguage.mr: 'अपेक्षित तारीख',
    },
  };

  /// Returns localized string by key and language
  static String get(String key, AppLanguage lang) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry[AppLanguage.en] ?? key;
  }

  /// Convenience lookup using WidgetRef
  static String tr(WidgetRef ref, String key) {
    final lang = ref.watch(appLanguageProvider);
    return get(key, lang);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension on WidgetRef for clean, reactive translation calls: `ref.tr('key')`
// ─────────────────────────────────────────────────────────────────────────────

extension WidgetRefLocalizationX on WidgetRef {
  String tr(String key) {
    final lang = watch(appLanguageProvider);
    return AppStrings.get(key, lang);
  }
}


extension BuildContextLocalizationX on BuildContext {
  String tr(String key) {
    final lang = AppLanguageX.fromCode(Localizations.localeOf(this).languageCode);
    return AppStrings.get(key, lang);
  }
}
