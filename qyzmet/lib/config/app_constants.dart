class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Qyzmet';
  static const String appSlogan = 'Book. Pay. Relax.';
  static const String appVersion = '1.0.0';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String providersCollection = 'providers';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String loyaltyCollection = 'loyalty';
  static const String paymentsCollection = 'payments';

  // Currency
  static const String currency = 'KZT';
  static const String currencySymbol = '₸';

  // Platform commission
  static const double commissionRate = 0.15; // 15%

  // Loyalty tiers
  static const int loyaltyLevel2Threshold = 5;
  static const int loyaltyLevel3Threshold = 15;
  static const double loyaltyLevel2Discount = 0.05; // 5%
  static const double loyaltyLevel3Discount = 0.10; // 10%

  // Location
  static const String defaultCity = 'Астана';
  static const String defaultCountry = 'Kazakhstan';

  // Pagination
  static const int providersPageSize = 20;
  static const int bookingsPageSize = 15;
  static const int reviewsPageSize = 10;

  // Time
  static const int bookingMinHours = 1;
  static const int bookingMaxHours = 8;
  static const int minBookingHoursAhead = 2;
  static const int maxBookingDaysAhead = 30;

  // Time slots
  static const List<String> timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  // Service categories
  static const List<Map<String, String>> serviceCategories = [
    {
      'id': 'cleaning',
      'nameRu': 'Уборка',
      'nameKk': 'Тазалық',
      'nameEn': 'Cleaning',
      'icon': 'cleaning',
    },
    {
      'id': 'babysitting',
      'nameRu': 'Няня',
      'nameKk': 'Бала күтімі',
      'nameEn': 'Babysitting',
      'icon': 'baby',
    },
    {
      'id': 'repairs',
      'nameRu': 'Ремонт',
      'nameKk': 'Жөндеу',
      'nameEn': 'Repairs',
      'icon': 'tools',
    },
    {
      'id': 'renovation',
      'nameRu': 'Ремонт квартиры',
      'nameKk': 'Пәтер жөндеу',
      'nameEn': 'Renovation',
      'icon': 'renovation',
    },
    {
      'id': 'plumbing',
      'nameRu': 'Сантехника',
      'nameKk': 'Сантехника',
      'nameEn': 'Plumbing',
      'icon': 'plumbing',
    },
    {
      'id': 'electrical',
      'nameRu': 'Электрика',
      'nameKk': 'Электр',
      'nameEn': 'Electrical',
      'icon': 'electrical',
    },
    {
      'id': 'garden',
      'nameRu': 'Сад',
      'nameKk': 'Бау-бақша',
      'nameEn': 'Gardening',
      'icon': 'garden',
    },
    {
      'id': 'moving',
      'nameRu': 'Переезд',
      'nameKk': 'Көшу',
      'nameEn': 'Moving',
      'icon': 'moving',
    },
  ];

  // Astana districts
  static const List<String> astanaDistricts = [
    'Алматы',
    'Байконур',
    'Есиль',
    'Нура',
    'Сарыарка',
    'Байзак',
  ];

  // Booking durations in hours
  static const List<int> bookingDurations = [1, 2, 3, 4, 6, 8];

  // Storage paths
  static const String avatarsPath = 'avatars';
  static const String providersPath = 'providers';
  static const String documentsPath = 'documents';

  // Shared prefs keys
  static const String prefLanguage = 'language';
  static const String prefThemeMode = 'theme_mode';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefUserId = 'user_id';

  // Stripe publishable key placeholder
  static const String stripePublishableKey = 'pk_test_REPLACE_WITH_YOUR_KEY';

  // Google Maps API key placeholder
  static const String googleMapsApiKey = 'REPLACE_WITH_YOUR_MAPS_KEY';

  // Support contact
  static const String supportEmail = 'support@qyzmet.kz';
  static const String supportPhone = '+7 (700) 000-0000';
  static const String supportWhatsapp = '+77000000000';

  // Social links
  static const String instagramUrl = 'https://instagram.com/qyzmet_kz';
  static const String telegramUrl = 'https://t.me/qyzmet_kz';
}
