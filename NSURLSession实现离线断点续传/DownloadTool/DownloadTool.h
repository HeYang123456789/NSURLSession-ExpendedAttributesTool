//
//  DownloadTools.h
//  NSURLSession实现离线断点续传
//
//  Created by HEYANG on 16/2/18.
//  Copyright © 2016年 HEYANG. All rights reserved.
//

#import <Foundation/Foundation.h>


// 定义一个block用来传递进度值
typedef  void (^SetProgressValue)(float progressValue);

@interface DownloadTool : NSObject

/** 创建下载工具对象 */
+ (instancetype)DownloadWithURLString:(NSString*)urlString setProgressValue:(SetProgressValue)setProgressValue;
/** 开始下载 */
-(void)startDownload;
/** 暂停下载 */
-(void)suspendDownload;

@end
