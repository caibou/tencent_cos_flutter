//
//  COSManager.h
//  DYBaseSDK
//
//  Created by kuangxianming on 2022/9/19.
//  Copyright © 2022 flyhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DYCOSModel.h"

typedef void(^COSCallback)(BOOL isSuccess, NSError *_Nullable error);

@interface COSManager : NSObject

+ (instancetype _Nonnull ) sharedInstance;

- (void)upload:(DYCOSModel *_Nonnull)model onCompletion:(COSCallback _Nullable)completion;

- (void)uploadWithModelList:(NSArray<DYCOSModel *> *_Nonnull)modelList
                uploadBlock:(void (^_Nullable)(DYCOSModel * _Nonnull model, NSError * _Nullable error))uploadBlock
            completion:(COSCallback _Nullable)completion;

@end

