//
//  ViewController.m
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 6/13/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import "ViewController.h"
//@import Quartzcore;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    //beacon UUID
    //NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
    //beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"se.mathijs.MiBeaconTrilateration"];
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"kevin.testregion"];
    
    // start ranging ID
    [locationManager startRangingBeaconsInRegion:beaconRegion];
    
    //  MiBeaconTrilaterator = [[MiBeaconTrilateration alloc] init];
    
    // misc UI settings
    //  [beaconGrid.layer setCornerRadius:10];
    //  [selfView.layer setCornerRadius:10];
    
    // [self plotBeaconsFromPlistToGrid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    foundBeacons = [beacons copy];
    
    // put them in the tableView
    [beaconsFound setText:[NSString stringWithFormat:@"Found beacons (%lu)", (unsigned long)[foundBeacons count]]];
    [beaconsTableView reloadData];
    
    }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [foundBeacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLBeacon *currentBeacon = [foundBeacons objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Neue Thin" size:15.0f]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%d/%d rssi:%ld dist: %.1fm", [[currentBeacon major] intValue], [[currentBeacon minor] intValue],(long)[currentBeacon rssi], [currentBeacon accuracy]]];
    
    return cell;
}

////////////////////////////////////////////////////////
//Pinch Zoom, Rotate, Pan for Map

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}
///////////////////////////////////////////////////////



@end








