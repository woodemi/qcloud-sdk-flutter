import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qcloud_cosxml/CosClient.dart';

final cosClient = CosClient(secretId: Platform.environment['SECRET_ID'], secretKey: Platform.environment['SECRET_KEY']);

void main() {
  test('test getService', () async {
    var service = await cosClient.getService();
    expect(service, isNotNull);
  });

  test('test listObject', () async {
    var listObject = await cosClient.getBucket('test-1256480948', 'ap-beijing');
    print('listObject $listObject');
    expect(listObject, isNotNull);
  });
}
