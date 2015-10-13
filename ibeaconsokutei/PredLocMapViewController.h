//
//  PredLocMapViewController.h
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 1/6/15.
//  Copyright (c) 2015 Phongagsorn Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PredLocMapViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *predictedCoordLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveCoordBtn;
@property (strong, nonatomic) IBOutlet UIButton *doneBtn;
@property (strong, nonatomic) IBOutlet UIImageView *predMapImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


@property (strong, nonatomic) NSNumber *correctedXCoordinate;
@property (strong, nonatomic) NSNumber *correctedYCoordinate;
@property (strong, nonatomic) NSNumber *tappedCoordinateX;
@property (strong, nonatomic) NSNumber *tappedCoordinateY;
@property (strong, nonatomic) NSNumber *learnPredictApiCallFlag; //1= learn, 2 = predict, 3 = learnxy

@property (strong, nonatomic) NSMutableArray *beaconData;

@property (strong, nonatomic) NSNumber* soinn_sec_range;

@end
