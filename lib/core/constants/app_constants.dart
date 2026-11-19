abstract final class AppConstants {
  static const String appName = 'My money';
  static const Duration inactivityTimeout = Duration(minutes: 5);
  static const int maxNoteLength = 500;
  static const int maxCategoryNameLength = 50;
  static const int maxAccountNameLength = 50;
  static const double budgetWarningThreshold = 0.8;
  static const double budgetCriticalThreshold = 1.0;
  static const int trendMonths = 6;
  static const int pageSize = 50;
}
