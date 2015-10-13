//
//  ViewController.h
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 6/13/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MiBeaconTrilateration.h"

#import <Foundation/Foundation.h>
@import CoreLocation;


@interface ViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CLBeaconRegion *beaconRegion;
    CLLocationManager *locationManager;
    
    NSDictionary *beaconCoordinates;
    // float scaleFactor;
    //  int maxY;
    
    //   MiBeaconTrilateration *MiBeaconTrilaterator;
    
    NSMutableArray *foundBeacons;
    
    // UI
    IBOutlet UILabel *xyResult;
    IBOutlet UITableView *beaconsTableView;
    IBOutlet UILabel *beaconsFound;
    IBOutlet UILabel *selfView;
    IBOutlet UIView *beaconGrid;
    IBOutlet UIScrollView *mapScrollView;
}

@end
