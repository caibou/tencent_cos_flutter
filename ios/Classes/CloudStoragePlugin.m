#import "CloudStoragePlugin.h"
#import "COSManager.h"
#import "HYLogMacros.h"

#define kUploadFileEvent @"uploadFile"

@interface CloudStoragePlugin ()
@property (nonatomic, copy) FlutterResult resultToFlutterBlock;
@end

@implementation CloudStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"cloud_storage"
            binaryMessenger:[registrar messenger]];
    CloudStoragePlugin* instance = [[CloudStoragePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _resultToFlutterBlock = result;
    if ([kUploadFileEvent isEqualToString:call.method]) {
        NSDictionary *params = call.arguments;
        DYCOSModel *cosModel = nil;
        if (params && params.count > 0) {
            cosModel = [[DYCOSModel alloc] init];
            cosModel.secretId = params[@"tmp_secret_id"];
            cosModel.secretKey = params[@"tmp_secret_key"];
            cosModel.securityToken = params[@"session_token"];
            cosModel.expiredTimeSecs = [params[@"expired_time"] doubleValue];
            cosModel.startTimeSecs = [params[@"start_time"] doubleValue];
            cosModel.region = params[@"region"];
            cosModel.bucketName = params[@"bucket"];
            cosModel.cosKey = params[@"cos_key"];
            cosModel.filePath = params[@"file_path"];
            cosModel.cdnUrl = params[@"cdn_url"];
        }
        
        if (!cosModel || !cosModel.filePath || cosModel.filePath.length == 0) {
            DYLogError(@"upload filePath is empty");
            return;
        }
        [self cos_upload_file:cosModel];
        
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma --上传图片到腾讯云
- (void)cos_upload_file:(DYCOSModel *)cosModel {
    NSData *fileData = [NSData dataWithContentsOfFile:cosModel.filePath];
    cosModel.data =        fileData;

    __weak typeof(self) weakSelf = self;
    [[COSManager sharedInstance] upload:cosModel onCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        if(weakSelf.resultToFlutterBlock){
            weakSelf.resultToFlutterBlock(isSuccess ? cosModel.cdnUrl : @"");
        }
        if (error) {
            NSLog(@"upload error:%@",error);
        }
    }];
}

@end
