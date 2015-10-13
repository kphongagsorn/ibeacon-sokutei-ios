//
//  SettingsViewController.h
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 7/28/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@class SettingsViewController;

/*
@protocol SettingsViewControllerDelegate <NSObject>
- (void)addItemViewController:(SettingsViewController *)controller didFinishEnteringItem:(NSNumber *)item;
@end
*/

/*
@protocol SettingsViewControllerDelegate <NSObject>
//- (void)addItemViewController:(SettingsViewController *)controller didFinishEnteringItem:(NSString *)item;

- (void)passValue:(id)delegate didFinishEnteringItem:(NSNumber *)item;

@end
 
 */

@interface SettingsViewController : UIViewController<UITextFieldDelegate> {
    IBOutlet UILabel *currentTimerSettingLabel;
     IBOutlet UIView *currentReadingsLabel;
     IBOutlet UILabel *currentSecondsLabel;
    IBOutlet UIImageView *checkmarkIM;
    
}

@property (strong, nonatomic) IBOutlet UITextField *timerSetting;
@property (strong, nonatomic) IBOutlet UIButton *setTimerTimeButton;

@property (strong, nonatomic) IBOutlet UITextField *numberOfReadings;
@property (strong, nonatomic) IBOutlet UIButton *setReadingsButton;


@property (strong, nonatomic) IBOutlet UITextField *secondsSetting;
@property (strong, nonatomic) IBOutlet UIButton *setSecondsButton;

@property (strong, nonatomic) NSNumber *timerTime;
@property (strong, nonatomic) NSNumber *readings;
@property (strong, nonatomic) NSNumber *timeInterval;

@property (strong, nonatomic) IBOutlet UIButton *setButton;

//@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;

//@property (strong, nonatomic) id <SettingsViewControllerDelegate> delegate;

@end
