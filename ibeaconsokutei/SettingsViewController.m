//
//  SettingsViewController.m
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 7/28/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewController.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController


NSNumber *timerTimeNum;
NSString *timeTimeNumAsStr;

NSNumber *readingsNum;
NSNumber *timeIntervalNum;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _setButton.backgroundColor = [UIColor blueColor];
    
    _timerSetting.returnKeyType =  UIReturnKeyDone;
    [_timerSetting setDelegate:self];
    
    _secondsSetting.returnKeyType =  UIReturnKeyDone;
    [_secondsSetting setDelegate:self];
    
    //Default settings
    timerTimeNum = [[NSNumber alloc]initWithInt:60];
    //readingsNum = [[NSNumber alloc]initWithInt:1];
    timeIntervalNum = [[NSNumber alloc]initWithFloat:1];
    
    
    _timerTime = timerTimeNum;
   // _readings = readingsNum;
    _timeInterval = timeIntervalNum;
    
    
    //[currentTimerSettingLabel setText:[NSString stringWithFormat:@"Current Timer: %@",_secondsSetting.text]] ;
    //[currentSecondsLabel setText:[NSString stringWithFormat:@"Reading Delay Interval: %@", _secondsSetting.text]] ;
    

    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//hide keyboard on return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


//only allow numerical input and decimal point
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // allow backspace
    if (!string.length)
    {
        return YES;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //first, check if the new string is numeric only. If not, return NO;
    NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    if ([newString rangeOfCharacterFromSet:characterSet].location != NSNotFound)
    {
        return NO;
    }
    
    //return [newString doubleValue] < 1000;
    
    return YES;
}


//set timer and number of readings
- (IBAction)set:(id)sender {
    
    //default timer time is 60 seconds, 1 reading per second
    if ([_timerSetting.text isEqual: @""] || [_secondsSetting.text isEqual: @""] ) {
        timerTimeNum = [[NSNumber alloc]initWithInt:60];
        timeIntervalNum = [[NSNumber alloc]initWithInt:1];
        
        UIImage *checkmark =[UIImage imageNamed:@"x-mark.png"];
        [checkmarkIM setImage:checkmark];
    }
    
    //set timer and readings per second
    else {
        
        NSString *timer = _timerSetting.text;
        _timerTime = [NSNumber numberWithFloat:[timer floatValue]];
        
        NSString *timeInterv = _secondsSetting.text;
        _timeInterval = [NSNumber numberWithFloat:[timeInterv floatValue]];
        
        //display check mark
        UIImage *checkmark =[UIImage imageNamed:@"check-mark.png"];
        [checkmarkIM setImage:checkmark];
    }
    
}




/*
//segue 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.destinationViewController isKindOfClass:[ViewController class]]){
        
        ViewController *destination =  [segue destinationViewController];

        NSString *timer = _timerSetting.text;
        timerTimeNum = [NSNumber numberWithFloat:[timer floatValue]];
        NSString *timeInterv = _secondsSetting.text;
        timeIntervalNum = [NSNumber numberWithFloat:[timeInterv floatValue]];
        
        
        destination.timerTimeFromSettings = timerTimeNum;
        
        destination.timeIntervalFromSettings = timeIntervalNum;
    
        
        
        
    }
}
*/

@end
