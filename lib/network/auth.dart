import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

/// TODO: De-static this class when start using DI to be easier to test
class Auth {
  static _ApiKeys _apiKeys;

  static Future<void> init() async {
    try {
      var jsonApiKeyString = await rootBundle.loadString('assets/api_keys.json');
      _apiKeys = _ApiKeys.fromJson(json.decode(jsonApiKeyString));
    } catch (e) {
      print(e);
      throw _createInvalidApiKeysException();
    }
  }

  static void _validateApiKeys() {

    if (_apiKeys == null) {
      throw _createInvalidApiKeysException();
    }
  }

  static Exception _createInvalidApiKeysException() {
    return Exception('''
        API Keys are not loaded.
        Please re-generate the keys by running `MEDITO_API_KEYS_PASS_PARAPRHASE=<passphrase_you_get_from_medito_slack_development_channel> ./github/scripts/decrypt_development_api_keys.sh`.
        If you still have troubles with this exception, please reach out to Medito #development Slack channel.
        ''');
  }

  static String getBaseUrl() {
    _validateApiKeys();
    return _apiKeys.baseUrl;
  }

  static String getInitToken() {

    _validateApiKeys();
    return _apiKeys.initToken;
  }

  static String getContentToken() {
    _validateApiKeys();
    return _apiKeys.contentToken;
  }

  static String getSentryUrl() {
    _validateApiKeys();
    return _apiKeys.sentryUrl;
  }
}

class _ApiKeys extends Equatable {
  final String baseUrl;
  final String initToken;
  final String contentToken;
  final String sentryUrl;

  _ApiKeys({this.baseUrl, this.initToken, this.contentToken, this.sentryUrl});

  factory _ApiKeys.fromJson(Map<String, dynamic> json) {
    print(json);
    return _ApiKeys(
      baseUrl: json['base_url'],
      initToken: json['init_token'],
      contentToken: json['content_key'],
      sentryUrl: json['sentry_url'],
    );
  }

  @override
  List<Object> get props => [baseUrl, initToken, contentToken, sentryUrl];
}
