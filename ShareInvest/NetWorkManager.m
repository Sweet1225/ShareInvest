//
//  NetWorkManager.m
//  Massage-iOS
//
//  Created by apple on 16/4/7.
//  Copyright © 2016年 ihunuo. All rights reserved.
//

#import "NetWorkManager.h"
#define SHANGZHENG "http://hq.sinajs.cn/list=sh000001"
#define SHENZHENG "http://hq.sinajs.cn/list=sz399006"
@implementation NetWorkManager

- (instancetype)init{
    self = [super init];
    return self;
}

- (NSMutableDictionary*)blocks{
    if (!_blocks) {
        _blocks = [[NSMutableDictionary alloc] init];
    }
    return _blocks;
}

- (void) getShareNum{
    NSString *urlStr = @"http://hq.sinajs.cn/list=sz399006";
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    //[request addValue: @"0d8be696c0e0baa6801e4eb84d753143" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   //NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSNEXTSTEPStringEncoding];
                                   //NSLog(@"HttpResponseBody %@",responseString);
                                   NSMutableArray* ary =  [self getNumFromString:responseString];
                                   if (self.blockOnGetShareNum) {
                                       self.blockOnGetShareNum([[ary objectAtIndex:3] floatValue],[[ary objectAtIndex:2] floatValue]);
                                       
                                   }
                               }
                           }];
}

- (void) getCurDataFromShareNumber:(NSString *)ShareNum{
    NSString *urlStr = [NSString stringWithFormat:@"http://hq.sinajs.cn/list=%@",ShareNum];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSNEXTSTEPStringEncoding];
                                   NSMutableArray* ary =  [self getNumFromString:responseString];
                                   float curNum;
                                   float openNum;
                                   if (ary.count<2) {
                                       curNum = 0;
                                       openNum = 0;
                                   }else{
                                       curNum =[[ary objectAtIndex:3] floatValue];
                                       openNum = [[ary objectAtIndex:2] floatValue];
                                   }
                                   if ([self.blocks objectForKey:ShareNum]) {
                                       SWGetShareNum block = [self.blocks objectForKey:ShareNum];
                                       block(curNum,openNum);
                                   }
                                   
                               }
                           }];
}



- (NSMutableArray*) getNumFromString:(NSString*) str
{
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    while (true) {
        NSRange range = [str rangeOfString:@","];
        if (range.length==0) {
            break;
        }
        NSRange newR = NSMakeRange(0, range.location-1);
        NSString*  newStr = [str substringWithRange:newR];
        [ary addObject:newStr];
        NSRange curR = NSMakeRange(range.location+1, str.length-range.location-1);
        str = [str substringWithRange:curR];
        NSLog(@"%@",newStr);
        
    }
    
    
    
    
    return  ary;
}

@end
