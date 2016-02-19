//
//  ViewController.m
//  NSURLSession实现离线断点续传
//
//  Created by HEYANG on 16/2/18.
//  Copyright © 2016年 HEYANG. All rights reserved.
//

#import "ViewController.h"
#import "RainbowProgress.h"

#import "DownloadTool.h"

#define MP4_URL_String @"http://120.25.226.186:32812/resources/videos/minion_02.mp4"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *showDownloadState;
/** 彩虹进度条 */
@property (nonatomic,weak)RainbowProgress *rainbowProgress;
/** 网络下载工具对象 */
@property (nonatomic,strong)DownloadTool *download;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSelfView];
    [self addProgress];
    [self addDownload];
    
}
// 启动和关闭的网络下载开关
- (IBAction)SwitchBtn:(UISwitch *)sender {
    if (sender.isOn) {
        self.showDownloadState.text = @"开始下载";
        [self.download startDownload];
    }else{
        self.showDownloadState.text = @"暂停下载";
        [self.download suspendDownload];
    }
}
#pragma mark - 设置控制器View
-(void)setSelfView{
    self.view.backgroundColor = [UIColor blackColor];
}
#pragma mark - 添加彩虹进度条
-(void)addProgress{
    // 创建彩虹进度条,并启动动画
    RainbowProgress* rainbowProgress = [[RainbowProgress alloc] init];
    [rainbowProgress startAnimating];
    [self.view addSubview:rainbowProgress];
    self.rainbowProgress = rainbowProgress;
}
#pragma mark - 创建网络下载任务
-(void)addDownload{
    DownloadTool* download = [DownloadTool DownloadWithURLString:MP4_URL_String setProgressValue:^(float progressValue) {
        self.rainbowProgress.progressValue = progressValue;
    }];
    self.download = download;
}

#pragma mark - 设置状态栏样式
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
