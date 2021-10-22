import 'downloads/api_keys.dart';

/// TODO: De-static this class when start using DI to be easier to test
class Auth {
  static ApiKeys _apiKeys;

  static Future<void> init() async {
    try {
      // TODO: create and inject different key for different environment
      _apiKeys = ApiKeys(
          // Original value: https://meditofoundation.org
          baseUrl: 'aHR0cHM6Ly9tZWRpdG9mb3VuZGF0aW9uLm9yZy8K',
          // Original value: this_is_init_key
          initToken: 'dGhpc19pc19pbml0X2tleQo=',
          // Original value: this_is_content_token
          contentToken: 'dGhpc19pc19jb250ZW50X3Rva2VuCg==',
          // Original value: https://meditofoundation.org
          sentryUrl: 'aHR0cHM6Ly9tZWRpdG9mb3VuZGF0aW9uLm9yZy8K');
      print(_apiKeys);
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
