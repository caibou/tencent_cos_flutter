//
//  COSManager.m
//  DYBaseSDK
//
//  Created by kuangxianming on 2022/9/19.
//  Copyright © 2022 flyhuang. All rights reserved.
//

#import "COSManager.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import "NetworkManager.h"
#import "NetworkServiceManager.h"
#import "INetworkServiceProtocol.h"

#define kRegion @"ap-guangzhou"

@interface COSManager ()<QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@end

static NSString *DYCOSDomain = @"DYCOSDomain";

@implementation COSManager {
    DYCOSModel * _cosModel;
}

#pragma singal instance
+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    static COSManager *share = nil;
    dispatch_once(&onceToken, ^{
        share = [[COSManager alloc] init];
    }) ;
    return share;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupCOSXMLShareService];
    }
    return self;
}


#pragma -- QCloudCredentailFenceQueueDelegate
- (void) fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];

    credential.secretID = _cosModel.secretId;
    credential.secretKey = _cosModel.secretKey;
    credential.token = _cosModel.securityToken;
    credential.startDate = [NSDate dateWithTimeIntervalSince1970:_cosModel.startTimeSecs]; // 单位是秒
    credential.expirationDate = [NSDate dateWithTimeIntervalSince1970:_cosModel.expiredTimeSecs];// 单位是秒

    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
        initWithCredential:credential];
    continueBlock(creator, nil);
}

#pragma -- QCloudSignatureProvider
- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];

    credential.secretID = _cosModel.secretId;
    credential.secretKey = _cosModel.secretKey;
    credential.token = _cosModel.securityToken;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
        initWithCredential:credential];
    
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);
}


#pragma --初始化
- (void)setupCOSXMLShareService {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];

    endpoint.regionName = kRegion;
    // 使用 HTTPS
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    // 密钥提供者为自己
    configuration.signatureProvider = self;
    // 初始化 COS 服务示例
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:
        configuration];
}

#pragma --上传到腾讯云
- (void)upload:(DYCOSModel *_Nonnull)model onCompletion:(COSCallback _Nullable)completion
{
    _cosModel = model;
    
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];

    // 存储桶名称，由BucketName-Appid 组成，可以在COS控制台查看 https://console.cloud.tencent.com/cos5/bucket
    put.bucket = model.bucketName;
    // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
    put.object = model.cosKey;
    //需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
    put.body =  model.data;
    
    //监听上传进度
    [put setSendProcessBlock:^(int64_t bytesSent,
                                int64_t totalBytesSent,
                                int64_t totalBytesExpectedToSend) {
        //      bytesSent                 本次要发送的字节数（一个大文件可能要分多次发送）
        //      totalBytesSent            已发送的字节数
        //      totalBytesExpectedToSend  本次上传要发送的总字节数（即一个文件大小）
    }];

    //监听上传结果
    [put setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSLog(@"cos upload success");
                if (completion) {
                    completion(YES, nil);
                }
            }
            else {
                DYLogError(@"upload object failed, error: %@", error.localizedDescription);
                if (completion) {
                    completion(NO, error);
                }
            }
        });
    }];

    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
}

- (void)uploadWithModelList:(NSArray<DYCOSModel *> *_Nonnull)modelList
                uploadBlock:(void (^_Nullable)(DYCOSModel * _Nonnull model, NSError * _Nullable error))uploadBlock
            completion:(COSCallback _Nullable)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        __block BOOL isSuccess = YES;
        __block NSError * error = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [modelList enumerateObjectsUsingBlock:^(DYCOSModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            [self upload:model onCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
                if (error) {
                    isSuccess = NO;
                    error = error;
                } else {
                    model.isUploaded = YES;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (uploadBlock) {
                        uploadBlock(model, error);
                    }
                });
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if (!isSuccess) {
                *stop = YES;
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(isSuccess, error);
            }
        });
    });
}

@end
