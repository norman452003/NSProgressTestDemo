//
//  DonwloadOperation.m
//  NSProgressDemo2
//
//  Created by gongxin on 16/6/24.
//  Copyright © 2016年 gongxin. All rights reserved.
//

#import "DonwloadOperation.h"

static NSString* const FinishedKey = @"isFinished";
static NSString* const ExecutingKey = @"isExecuting";

@interface DonwloadOperation ()<NSURLSessionDataDelegate>

@property (nonatomic, copy) void(^completeBlock)(NSData *data);
@property (nonatomic, copy) void(^progressBlock)(NSProgress *progress);
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableData *mData;


// NSOperation需要实现
@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isExecuting) BOOL executing;
@end

@implementation DonwloadOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (instancetype)initWithURL:(NSString *)url progress:(void (^)(NSProgress *))progress complete:(void (^)(NSData *))complete{
    self = [super init];
    if (self) {
        self.completeBlock = complete;
        self.progressBlock = progress;
        _mData = [NSMutableData data];
        _url = url;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        
    }
    return self;
}

- (NSProgress *)progress{
    if (!_progress) {
        _progress = [NSProgress progressWithTotalUnitCount:1];
        _progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    }
    return _progress;
}

- (void)start{
    
    self.executing = YES;
    
    [self main];
}

- (void)main{
    
    @autoreleasepool {
        
        _task = [_session dataTaskWithURL:[NSURL URLWithString:_url]];
        
        [self.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        [_task resume];
        
        self.progress.cancellable = NO;
        self.progress.pausable = NO;
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [_mData appendData:data];
    self.progress.totalUnitCount = dataTask.countOfBytesExpectedToReceive;
    self.progress.completedUnitCount = dataTask.countOfBytesReceived;
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    self.executing = NO;
    if (_completeBlock) {
        _completeBlock(self.mData.copy);
    }
    [self.progress removeObserver:self forKeyPath:@"fractionCompleted"];
    self.finished = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([object isKindOfClass:[NSProgress class]]) {
        if (self.progressBlock) {
            self.progressBlock(self.progress);
        }
    }
}

#pragma mark - NSOperation KVO通知
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:ExecutingKey];
    _executing = executing;
    [self didChangeValueForKey:ExecutingKey];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:FinishedKey];
    _finished = finished;
    [self didChangeValueForKey:FinishedKey];
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end
