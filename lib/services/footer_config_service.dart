import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrollease_web/model/footer_config_model.dart';

class FooterConfigService {
  static const String _collectionName = 'footer_config';
  static const String _documentId = 'main_config';

  // Get current footer configuration
  static Future<FooterConfigModel> getFooterConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(_documentId)
          .get();

      if (doc.exists) {
        return FooterConfigModel.fromMap(doc.data()!);
      } else {
        // Return default configuration if none exists
        return FooterConfigModel(
          appName: 'EnrollEase',
          privacyPolicyText: 'Privacy Policy',
          termsAndConditionsText: 'Terms & Conditions',
          privacyPolicyContent: '''## EnrollEase Privacy Policy

Effective Date: December 5, 2024
Last Updated: December 5, 2024

Welcome to EnrollEase! Your privacy is important to us, and we are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your information in compliance with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines.

1. Information We Collect
	We collect personal, educational, payment, and system usage data to provide and improve our services.

2. How We Use Your Information
	We use your data for enrollment, payment processing, communication, app improvement, and legal compliance.

3. Data Sharing
	We share data only with schools, service providers, and legal authorities when necessary.

4. Data Security
	Your data is protected using encryption, secure payment gateways, and regular audits.

5. Data Retention
	We keep data only as long as needed for service or legal purposes and delete it securely after.

6. Your Rights
	You can access, correct, object, delete, or request a copy of your data. You may also file complaints with the National Privacy Commission (NPC).

7. Children's Privacy
	Parental or guardian consent is required for users under 18.

8. Policy Updates
	We will notify you of changes through the app or website.

9. Contact Us
	For inquiries, concerns, or data requests, please contact:

Data Protection Officer (DPO):
	ApexVision
	apexvision6@gmail.com
	+639816188964
	Oroquieta City, Misamis Occidental, Philipines

National Privacy Commission:
https://privacy.gov.ph/''',
          termsAndConditionsContent: '''# EnrollEase Terms and Conditions

## 1. Introduction

Welcome to EnrollEase, a web application provided by ApexVision. These Terms and Conditions govern your use of our website located at https://enrollease-4a6cd.web.app/. By accessing or using EnrollEase, you agree to be bound by these terms.

## 2. Eligibility

- You must be at least 18 years old to use this website.
- Users represent and warrant that they have the legal capacity to enter into these terms.

## 3. Website Purpose

EnrollEase is an administrative service platform designed to provide registration and management services for Oroquieta SDA School. The website is intended solely for authorized personnel involved in school administration.

## 4. User Responsibilities

- Users must provide accurate and complete information when using the platform.
- Users are responsible for maintaining the confidentiality of their account credentials.
- Any misuse of the platform or unauthorized access is strictly prohibited.

## 5. Data Privacy and Protection

- We collect and process user data in accordance with our Privacy Policy.
- Personal information is handled with strict confidentiality and used only for administrative purposes.
- Data is processed exclusively within Oroquieta, Misamis Occidental, Philippines.

## 6. Intellectual Property

- All content, design, and functionality of EnrollEase are the exclusive property of ApexVision.
- Users are prohibited from reproducing, distributing, or creating derivative works without explicit written permission.

## 7. Limitations of Service

- EnrollEase is provided "as is" without any warranties.
- We reserve the right to modify, suspend, or discontinue the service at any time.
- No financial transactions are processed through this platform.

## 8. User Conduct

Users agree to:
- Use the platform only for its intended administrative purposes
- Respect the privacy and rights of other users
- Not engage in any activities that might compromise the system's integrity
- Comply with all applicable local and national regulations

## 9. Disclaimer of Liability

ApexVision shall not be liable for:
- Any direct, indirect, or consequential damages arising from platform use
- Loss of data or interruption of services
- Any actions taken by users based on information provided on the platform

## 10. Geographical Limitation

This service is specifically designed for use in Oroquieta, Misamis Occidental, Philippines, and is subject to local jurisdictional laws.

## 11. Contact Information

For any questions or concerns regarding these Terms and Conditions, please contact:
- Email: apexvision.support@gmail.com
- Address: Oroquieta, Misamis Occidental, Philippines

## 12. Modifications to Terms

ApexVision reserves the right to update these Terms and Conditions at any time. Users are encouraged to review the terms periodically.

## 13. Acceptance of Terms

By continuing to use EnrollEase, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.

*Last Updated: December 2024*''',
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error getting footer config: $e');
      // Return default configuration on error
      return FooterConfigModel(
        appName: 'EnrollEase',
        privacyPolicyText: 'Privacy Policy',
        termsAndConditionsText: 'Terms & Conditions',
        privacyPolicyContent: 'Default privacy policy content...',
        termsAndConditionsContent: 'Default terms and conditions content...',
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Update footer configuration
  static Future<bool> updateFooterConfig(FooterConfigModel config) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(_documentId)
          .set(config.toMap(), SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error updating footer config: $e');
      return false;
    }
  }

  // Stream footer configuration for real-time updates
  static Stream<FooterConfigModel> getFooterConfigStream() {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(_documentId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return FooterConfigModel.fromMap(doc.data()!);
      } else {
        // Return default configuration if none exists
        return FooterConfigModel(
          appName: 'EnrollEase',
          privacyPolicyText: 'Privacy Policy',
          termsAndConditionsText: 'Terms & Conditions',
          privacyPolicyContent: '''## EnrollEase Privacy Policy

Effective Date: December 5, 2024
Last Updated: December 5, 2024

Welcome to EnrollEase! Your privacy is important to us, and we are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your information in compliance with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines.

1. Information We Collect
	We collect personal, educational, payment, and system usage data to provide and improve our services.

2. How We Use Your Information
	We use your data for enrollment, payment processing, communication, app improvement, and legal compliance.

3. Data Sharing
	We share data only with schools, service providers, and legal authorities when necessary.

4. Data Security
	Your data is protected using encryption, secure payment gateways, and regular audits.

5. Data Retention
	We keep data only as long as needed for service or legal purposes and delete it securely after.

6. Your Rights
	You can access, correct, object, delete, or request a copy of your data. You may also file complaints with the National Privacy Commission (NPC).

7. Children's Privacy
	Parental or guardian consent is required for users under 18.

8. Policy Updates
	We will notify you of changes through the app or website.

9. Contact Us
	For inquiries, concerns, or data requests, please contact:

Data Protection Officer (DPO):
	ApexVision
	apexvision6@gmail.com
	+639816188964
	Oroquieta City, Misamis Occidental, Philipines

National Privacy Commission:
https://privacy.gov.ph/''',
          termsAndConditionsContent: '''# EnrollEase Terms and Conditions

## 1. Introduction

Welcome to EnrollEase, a web application provided by ApexVision. These Terms and Conditions govern your use of our website located at https://enrollease-4a6cd.web.app/. By accessing or using EnrollEase, you agree to be bound by these terms.

## 2. Eligibility

- You must be at least 18 years old to use this website.
- Users represent and warrant that they have the legal capacity to enter into these terms.

## 3. Website Purpose

EnrollEase is an administrative service platform designed to provide registration and management services for Oroquieta SDA School. The website is intended solely for authorized personnel involved in school administration.

## 4. User Responsibilities

- Users must provide accurate and complete information when using the platform.
- Users are responsible for maintaining the confidentiality of their account credentials.
- Any misuse of the platform or unauthorized access is strictly prohibited.

## 5. Data Privacy and Protection

- We collect and process user data in accordance with our Privacy Policy.
- Personal information is handled with strict confidentiality and used only for administrative purposes.
- Data is processed exclusively within Oroquieta, Misamis Occidental, Philippines.

## 6. Intellectual Property

- All content, design, and functionality of EnrollEase are the exclusive property of ApexVision.
- Users are prohibited from reproducing, distributing, or creating derivative works without explicit written permission.

## 7. Limitations of Service

- EnrollEase is provided "as is" without any warranties.
- We reserve the right to modify, suspend, or discontinue the service at any time.
- No financial transactions are processed through this platform.

## 8. User Conduct

Users agree to:
- Use the platform only for its intended administrative purposes
- Respect the privacy and rights of other users
- Not engage in any activities that might compromise the system's integrity
- Comply with all applicable local and national regulations

## 9. Disclaimer of Liability

ApexVision shall not be liable for:
- Any direct, indirect, or consequential damages arising from platform use
- Loss of data or interruption of services
- Any actions taken by users based on information provided on the platform

## 10. Geographical Limitation

This service is specifically designed for use in Oroquieta, Misamis Occidental, Philippines, and is subject to local jurisdictional laws.

## 11. Contact Information

For any questions or concerns regarding these Terms and Conditions, please contact:
- Email: apexvision.support@gmail.com
- Address: Oroquieta, Misamis Occidental, Philippines

## 12. Modifications to Terms

ApexVision reserves the right to update these Terms and Conditions at any time. Users are encouraged to review the terms periodically.

## 13. Acceptance of Terms

By continuing to use EnrollEase, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.

*Last Updated: December 2024*''',
          lastUpdated: DateTime.now(),
        );
      }
    });
  }
}
