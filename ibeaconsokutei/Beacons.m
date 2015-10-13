//
//  Beacons.m
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 6/19/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//



#import "Beacons.h"
@end


@implementation Beacons

@synthesize major;
@synthesize minor;
@synthesize rssi;
@synthesize accuracy;
@synthesize timeStamp;


- (id)initWithMajor:(NSNumber*)aMajor Minor:(NSNumber *)aMinor Rssi:(NSNumber *)aRssi Accuracy:(NSNumber *)aAccuracy TimeStamp:(NSString *)aTimeStamp;
{
    if( self = [super init] )
    {
        
        minor = aMinor;
        rssi = aRssi;
        major =aMajor;
        accuracy = aAccuracy;
        timeStamp =aTimeStamp;
        
        
    }
    
    return self;
}



@end

