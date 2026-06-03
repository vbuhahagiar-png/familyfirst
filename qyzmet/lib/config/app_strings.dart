/// Localization string keys used across the app.
/// Actual translations live in lib/l10n/*.arb files.
class AppStrings {
  AppStrings._();

  // Common
  static const String ok = 'ok';
  static const String cancel = 'cancel';
  static const String confirm = 'confirm';
  static const String save = 'save';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String close = 'close';
  static const String next = 'next';
  static const String back = 'back';
  static const String skip = 'skip';
  static const String loading = 'loading';
  static const String error = 'error';
  static const String retry = 'retry';
  static const String success = 'success';
  static const String noResults = 'no_results';
  static const String seeAll = 'see_all';
  static const String required = 'required';

  // App
  static const String appName = 'app_name';
  static const String appSlogan = 'app_slogan';

  // Auth
  static const String login = 'login';
  static const String logout = 'logout';
  static const String register = 'register';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirm_password';
  static const String forgotPassword = 'forgot_password';
  static const String fullName = 'full_name';
  static const String phoneNumber = 'phone_number';
  static const String continueWithGoogle = 'continue_with_google';
  static const String continueWithApple = 'continue_with_apple';
  static const String continueWithPhone = 'continue_with_phone';
  static const String alreadyHaveAccount = 'already_have_account';
  static const String dontHaveAccount = 'dont_have_account';
  static const String otpVerification = 'otp_verification';
  static const String otpSentTo = 'otp_sent_to';
  static const String resendOtp = 'resend_otp';
  static const String verifyCode = 'verify_code';
  static const String iAmClient = 'i_am_client';
  static const String iAmProvider = 'i_am_provider';

  // Onboarding
  static const String onboarding1Title = 'onboarding_1_title';
  static const String onboarding1Desc = 'onboarding_1_desc';
  static const String onboarding2Title = 'onboarding_2_title';
  static const String onboarding2Desc = 'onboarding_2_desc';
  static const String onboarding3Title = 'onboarding_3_title';
  static const String onboarding3Desc = 'onboarding_3_desc';
  static const String getStarted = 'get_started';

  // Home
  static const String home = 'home';
  static const String searchPlaceholder = 'search_placeholder';
  static const String goodMorning = 'good_morning';
  static const String goodAfternoon = 'good_afternoon';
  static const String goodEvening = 'good_evening';
  static const String popularProviders = 'popular_providers';
  static const String serviceCategories = 'service_categories';
  static const String nearbyProviders = 'nearby_providers';

  // Services
  static const String cleaning = 'cleaning';
  static const String babysitting = 'babysitting';
  static const String repairs = 'repairs';
  static const String renovation = 'renovation';
  static const String plumbing = 'plumbing';
  static const String electrical = 'electrical';
  static const String garden = 'garden';
  static const String moving = 'moving';

  // Provider
  static const String provider = 'provider';
  static const String providers = 'providers';
  static const String verified = 'verified';
  static const String rating = 'rating';
  static const String reviews = 'reviews';
  static const String pricePerHour = 'price_per_hour';
  static const String availability = 'availability';
  static const String availableNow = 'available_now';
  static const String bookNow = 'book_now';
  static const String about = 'about';
  static const String experience = 'experience';
  static const String responseTime = 'response_time';

  // Booking
  static const String bookings = 'bookings';
  static const String newBooking = 'new_booking';
  static const String selectDate = 'select_date';
  static const String selectTime = 'select_time';
  static const String selectDuration = 'select_duration';
  static const String address = 'address';
  static const String notes = 'notes';
  static const String totalAmount = 'total_amount';
  static const String bookingConfirmation = 'booking_confirmation';
  static const String bookingSuccess = 'booking_success';
  static const String bookingHistory = 'booking_history';
  static const String upcomingBookings = 'upcoming_bookings';
  static const String pastBookings = 'past_bookings';
  static const String cancelBooking = 'cancel_booking';
  static const String duration = 'duration';

  // Booking statuses
  static const String statusPending = 'status_pending';
  static const String statusConfirmed = 'status_confirmed';
  static const String statusInProgress = 'status_in_progress';
  static const String statusCompleted = 'status_completed';
  static const String statusCancelled = 'status_cancelled';
  static const String statusRefunded = 'status_refunded';

  // Payment
  static const String payment = 'payment';
  static const String payWith = 'pay_with';
  static const String cardNumber = 'card_number';
  static const String expiryDate = 'expiry_date';
  static const String cvv = 'cvv';
  static const String payNow = 'pay_now';
  static const String paymentSuccess = 'payment_success';
  static const String paymentFailed = 'payment_failed';
  static const String googlePay = 'google_pay';
  static const String applePay = 'apple_pay';
  static const String securePayment = 'secure_payment';
  static const String commission = 'commission';

  // Profile
  static const String profile = 'profile';
  static const String myProfile = 'my_profile';
  static const String editProfile = 'edit_profile';
  static const String myBookings = 'my_bookings';
  static const String settings = 'settings';
  static const String language = 'language';
  static const String theme = 'theme';
  static const String notifications = 'notifications';
  static const String helpCenter = 'help_center';
  static const String contactUs = 'contact_us';
  static const String privacyPolicy = 'privacy_policy';
  static const String termsOfService = 'terms_of_service';
  static const String about2 = 'about_app';

  // Loyalty
  static const String loyalty = 'loyalty';
  static const String loyaltyPoints = 'loyalty_points';
  static const String myPoints = 'my_points';
  static const String loyaltyLevel = 'loyalty_level';
  static const String loyaltyLevelStandard = 'loyalty_level_standard';
  static const String loyaltyLevelSilver = 'loyalty_level_silver';
  static const String loyaltyLevelGold = 'loyalty_level_gold';
  static const String discount = 'discount';
  static const String bookingsToNextLevel = 'bookings_to_next_level';

  // Review
  static const String writeReview = 'write_review';
  static const String yourRating = 'your_rating';
  static const String yourReview = 'your_review';
  static const String submitReview = 'submit_review';
  static const String reviewHint = 'review_hint';

  // Provider dashboard
  static const String pendingRequests = 'pending_requests';
  static const String todayEarnings = 'today_earnings';
  static const String weekEarnings = 'week_earnings';
  static const String monthEarnings = 'month_earnings';
  static const String totalEarnings = 'total_earnings';
  static const String acceptBooking = 'accept_booking';
  static const String declineBooking = 'decline_booking';
  static const String earnings = 'earnings';
  static const String calendar = 'calendar';
  static const String myServices = 'my_services';

  // Errors
  static const String errorGeneric = 'error_generic';
  static const String errorNetwork = 'error_network';
  static const String errorInvalidEmail = 'error_invalid_email';
  static const String errorWeakPassword = 'error_weak_password';
  static const String errorPasswordMismatch = 'error_password_mismatch';
  static const String errorUserNotFound = 'error_user_not_found';
  static const String errorWrongPassword = 'error_wrong_password';
  static const String errorEmailInUse = 'error_email_in_use';
  static const String errorPermissionDenied = 'error_permission_denied';
  static const String errorTimeout = 'error_timeout';
  static const String errorPaymentFailed = 'error_payment_failed';
}
