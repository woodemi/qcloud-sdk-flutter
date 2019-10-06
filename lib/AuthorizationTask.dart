import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class AuthorizationTask {
  static const algorithm = 'sha1';

  final String method;

  final String path;

  String _urlParamList;

  String _headerList;

  String _httpStringHash;

  AuthorizationTask({
    @required this.method,
    @required this.path,
    Map<String, String> urlParams,
    @required Map<String, String> headers,
  }): assert(method != null),
        assert(path != null),
        assert(headers?.isNotEmpty == true) {
    var urlParamPairs = _sortPairs(urlParams ?? {});
    var headerPairs = _sortPairs(headers);

    _urlParamList = urlParamPairs.map((e) => e.key).join(';');
    _headerList = headerPairs.map((e) => e.key).join(';');

    var httpString = [
      method.toLowerCase(), // HttpMethod
      path, // HttpURI
      _joinPairList(urlParamPairs), // HttpParameters
      _joinPairList(headerPairs), // HttpHeaders
    ].join('\n') + '\n';
    _httpStringHash = sha1.convert(utf8.encode(httpString)).toString();
  }

  List<MapEntry<String, String>> _sortPairs(Map<String, String> pairs) =>
      pairs.entries.map((e) => MapEntry(e.key.toLowerCase(), e.value)).toList()
        ..sort((a, b) => a.key.compareTo(b.key));

  String _joinPairList(List<MapEntry<String, String>> pairList) =>
      pairList.map((e) => '${e.key}=${Uri.encodeFull(e.value)}').join('&');

  String signWith(String secretId, String secretKey, int expireInSeconds) {
    String keyTime = _getKeyTime(Duration(seconds: expireInSeconds));
    var signKey = _computeHmacSha1(secretKey, keyTime);

    var stringToSign = [
      algorithm,
      keyTime,
      _httpStringHash,
    ].join('\n') + '\n';
    var signature = _computeHmacSha1(signKey, stringToSign);

    return [
      'q-sign-algorithm=$algorithm',
      'q-ak=$secretId',
      'q-sign-time=$keyTime',
      'q-key-time=$keyTime',
      'q-header-list=$_headerList',
      'q-url-param-list=$_urlParamList',
      'q-signature=$signature',
    ].join('&');
  }

  String _getKeyTime(Duration expireDuration) {
    var secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    return [secondsSinceEpoch, secondsSinceEpoch + expireDuration.inSeconds].join(';');
  }

  String _computeHmacSha1(String key, String data) =>
      Hmac(sha1, utf8.encode(key)).convert(utf8.encode(data)).toString();
}