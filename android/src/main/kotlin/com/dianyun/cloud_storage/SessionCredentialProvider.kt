package com.dianyun.cloud_storage

import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials
import com.tencent.qcloud.core.auth.SessionQCloudCredentials

class SessionCredentialProvider(
  val tmpSecretId: String,
  val tmpSecretKey: String,
  val sessionToken: String,
  val startTime: Long,
  val expiredTime: Long
) : BasicLifecycleCredentialProvider() {

  override fun fetchNewCredentials(): QCloudLifecycleCredentials {
    return SessionQCloudCredentials(tmpSecretId, tmpSecretKey, sessionToken, startTime, expiredTime)
  }
}