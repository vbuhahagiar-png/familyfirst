class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneAuth = '/phone-auth';

  // Client
  static const String clientHome = '/home';
  static const String search = '/search';
  static const String providersList = '/providers';
  static const String providerDetail = '/provider/:id';
  static const String booking = '/booking/:providerId';
  static const String payment = '/payment/:bookingId';
  static const String bookingConfirmation = '/booking-confirmation/:bookingId';
  static const String bookingsHistory = '/bookings-history';
  static const String profile = '/profile';
  static const String loyalty = '/loyalty';

  // Provider
  static const String providerHome = '/provider-home';
  static const String providerProfileSetup = '/provider-setup';
  static const String providerBookings = '/provider-bookings';
  static const String providerCalendar = '/provider-calendar';
  static const String providerEarnings = '/provider-earnings';
  static const String providerProfile = '/provider-profile';

  // Helpers
  static String providerDetailPath(String id) => '/provider/$id';
  static String bookingPath(String providerId) => '/booking/$providerId';
  static String paymentPath(String bookingId) => '/payment/$bookingId';
  static String bookingConfirmationPath(String bookingId) =>
      '/booking-confirmation/$bookingId';
}
