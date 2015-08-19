//
//  DownloadRequest.m
//  TaskMgr2
//
//  Created by WenYH on 15/5/8.
//  Copyright (c) 2015年 szl. All rights reserved.
//

#import "DownloadRequest.h"

@implementation DownloadRequest

+ (AFDownloadRequestOperation *)downloadWithURL:(NSString *)urlString
                                     saveToPath:(NSString *)savePath
                                       complete:(void (^)(AFDownloadRequestOperation *operation, NSString *savePath))complete
                                        failure:(void (^)(AFDownloadRequestOperation *operation, NSError *error))failure
                                       progress:(void (^)(NSInteger progress, NSInteger totalBytes))progress {
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:savePath shouldResume:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"[下载成功]: %@", savePath);
        AFDownloadRequestOperation *downoperaton = (AFDownloadRequestOperation *)operation;
        complete(downoperaton,savePath);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[下载失败]: %@", error);
        AFDownloadRequestOperation *downoperaton = (AFDownloadRequestOperation *)operation;
        failure(downoperaton,error);
    }];
    
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        CGFloat progress = totalBytesRead / totalBytesExpected*1.0;
        NSLog(@"%f",progress);
    }];
    
    [operation start];
    return operation;
}

@end
