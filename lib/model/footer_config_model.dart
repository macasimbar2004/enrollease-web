class FooterConfigModel {
  final String appName;
  final String privacyPolicyText;
  final String termsAndConditionsText;
  final String privacyPolicyContent;
  final String termsAndConditionsContent;
  final DateTime lastUpdated;

  FooterConfigModel({
    required this.appName,
    required this.privacyPolicyText,
    required this.termsAndConditionsText,
    required this.privacyPolicyContent,
    required this.termsAndConditionsContent,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'privacyPolicyText': privacyPolicyText,
      'termsAndConditionsText': termsAndConditionsText,
      'privacyPolicyContent': privacyPolicyContent,
      'termsAndConditionsContent': termsAndConditionsContent,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory FooterConfigModel.fromMap(Map<String, dynamic> map) {
    return FooterConfigModel(
      appName: map['appName'] ?? 'EnrollEase',
      privacyPolicyText: map['privacyPolicyText'] ?? 'Privacy Policy',
      termsAndConditionsText:
          map['termsAndConditionsText'] ?? 'Terms & Conditions',
      privacyPolicyContent:
          map['privacyPolicyContent'] ?? 'Default privacy policy content...',
      termsAndConditionsContent: map['termsAndConditionsContent'] ??
          'Default terms and conditions content...',
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          map['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  FooterConfigModel copyWith({
    String? appName,
    String? privacyPolicyText,
    String? termsAndConditionsText,
    String? privacyPolicyContent,
    String? termsAndConditionsContent,
    DateTime? lastUpdated,
  }) {
    return FooterConfigModel(
      appName: appName ?? this.appName,
      privacyPolicyText: privacyPolicyText ?? this.privacyPolicyText,
      termsAndConditionsText:
          termsAndConditionsText ?? this.termsAndConditionsText,
      privacyPolicyContent: privacyPolicyContent ?? this.privacyPolicyContent,
      termsAndConditionsContent:
          termsAndConditionsContent ?? this.termsAndConditionsContent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
