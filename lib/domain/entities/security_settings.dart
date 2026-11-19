class SecuritySettings {
  const SecuritySettings({
    this.isPinEnabled = false,
    this.isBiometricsEnabled = false,
    this.hideInAppSwitcher = true,
    this.inactivityMinutes = 5,
  });

  final bool isPinEnabled;
  final bool isBiometricsEnabled;
  final bool hideInAppSwitcher;

  /// Auto-lock timeout in minutes (0 = immediately on background).
  final int inactivityMinutes;

  SecuritySettings copyWith({
    bool? isPinEnabled,
    bool? isBiometricsEnabled,
    bool? hideInAppSwitcher,
    int? inactivityMinutes,
  }) {
    return SecuritySettings(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      hideInAppSwitcher: hideInAppSwitcher ?? this.hideInAppSwitcher,
      inactivityMinutes: inactivityMinutes ?? this.inactivityMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecuritySettings &&
        other.isPinEnabled == isPinEnabled &&
        other.isBiometricsEnabled == isBiometricsEnabled &&
        other.hideInAppSwitcher == hideInAppSwitcher &&
        other.inactivityMinutes == inactivityMinutes;
  }

  @override
  int get hashCode => Object.hash(
        isPinEnabled,
        isBiometricsEnabled,
        hideInAppSwitcher,
        inactivityMinutes,
      );
}
