import 'package:flutter/foundation.dart';
import 'package:enrollease_web/model/footer_config_model.dart';
import 'package:enrollease_web/services/footer_config_service.dart';

class FooterConfigProvider extends ChangeNotifier {
  FooterConfigModel? _footerConfig;
  bool _isLoading = false;

  FooterConfigModel? get footerConfig => _footerConfig;
  bool get isLoading => _isLoading;

  // Initialize footer configuration
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _footerConfig = await FooterConfigService.getFooterConfig();
    } catch (e) {
      print('Error initializing footer config: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update footer configuration
  Future<bool> updateFooterConfig(FooterConfigModel config) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await FooterConfigService.updateFooterConfig(config);
      if (success) {
        _footerConfig = config;
      }
      return success;
    } catch (e) {
      print('Error updating footer config: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current year
  String get currentYear => DateTime.now().year.toString();

  // Get copyright text
  String get copyrightText {
    if (_footerConfig != null) {
      return '© $currentYear ${_footerConfig!.appName}. All rights reserved.';
    }
    return '© $currentYear EnrollEase. All rights reserved.';
  }

  // Get privacy policy text
  String get privacyPolicyText {
    return _footerConfig?.privacyPolicyText ?? 'Privacy Policy';
  }

  // Get terms and conditions text
  String get termsAndConditionsText {
    return _footerConfig?.termsAndConditionsText ?? 'Terms & Conditions';
  }

  // Get privacy policy content
  String get privacyPolicyContent {
    return _footerConfig?.privacyPolicyContent ??
        'Default privacy policy content...';
  }

  // Get terms and conditions content
  String get termsAndConditionsContent {
    return _footerConfig?.termsAndConditionsContent ??
        'Default terms and conditions content...';
  }
}
