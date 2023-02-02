import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cloud_storage_method_channel.dart';

abstract class CloudStoragePlatform extends PlatformInterface {
  /// Constructs a CloudStoragePlatform.
  CloudStoragePlatform() : super(token: _token);

  static final Object _token = Object();

  static CloudStoragePlatform _instance = MethodChannelCloudStorage();

  /// The default instance of [CloudStoragePlatform] to use.
  ///
  /// Defaults to [MethodChannelCloudStorage].
  static CloudStoragePlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CloudStoragePlatform] when
  /// they register themselves.
  static set instance(CloudStoragePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> uploadFile(Map<String, dynamic> params);
}
