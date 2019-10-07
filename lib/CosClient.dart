import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'AuthorizationTask.dart';

const defaultExpireInSeconds = 10;

class CosClient {
  final String secretId;
  final String secretKey;

  CosClient({
    @required this.secretId,
    @required this.secretKey,
  });

  Map<String, String> _buildHeaders({
    String method,
    String host,
    String path,
  }) {
    var headers = {
      'Host': host
    };
    headers['Authorization'] = AuthorizationTask(
      method: method,
      path: path,
      headers: headers,
    ).signWith(secretId, secretKey, defaultExpireInSeconds);
    return headers;
  }

  Future<String> getService() async {
    var host = 'service.cos.myqcloud.com';
    var path = '/';
    var response = await Dio().get('https://$host$path', options: Options(
      headers: _buildHeaders(
        method: 'get',
        host: host,
        path: path,
      ),
    ));
    return response.data.toString();
  }

  Future<String> getBucket(String bucket, String region) async {
    var host = '$bucket.cos.$region.myqcloud.com';
    var path = '/';
    var response = await Dio().get('https://$host$path', options: Options(
        headers: _buildHeaders(
          method: 'get',
          host: host,
          path: path,
        )
    ));
    return response.data.toString();
  }
}
