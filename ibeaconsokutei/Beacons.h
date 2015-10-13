//
//  Beacons.h
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 6/19/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Beacons : NSObject
{
    NSNumber *major;
    NSNumber *minor;
    NSNumber *rssi;
    NSNumber *accuracy;
    NSString *timeStamp;

}

@property(nonatomic, retain) NSNumber *major;
@property(nonatomic, retain) NSNumber *minor;
@property(nonatomic, retain) NSNumber *rssi;
@property(nonatomic, retain) NSNumber *accuracy;
@property(nonatomic, retain) NSString *timeStamp;

//- (id)initWithMinor:(NSString *)minor Rssi:(NSString *)rssi;
//- (id)initWithMajor:(NSString *)major Minor:(NSString *)minor Rssi:(NSString *)rssi;
- (id)initWithMajor:(NSNumber *)aMajor Minor:(NSNumber *)aMinor Rssi:(NSNumber *)aRssi Accuracy:(NSNumber *)aAccuracy TimeStamp: (NSString*)aTimeStamp;