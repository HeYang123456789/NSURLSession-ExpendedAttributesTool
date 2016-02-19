//
//  ExpendFileAttributes.h
//  NSURLSession实现离线断点续传
//
//  Created by HEYANG on 16/2/19.
//  Copyright © 2016年 HEYANG. All rights reserved.
//

/**
 *   ExpendFileAttributes工具类下载源码：https://github.com/HeYang123456789/NSURLSession-ExpendedAttributesTool
 */

#import <Foundation/Foundation.h>

@interface ExpendFileAttributes : NSObject

/** 为文件增加一个扩展属性，值是字符串 */
+ (BOOL)extendedStringValueWithPath:(NSString *)path key:(NSString *)key value:(NSString *)value;

/** 读取文件扩展属性，值是字符串 */
+ (NSString *)stringValueWithPath:(NSString *)path key:(NSString *)key;


@end
