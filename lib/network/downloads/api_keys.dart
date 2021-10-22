import 'dart:convert';

import 'package:equatable/equatable.dart';

class ApiKeys extends Equatable {
  final String _baseUrl;
  final String _initToken;
  final String _contentToken;
  final String _sentryUrl;

  ApiKeys(
      {String baseUrl, String initToken, String contentToken, String sentryUrl})
      : _baseUrl = baseUrl,
        _initToken = initToken,
        _contentToken = contentToken,
        _sentryUrl = sentryUrl;

  String get baseUrl => utf8.decode(base64Decode(_baseUrl));

  String get initToken => utf8.decode(base64Decode(_initToken));

  String get contentToken => utf8.decode(base64Decode(_contentToken));

  String get sentryUrl => utf8.decode(base64Decode(_sentryUrl));

  @override
  List<Object> get props => [_baseUrl, _initToken, _contentToken, _sentryUrl];
}
