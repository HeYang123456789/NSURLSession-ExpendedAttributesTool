//
//  ExpendFileAttributes.m
//  NSURLSession实现离线断点续传
//
//  Created by HEYANG on 16/2/19.
//  Copyright © 2016年 HEYANG. All rights reserved.
//

#import "ExpendFileAttributes.h"

#include <sys/xattr.h>

@implementation ExpendFileAttributes
//为文件增加一个扩展属性
+ (BOOL)extendedStringValueWithPath:(NSString *)path key:(NSString *)key value:(NSString *)stringValue
{
    NSData* value = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
    ssize_t writelen = setxattr([path fileSystemRepresentation],
                                [key UTF8String],
                                [value bytes],
                                [value length],
                                0,
                                0);
    return writelen==0?YES:NO;
}
//读取文件扩展属性
+ (NSString *)stringValueWithPath:(NSString *)path key:(NSString *)key
{
    ssize_t readlen = 1024;
    do {
        char buffer[readlen];
        bzero(buffer, sizeof(buffer));
        size_t leng = sizeof(buffer);
        readlen = getxattr([path fileSystemRepresentation],
                           [key UTF8String],
                           buffer,
                           leng,
                           0,
                           0);
        if (readlen < 0){
            return nil;
        }
        else if (readlen > sizeof(buffer)) {
            continue;
        }else{
            NSData *data = [NSData dataWithBytes:buffer length:readlen];
            NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"result---%@",result);
            return result;
        }
    } while (YES);
    return nil;
}
@end
