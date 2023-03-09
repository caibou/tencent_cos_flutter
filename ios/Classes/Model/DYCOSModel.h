//
//  DYCOSModel.h
//  DYBaseSDK
//
//  Created by kuangxianming on 2022/9/19.
//  Copyright © 2022 flyhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DYCloudModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DYCOSModel : DYCloudModel
@property (nonatomic, copy) NSString * secretId;
@property (nonatomic, copy) NSString * secretKey;
@property (nonatomic, copy) NSString * securityToken;
@property (nonatomic, assign) double expiredTimeSecs;
@property (nonatomic, assign) double startTimeSecs;
@property (nonatomic, copy) NSString * region;
@property (nonatomic, copy) NSString * bucketName;
@property (nonatomic, copy) NSString * cosKey;
@property (nonatomic, copy) NSString * cdnUrl;
@end

NS_ASSUME_NONNULL_END
