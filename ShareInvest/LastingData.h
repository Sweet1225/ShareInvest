//
//  LastingData.h
//  ShareInvest
//
//  Created by apple on 16/4/26.
//  Copyright © 2016年 sweet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastingData : NSObject
+(instancetype) shareInstance;
//风险点位
@property (nonatomic, assign) NSInteger riskNum;
//加仓本金
@property (nonatomic, assign) NSInteger addMoney;
//股票代码
@property (nonatomic, assign) NSString* shareNum;
//风险金额
@property (nonatomic, assign) NSInteger riskMoney;
@end
