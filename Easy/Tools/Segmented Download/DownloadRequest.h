//
//  DownloadRequest.h
//  TaskMgr2
//
//  Created by WenYH on 15/5/8.
//  Copyright (c) 2015年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"

@interface DownloadRequest : NSObject

+ (AFDownloadRequestOperation *)downloadWithURL:(NSString *)urlString
                                     saveToPath:(NSString *)savePath
                                       complete:(void (^)(AFDownloadRequestOperation *operation, NSString *savePath))complete
                                        failure:(void (^)(AFDownloadRequestOperation *operation, NSError *error))failure
                                       progress:(void (^)(NSInteger progress, NSInteger totalBytes))progress;
@end
