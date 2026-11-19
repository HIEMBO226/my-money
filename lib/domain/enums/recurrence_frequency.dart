enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get labelKey {
    return switch (this) {
      RecurrenceFrequency.daily => 'frequencyDaily',
      RecurrenceFrequency.weekly => 'frequencyWeekly',
      RecurrenceFrequency.monthly => 'frequencyMonthly',
      RecurrenceFrequency.yearly => 'frequencyYearly',
    };
  }
}
