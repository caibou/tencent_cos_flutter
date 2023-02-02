import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cloud_storage_platform_interface.dart';

/// An implementation of [CloudStoragePlatform] that uses method channels.
class MethodChannelCloudStorage extends CloudStoragePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cloud_storage');

  @override
  Future<bool> uploadFile(Map<String, dynamic> params) async {
    try {
      return methodChannel.invokeMethod<String>('uploadFile', params).then((value) => value?.isNotEmpty ?? false);
    } on PlatformException catch (e) {
      throw "Unable to upload ${params.toString()}, reason: \n ${e.toString()}";
    }
  }
}
