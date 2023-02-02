package com.dianyun.cloud_storage

import android.content.Context
import androidx.annotation.NonNull
import com.tencent.cos.xml.CosXmlService
import com.tencent.cos.xml.CosXmlServiceConfig
import com.tencent.cos.xml.exception.CosXmlClientException
import com.tencent.cos.xml.exception.CosXmlServiceException
import com.tencent.cos.xml.listener.CosXmlResultListener
import com.tencent.cos.xml.model.CosXmlRequest
import com.tencent.cos.xml.model.CosXmlResult
import com.tencent.cos.xml.transfer.TransferConfig
import com.tencent.cos.xml.transfer.TransferManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** CloudStoragePlugin */
class CloudStoragePlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var channel: MethodChannel? = null
  private var applicationContext: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cloud_storage")
    channel?.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "uploadFile" -> {
        uploadFile(call, result)
      }
      else -> result.notImplemented()
    }
  }

  private fun uploadFile(call: MethodCall, result: Result)  {
    val filePath = call.argument<String>("file_path") ?: ""
    val tmpSecretId = call.argument<String>("tmp_secret_id") ?: ""
    val tmpSecretKey = call.argument<String>("tmp_secret_key") ?: ""
    val sessionToken = call.argument<String>("session_token") ?: ""
    val expiredTime = call.argument<String>("expired_time") ?: "0"
    val startTime = call.argument<String>("start_time") ?: "0"
    val region = call.argument<String>("region") ?: ""
    val bucket = call.argument<String>("bucket") ?: ""
    val cosPath = call.argument<String>("cos_path") ?: ""
    val provider =
      SessionCredentialProvider(tmpSecretId, tmpSecretKey, sessionToken, startTime.toLong(), expiredTime.toLong())

    // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
    val serviceConfig = CosXmlServiceConfig.Builder()
      .setRegion(region)
      .isHttps(true) // 使用 HTTPS 请求, 默认为 HTTP 请求
      .builder()

    // 初始化 COS Service，获取实例
    val cosXmlService = CosXmlService(
      applicationContext,
      serviceConfig,
      provider
    )
    val transferManager = TransferManager(cosXmlService, TransferConfig.Builder().build())
    val uploadTask = transferManager.upload(bucket, cosPath, filePath, null)

    uploadTask?.setCosXmlResultListener(object : CosXmlResultListener {
      override fun onSuccess(req: CosXmlRequest?, cosResult: CosXmlResult?) {
        result.success(cosResult?.accessUrl)
      }

      override fun onFail(
        cosRequest: CosXmlRequest?,
        clientException: CosXmlClientException?,
        serviceException: CosXmlServiceException?
      ) {
        result.error(
          serviceException?.errorCode ?: "",
          serviceException?.errorMessage,
          serviceException?.message
        )
      }
    })
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    applicationContext = null
  }
}
