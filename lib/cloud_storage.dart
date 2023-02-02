import 'package:cloud_storage/src/cloud_storage_platform_interface.dart';

class CloudStorage {

  Future<bool> uploadFile(Map<String, dynamic> params) async {
    return CloudStoragePlatform.instance.uploadFile(params);
  }
}
