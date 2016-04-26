//
//  LastingData.m
//  ShareInvest
//
//  Created by apple on 16/4/26.
//  Copyright © 2016年 sweet. All rights reserved.
//

#import "LastingData.h"

@implementation LastingData

+(instancetype) shareInstance
{
    static LastingData* _globals = nil;
    if (!_globals) {
        _globals = [[LastingData alloc] init];
    }
    return _globals;
}



@end
