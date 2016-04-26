//
//  SetViewController.m
//  ShareInvest
//
//  Created by apple on 16/4/26.
//  Copyright © 2016年 sweet. All rights reserved.
//

#import "SetViewController.h"
#import "LastingData.h"
#import "ViewController.h"
#import "NetWorkManager.h"
@interface SetViewController ()<UITextFieldDelegate>
{
    NSString* seekString;
}
@property (weak, nonatomic) IBOutlet UILabel *seekLab;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property(nonatomic, strong) LastingData* lastingData;
@property (weak, nonatomic) IBOutlet UITextField *riskTextField;
@property (weak, nonatomic) IBOutlet UITextField *addMoneyTextField;
@property (weak, nonatomic) IBOutlet UITextField *shareTextField;
@property (weak, nonatomic) IBOutlet UITextField *riskMonetTextField;
@property (nonatomic, strong) NetWorkManager* manager;
@end

@implementation SetViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[NetWorkManager alloc] init];
    [self find];
    [self setupLastingData];
    [self setUpTextField];
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

- (void) find{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.manager getCurDataFromShareNumber:seekString];
        [self find];
    });
}

- (void) setUpTextField{
    seekString = @"sh000001";
    self.textField.text = seekString;
    self.textField.delegate = self;
    [self seekShare:seekString];
    [self.manager getCurDataFromShareNumber:seekString];
    
    self.riskTextField.text = [NSString stringWithFormat:@"%ld",(long)self.lastingData.riskNum];
    self.addMoneyTextField.text = [NSString stringWithFormat:@"%ld",(long)self.lastingData.addMoney];
    self.riskMonetTextField.text = [NSString stringWithFormat:@"%ld",(long)self.lastingData.riskMoney];
    self.shareTextField.text = self.lastingData.shareNum;
    self.riskTextField.delegate = self;
    self.addMoneyTextField.delegate = self;
    self.shareTextField.delegate = self;
    self.riskMonetTextField.delegate = self;
}

- (IBAction)seekButtonTouch:(UIButton *)sender {
    [self seekShare:self.textField.text];
    seekString = self.textField.text;
    [self.manager getCurDataFromShareNumber:seekString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void) setupLastingData{
    self.lastingData = [LastingData shareInstance];
    self.lastingData.riskNum = [self readRiskNum];
    self.lastingData.addMoney = [self readAddMoney];
    self.lastingData.shareNum = [self readShareNum];
    self.lastingData.riskMoney = [self readRiskMoney];
}

- (void) saveRiskNum:(NSInteger) num{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:num forKey:@"riskNum"];
    self.lastingData.riskNum = num;
    [userDefaults synchronize];
}

- (NSInteger) readRiskNum{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger colorStr = [userDefaults integerForKey:@"riskNum"];
    if (!colorStr) {
        colorStr = 2200;
    }
    return colorStr;
}

- (void) saveAddMoney:(NSInteger) num{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:num forKey:@"addMoney"];
    self.lastingData.addMoney = num;
    [userDefaults synchronize];
}

- (NSInteger) readAddMoney{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger colorStr = [userDefaults integerForKey:@"addMoney"];
    if (!colorStr) {
        colorStr = 200;
    }
    return colorStr;
}

- (void) saveShareNum:(NSString*) num{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:num forKey:@"shareNum"];
    self.lastingData.shareNum = num;
    [userDefaults synchronize];
}

- (NSInteger) readRiskMoney{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger colorStr = [userDefaults integerForKey:@"riskMoney"];
    if (!colorStr) {
        colorStr = 1000;
    }
    return colorStr;
}

- (void) saveRiskMoney:(NSInteger) num{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:num forKey:@"riskMoney"];
    self.lastingData.riskMoney = num;
    [userDefaults synchronize];
}

- (NSString*) readShareNum{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* colorStr = [userDefaults stringForKey:@"shareNum"];
    if (!colorStr) {
        colorStr = @"sz399006";
    }
    return colorStr;
}

- (IBAction)sureTouch:(UIButton *)sender {

    [self saveRiskNum:[self.riskTextField.text integerValue]];
    [self saveAddMoney:[self.addMoneyTextField.text integerValue]];
    [self saveShareNum:self.shareTextField.text];
    [self saveRiskMoney:[self.riskMonetTextField.text integerValue]];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}

@end
