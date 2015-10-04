//
//  MD5.h
//  NewProject
//
//  Created by 一鸿温 on 15/10/4.
//  Copyright (c) 2015年 wyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5 : NSObject

+ (NSString *)md5FromString:(NSString *)string;

+ (NSString*)md5FromFile:(NSString*)path;

@end
