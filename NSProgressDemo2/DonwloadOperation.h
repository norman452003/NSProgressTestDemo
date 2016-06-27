//
//  DonwloadOperation.h
//  NSProgressDemo2
//
//  Created by gongxin on 16/6/24.
//  Copyright © 2016年 gongxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DonwloadOperation : NSOperation

@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSString *url;

- (instancetype)initWithURL:(NSString *)url progress:(void(^)(NSProgress *progress))progress  complete:(void(^)(NSData *data))complete;

@end
