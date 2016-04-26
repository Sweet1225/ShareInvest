//
//  NetWorkManager.h
//  Massage-iOS
//
//  Created by apple on 16/4/7.
//  Copyright © 2016年 ihunuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//连接设备成功的block
typedef void (^SWGetShareNum)(float curNum,float openNum);
//连接设备失败的block
@interface NetWorkManager : NSObject


- (void) getCurDataFromShareNumber:(NSString*) ShareNum;

- (void) getShareNum;

@property (nonatomic, copy) SWGetShareNum blockOnGetShareNum;

@property(nonatomic, strong) NSMutableDictionary* blocks;
@end
