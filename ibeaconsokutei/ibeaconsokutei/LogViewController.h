//
//  LogViewController.h
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 6/19/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Beacons.h"

@end

@interface LogViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate> {
  
}
    //UI
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UITextView *logTextView;

@property (strong, nonatomic) NSString *logText;
@property (strong, nonatomic) NSString *coordinateTextX;
@property (strong, nonatomic) NSString *coordinateTextY;
@property (strong, nonatomic) NSString *timeAsText;


@property (strong, nonatomic) NSString *timerTime;
@property (strong, nonatomic) NSString *readingInterval;
@property (strong, nonatomic) NSString *numOfReadings;
@property (strong, nonatomic) IBOutlet UIButton *saveBeaconData;
@property (strong, nonatomic) IBOutlet UIImageView *checkmarkIM;
@property (strong, nonatomic) IBOutlet UIButton *savePredictLocation;
@property (strong, nonatomic) IBOutlet UIButton *soinnPredictLocBtn;
@property (strong, nonatomic) IBOutlet UIImageView *predictCheckMarkIM;

@property (strong, nonatomic) NSString *predictedLocFromVC;


//@property (weak, nonatomic) NSString *txtFileData;
//@property (weak, nonatomic) NSMutableString *txtFileMutable ;


- (double) calculateCoordinateErrorFor: (double)tappedXCoord withValue: (double)tappedYCoord andValue: (double)predictedXCoord andValue: (double)predictedYCoord;



@end
