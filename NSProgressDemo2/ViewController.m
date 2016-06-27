//
//  ViewController.m
//  NSProgressDemo2
//
//  Created by gongxin on 16/6/24.
//  Copyright © 2016年 gongxin. All rights reserved.
//

#import "ViewController.h"
#import "DonwloadOperation.h"

@interface ViewController ()

@property (nonatomic, strong) UIProgressView *mainProgressView;
@property (nonatomic, strong) UIProgressView *progressView1;
@property (nonatomic, strong) UIProgressView *progressView2;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSProgress *mainProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *l1 = [self labelWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] text:@"总下载进度"];
    l1.frame = CGRectMake(10, 100, l1.frame.size.width, l1.frame.size.height);
    [self.view addSubview:l1];
    
    _mainProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(l1.frame) + 50, l1.center.y, 200, 20)];
    _mainProgressView.progressTintColor = [UIColor greenColor];
    _mainProgressView.trackTintColor = [UIColor grayColor];
    _mainProgressView.progress = 0;
    [self.view addSubview:_mainProgressView];
    
    UILabel *l2 = [self labelWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] text:@"下载进度1"];
    l2.center = CGPointMake(l1.center.x, l1.center.y + 50);
    [self.view addSubview:l2];
    
    _progressView1 = [[UIProgressView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_mainProgressView.frame), l2.center.y, 200, 20)];
    _progressView1.progressTintColor = [UIColor greenColor];
    _progressView1.trackTintColor = [UIColor grayColor];
    _progressView1.progress = 0;
    [self.view addSubview:_progressView1];
    
    UILabel *l3 = [self labelWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] text:@"下载进度2"];
    l3.center = CGPointMake(l2.center.x, l2.center.y + 50);
    [self.view addSubview:l3];
    
    _progressView2 = [[UIProgressView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_progressView1.frame), l3.center.y, 200, 20)];
    _progressView2.progressTintColor = [UIColor greenColor];
    _progressView2.trackTintColor = [UIColor grayColor];
    _progressView2.progress = 0;
    [self.view addSubview:_progressView2];
    
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:@"下载" forState:UIControlStateNormal];
    [b setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [b sizeToFit];
    b.center = CGPointMake(self.view.center.x, self.view.center.y + 100);
    [b addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
    
}

- (void)startDownload{
    __weak typeof(self) weakSelf = self;
    long totalSize = 1;
    _mainProgress = [NSProgress progressWithTotalUnitCount:totalSize * 2];
    [_mainProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionInitial context:nil];

    
    DonwloadOperation *task1 = [[DonwloadOperation alloc] initWithURL:@"http://m4.pc6.com/cjh3/mpegstreamclip.dmg" progress:^(NSProgress *progress) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            weakSelf.progressView1.progress = progress.fractionCompleted;
        }];
    } complete:^(NSData *data) {
        
    }];
    task1.progress = [NSProgress progressWithTotalUnitCount:totalSize];
    [_mainProgress addChild:task1.progress withPendingUnitCount:totalSize];
    
    [self.queue addOperation:task1];
    
    DonwloadOperation *task2 = [[DonwloadOperation alloc] initWithURL:@"http://down.sandai.net/mac/thunder_dl2.6.9.1826_Beta.dmg" progress:^(NSProgress *progress) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            weakSelf.progressView2.progress = progress.fractionCompleted;
        }];
    } complete:^(NSData *data) {
        
    }];
    task2.progress = [NSProgress progressWithTotalUnitCount:totalSize];
    [_mainProgress addChild:task2.progress withPendingUnitCount:totalSize];
    
    [self.queue addOperation:task2];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        weakSelf.mainProgressView.progress = weakSelf.mainProgress.fractionCompleted;
    }];
}


- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)color text:(NSString *)text{
    UILabel *l = [[UILabel alloc] init];
    l.font = font;
    l.text = text;
    l.textColor= color;
    [l sizeToFit];
    return l;
}

- (NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
    [self.mainProgress removeObserver:self forKeyPath:@"fractionCompleted"];
}

@end
