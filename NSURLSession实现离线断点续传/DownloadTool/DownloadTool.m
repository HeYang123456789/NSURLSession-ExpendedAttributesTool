//
//  DownloadTools.m
//  NSURLSession实现离线断点续传
//
//  Created by HEYANG on 16/2/18.
//  Copyright © 2016年 HEYANG. All rights reserved.
//


#import "DownloadTool.h"

#import "ExpendFileAttributes.h"

#define Key_FileTotalSize @"Key_FileTotalSize"

@interface DownloadTool () <NSURLSessionDataDelegate>
/** Session会话 */
@property (nonatomic,strong)NSURLSession *session;
/** Task任务 */
@property (nonatomic,strong)NSURLSessionDataTask *task;
/** 文件的全路径 */
@property (nonatomic,strong)NSString *fileFullPath;
/** 传递进度值的block */
@property (nonatomic,copy) SetProgressValue setProgressValue;
/** 当前已经下载的文件的长度 */
@property (nonatomic,assign)NSInteger currentFileSize;
/** 输出流 */
@property (nonatomic,strong)NSOutputStream *outputStream;
/** 不变的文件总长度 */
@property (nonatomic,assign)NSInteger fileTotalSize;
@end

@implementation DownloadTool

+ (instancetype)DownloadWithURLString:(NSString*)urlString setProgressValue:(SetProgressValue)setProgressValue{
    DownloadTool* download = [[DownloadTool alloc] init];
    download.setProgressValue = setProgressValue;
    [download getFileSizeWithURLString:urlString];
    [download creatDownloadSessionTaskWithURLString:urlString];
    NSLog(@"%@",download.fileFullPath);
    return download;
}
// 刚创建该网络下载工具类的时候，就需要查询本地是否有已经下载的文件，并返回该文件已经下载的长度
-(void)getFileSizeWithURLString:(NSString*)urlString{
    // 创建文件管理者
    NSFileManager* fileManager = [NSFileManager defaultManager];
    // 获取文件各个部分
    NSArray* fileComponents = [fileManager componentsToDisplayForPath:urlString];
    // 获取下载之后的文件名
    NSString* fileName = [fileComponents lastObject];
    // 根据文件名拼接沙盒全路径
    NSString* fileFullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    self.fileFullPath = fileFullPath;
    
    NSDictionary* attributes = [fileManager attributesOfItemAtPath:fileFullPath
                                                             error:nil];
    // 打印文件的所有属性
    NSLog(@"文件所有的属性\n%@",attributes);
    // 如果有该文件，且为下载没完成，就直接拿出该文件的长度设置进度值，并设置当前的文件长度
    NSInteger fileCurrentSize = [attributes[@"NSFileSize"] integerValue];
    // 如果文件长度为0，就不需要计算进度值了
    if (fileCurrentSize != 0) {
        // 获取最终的文件中长度
        NSInteger fileTotalSize = [[ExpendFileAttributes stringValueWithPath:self.fileFullPath key:Key_FileTotalSize] integerValue];
        self.currentFileSize = fileCurrentSize;
        self.fileTotalSize = fileTotalSize;
        // 设置进度条的值
        self.setProgressValue(1.0 * fileCurrentSize / fileTotalSize);
    }
    NSLog(@"当前文件长度：%lf" , self.currentFileSize * 1.0);
}
#pragma mark - 创建网络请求会话和任务，并启动任务
-(void)creatDownloadSessionTaskWithURLString:(NSString*)urlString{
    //判断文件是否已经下载完毕
    if (self.currentFileSize == self.fileTotalSize && self.currentFileSize != 0) {
        NSLog(@"文件已经下载完毕");
        return;
    }
    NSURLSession* session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:self
                             delegateQueue:[[NSOperationQueue alloc]init]];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    //2.3 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentFileSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request];
    self.session = session;
    self.task = task;
}

#pragma mark - 控制下载的状态
// 开始下载
-(void)startDownload{
    [self.task resume];
}
// 暂停下载
-(void)suspendDownload{
    [self.task suspend];
}
#pragma mark - NSURLSessionDataDelegate 的代理方法
// 收到响应调用的代理方法
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:
(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSLog(@"执行了收到响应调用的代理方法");
    // 创建输出流，并打开流
    NSOutputStream* outputStream = [[NSOutputStream alloc] initToFileAtPath:self.fileFullPath append:YES];
    [outputStream open];
    self.outputStream = outputStream;
    // 如果当前已经下载的文件长度等于0，那么就需要将总长度信息写入文件中
    if (self.currentFileSize == 0) {
        NSInteger totalSize = response.expectedContentLength;
        NSString* totalSizeString = [NSString stringWithFormat:@"%ld",totalSize];
        [ExpendFileAttributes extendedStringValueWithPath:self.fileFullPath key:Key_FileTotalSize value:totalSizeString];
        // 别忘了设置总长度
        self.fileTotalSize = totalSize;
    }
    // 允许收到响应
    completionHandler(NSURLSessionResponseAllow);
}
// 收到数据调用的代理方法
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"执行了收到数据调用的代理方法");
    // 通过输出流写入数据
    [self.outputStream write:data.bytes maxLength:data.length];
    // 将写入的数据的长度计算加进当前的已经下载的数据长度
    self.currentFileSize += data.length;
    // 设置进度值
    NSLog(@"当前文件长度：%lf，总长度：%lf",self.currentFileSize * 1.0,self.fileTotalSize * 1.0);
    NSLog(@"进度值: %lf",self.currentFileSize * 1.0 / self.fileTotalSize);
    // 获取主线程
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        self.setProgressValue(self.currentFileSize * 1.0 / self.fileTotalSize);
    }];
}
// 数据下载完成调用的方法
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    // 关闭输出流 并关闭强指针
    [self.outputStream close];
    self.outputStream = nil;
    // 关闭会话
    [self.session invalidateAndCancel];
    NSLog(@"%@",[NSThread currentThread]);
}
-(void)dealloc{
}
@end
