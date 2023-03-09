//
//  DYCloudModel.h
//  DYBaseSDK
//
//  Created by kuangxianming on 2022/9/19.
//  Copyright © 2022 flyhuang. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface DYCloudModel : NSObject
/** 上传文件路径 */
@property (nonatomic, copy) NSString * filePath;
/** 上传二进制数据 */
@property (nonatomic, strong) NSData *data;
/** endPoint */
@property(nonatomic,strong)NSString *endPoint;
/** funcName */
@property(nonatomic,strong)NSString *functionName;
/** serviewName */
@property(nonatomic,strong)NSString *serviewName;

@property (nonatomic, assign) BOOL isUploaded;

@end

NS_ASSUME_NONNULL_END
