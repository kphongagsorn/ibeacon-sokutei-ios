//
//  MapViewController.h
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 10/7/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController{

IBOutlet UIView *mapImageView;
    IBOutlet UILabel *coordinatesLabel;
   // IBOutlet UIButton *setCoordinates;
    IBOutlet UIButton *Done;
    IBOutlet UIButton *Predict;
}

@property (strong, nonatomic) NSNumber *xCoordinate;
@property (strong, nonatomic) NSNumber *yCoordinate;


@end
