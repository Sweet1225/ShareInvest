//
//  ViewController.m
//  ShareInvest
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 sweet. All rights reserved.
//

#import "ViewController.h"
#import "NetWorkManager.h"

@interface ViewController ()<UITextFieldDelegate>
{
    float curShareNum;
    float openShareNum;
    float curRate;
    float addMoney;
    NSString* seekString;
}
@property (weak, nonatomic) IBOutlet UILabel *openLab;
@property (weak, nonatomic) IBOutlet UILabel *curLab;
@property (weak, nonatomic) IBOutlet UILabel *rateLab;
@property (nonatomic, strong) NetWorkManager* manager;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab;
@property (weak, nonatomic) IBOutlet UILabel *totalMony;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UILabel *seekLab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setClock];
    [self find];
    [self setTotalMoney];
    [self setupNet];
    [self setUpTextField];
    
}

- (void) setupNet{
    self.manager = [[NetWorkManager alloc] init];
    [self.manager getShareNum];
    __weak typeof(self) weakSelf = self;
    self.manager.blockOnGetShareNum = ^(float curNum,float openNum){
        curShareNum = curNum;
        openShareNum = openNum;
        weakSelf.curLab.text = [NSString stringWithFormat:@"%f",curNum];
        weakSelf.openLab.text = [NSString stringWithFormat:@"%f",openNum];
        
        float rate = (curNum-openNum)*100/openNum;
        weakSelf.rateLab.text = [NSString stringWithFormat:@"%f%%",rate];
        curRate = rate;
        NSLog(@"return suc!");
        if (curShareNum - openShareNum<=0) {
            weakSelf.moneyLab.text = [NSString stringWithFormat:@"应补仓%f元",[weakSelf calculateMoney]];
        }else{
            weakSelf.moneyLab.text = [NSString stringWithFormat:@"恭喜今天上涨"];
        }
        [weakSelf setRateLabColor];
    };

}

- (void)seekShare:(NSString*) str{
    if ([self.manager.blocks objectForKey:seekString]) {
        [self.manager.blocks removeObjectForKey:seekString];
    }
    __weak typeof(self) weakSelf = self;
    SWGetShareNum block = ^(float curNum,float openNum){
        NSString* labStr = [NSString stringWithFormat:@"%d   %f%%",(int)curNum,(curNum-openNum)*100/openNum];
        weakSelf.seekLab.text = labStr;
        if (curNum-openNum>=0) {
            weakSelf.seekLab.textColor = [UIColor redColor];
        }else{
            weakSelf.seekLab.textColor = [UIColor greenColor];
        }
    };
    if (![self.manager.blocks objectForKey:str]) {
        [self.manager.blocks setObject:block forKey:str];
    }
}

- (void) setUpTextField{
    seekString = @"sh000001";
    self.textField.text = seekString;
    self.textField.delegate = self;
    [self seekShare:seekString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void) setTotalMoney{
    NSString* m =[self readMoney];
    if (!m) {
        self.totalMony.text = @"10500";
    }else{
        self.totalMony.text = [self readMoney];
    }
}
- (IBAction)seetButtonTouch:(UIButton *)sender {
    [self seekShare:self.textField.text];
    seekString = self.textField.text;
}

- (void) find{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.manager getShareNum];
        [self.manager getCurDataFromShareNumber:seekString];
        [self find];
    });
}

- (void) setClock{
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    if ([dateString isEqualToString:[self readDay]]) {
        return;
    }
    NSLog(@"dateString:%@",dateString);
    
    NSDate* muDate = [self dateFromString:[NSString stringWithFormat:@"%@ 14:50:00",dateString]];
    NSTimeInterval t =  [muDate timeIntervalSinceDate:currentDate];
    if (t<=0) {
        t = t+60*60*24;
    }
    [self registerLocalNotification:t];
    [self saveDay:dateString];
}
- (IBAction)sureButonTouch:(UIButton *)sender {
    float total = [self.totalMony.text floatValue]+addMoney;
    [self saveMoney:[NSString stringWithFormat:@"%f",total]];
    [self setTotalMoney];
}

- (void) setRateLabColor{
    if (curRate>=0) {
        self.rateLab.textColor = [UIColor redColor];
    }else{
        self.rateLab.textColor = [UIColor greenColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define BASICMONEY 1000
- (float) calculateMoney{
    //1800 4000
    //风险点位
    float centerNum = 2200;
    //加仓本金
    float money = 200;
    money = money*(openShareNum-curShareNum)*100/openShareNum;
    
    //风险点位上下 应加或减
    float lowRiskRate = (centerNum-curShareNum)/curShareNum;
    money = money + lowRiskRate*BASICMONEY;
    addMoney = money;
    return money;
}

// 设置本地通知
- (void)registerLocalNotification:(NSInteger)alertTime {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
    NSLog(@"fireDate=%@",fireDate);
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitSecond;
    
    // 通知内容
    notification.alertBody =  [NSString stringWithFormat:@"来了哈哈"];
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"0.0" forKey:@"key"];
    notification.userInfo = userDict;
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSCalendarUnitDay;
    } else {
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSDayCalendarUnit;
    }
    
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (NSDate *)dateFromString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}

- (void) saveDay:(NSString*) day{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setObject:[NSNumber numberWithLong:[color colorCode]] forKey:@"mainColor"];
    [userDefaults setObject:day forKey:@"day"];
    [userDefaults synchronize];
}

- (NSString*) readDay{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* colorStr = [userDefaults stringForKey:@"day"];
    return colorStr;
}

- (void) saveMoney:(NSString*) day{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setObject:[NSNumber numberWithLong:[color colorCode]] forKey:@"mainColor"];
    [userDefaults setObject:day forKey:@"money"];
    [userDefaults synchronize];
}

- (NSString*) readMoney{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* colorStr = [userDefaults stringForKey:@"money"];
    return colorStr;
}

@end
