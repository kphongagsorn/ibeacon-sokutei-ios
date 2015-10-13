//
//  PredLocMapViewController.m
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 1/6/15.
//  Copyright (c) 2015 Phongagsorn Kevin. All rights reserved.
//
//
// UIPicker Tutorial:
//https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/UIKitUICatalog/UIPickerView.html
//http://codewithchris.com/uipickerview-example/
//
//Zoom:
//http://stackoverflow.com/questions/6048257/how-can-i-zoom-in-and-out-in-a-uiimageview-without-uiscrollview
//
#import <sys/utsname.h>
/*
 @"i386"      on the simulator
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPod5,1"   on iPod Touch Fifth Generation
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPad1,1"   on iPad
 @"iPad2,1"   on iPad 2
 @"iPad3,1"   on 3rd Generation iPad
 @"iPad3,2":  on iPad 3(GSM+CDMA)
 @"iPad3,3":  on iPad 3(GSM)
 @"iPad3,4":  on iPad 4(WiFi)
 @"iPad3,5":  on iPad 4(GSM)
 @"iPad3,6":  on iPad 4(GSM+CDMA)
 @"iPhone3,1" on iPhone 4
 @"iPhone4,1" on iPhone 4S
 @"iPhone5,1" on iPhone 5
 @"iPad3,4"   on 4th Generation iPad
 @"iPad2,5"   on iPad Mini
 @"iPhone5,1" on iPhone 5(GSM)
 @"iPhone5,2" on iPhone 5(GSM+CDMA)
 @"iPhone5,3  on iPhone 5c(GSM)
 @"iPhone5,4" on iPhone 5c(GSM+CDMA)
 @"iPhone6,1" on iPhone 5s(GSM)
 @"iPhone6,2" on iPhone 5s(GSM+CDMA)
 @"iPhone7,1" on iPhone 6 Plus
 @"iPhone7,2" on iPhone 6
 */
#import <AFHTTPRequestOperationManager.h>
#import <AdSupport/ASIdentifierManager.h>
#import "PredLocMapViewController.h"
#import "Beacons.h"
@end


@interface PredLocMapViewController ()

@end

@implementation PredLocMapViewController
//Tamachi 16fl dimensions in meters; adjusted to account for imageview bounds
#define FLOOR_PLAN_HEIGHT 73.05 //73.34 //82.34  //73.34 ; true dimensions : 72 m
#define FLOOR_PLAN_WIDTH 37.58 //38.726 //+ (550+600+650 mm) ; true dimensions : 37.8 m ((7200m*5)+(*550m+600m+650m))

CGFloat correctedXCGFloat = 0;
CGFloat correctedYCGFloat = 0;
NSMutableArray* mutArrofSubarr;
NSMutableArray* beaconDataArrForSoinn;
NSArray* algoPredictedLocationResponse;

double predictedXPixDim = -1;
double predictedYPixDim =-1;
double predictedX = -1;
double predictedY =-1;

double theErrorDiff=-1;

NSMutableString* loggedData;




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_scrollView addSubview:_predMapImageView];
    _scrollView.contentSize = _predMapImageView.frame.size;
    
    
    // Enables/Disables panning/scrolling in the scrollView
    _scrollView.scrollEnabled = YES;
    
    // For supporting zoom,
    //_scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 5.0f;
    _scrollView.delegate=(id)self;

    
    beaconDataArrForSoinn = [[NSMutableArray alloc] init];
    NSLog(@"beaconData: %@",_beaconData);
    
    loggedData = [NSMutableString string];
    
    //NSSortDescriptor *major = [NSSortDescriptor sortDescriptorWithKey:@"major" ascending:YES selector:@selector(compare:)];
    //NSSortDescriptor *minor = [NSSortDescriptor sortDescriptorWithKey:@"minor" ascending:YES selector:@selector(compare:)];
    //NSSortDescriptor *rssi = [NSSortDescriptor sortDescriptorWithKey:@"rssi" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *timeSorting = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES selector:@selector(compare:)];
    
    NSArray *descriptors = @[timeSorting];
    
    //NSArray *descriptors = @[major, minor, timeSorting];
    
    mutArrofSubarr = [NSMutableArray array];
    
    //NSArray *descriptors = @[timeSorting];
    [_beaconData sortUsingDescriptors:descriptors];
    
    
    
    // NSUInteger length = [beaconArrayObj count];
    NSUInteger location = 0;
    NSNumber *bMinor;
    NSNumber *cMinor;
    NSNumber *bMajor;
    NSNumber *cMajor;
    NSString *bTime;
    NSString *cTime;
    
    
    int j = 1;//comparison beacon incrementer
    for (int i =0; i<_beaconData.count; i++) {
        if (j==_beaconData.count) {
            [mutArrofSubarr addObject:[_beaconData subarrayWithRange:NSMakeRange(location, j-location)]];
            break;
        }
        else{
            Beacons *beacon= _beaconData[i];
            Beacons *compareBeacon = _beaconData[j];
            bMajor = beacon.major;
            cMajor = compareBeacon.major;
            bMinor = beacon.minor;
            cMinor = compareBeacon.minor;
            
            bTime = beacon.timeStamp;
            cTime = compareBeacon.timeStamp;
            
            if ([bTime isEqualToString: cTime]) {
                //keep reading
            }
            
            else{
                [mutArrofSubarr addObject:[_beaconData subarrayWithRange:NSMakeRange(location, j-location)]];
                int temp = j;
                location = temp;
            }//endelse
            
        }//end else
        j++;//increment beacon to compare one beacon ahead
    }//end for
     
    NSLog(@"array of sub array: %@",mutArrofSubarr);
     
    
    //border around map image
    _predMapImageView.layer.borderColor = [UIColor blackColor].CGColor;
    _predMapImageView.layer.borderWidth = 1.0f;
    
    [self callSoinn:[_learnPredictApiCallFlag intValue]];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) machineName{
    /*
     @"i386"      on the simulator
     @"iPod1,1"   on iPod Touch
     @"iPod2,1"   on iPod Touch Second Generation
     @"iPod3,1"   on iPod Touch Third Generation
     @"iPod4,1"   on iPod Touch Fourth Generation
     @"iPod5,1"   on iPod Touch Fifth Generation
     @"iPhone1,1" on iPhone
     @"iPhone1,2" on iPhone 3G
     @"iPhone2,1" on iPhone 3GS
     @"iPad1,1"   on iPad
     @"iPad2,1"   on iPad 2
     @"iPad3,1"   on 3rd Generation iPad
     @"iPad3,2":  on iPad 3(GSM+CDMA)
     @"iPad3,3":  on iPad 3(GSM)
     @"iPad3,4":  on iPad 4(WiFi)
     @"iPad3,5":  on iPad 4(GSM)
     @"iPad3,6":  on iPad 4(GSM+CDMA)
     @"iPhone3,1" on iPhone 4
     @"iPhone4,1" on iPhone 4S
     @"iPhone5,1" on iPhone 5
     @"iPad3,4"   on 4th Generation iPad
     @"iPad2,5"   on iPad Mini
     @"iPhone5,1" on iPhone 5(GSM)
     @"iPhone5,2" on iPhone 5(GSM+CDMA)
     @"iPhone5,3  on iPhone 5c(GSM)
     @"iPhone5,4" on iPhone 5c(GSM+CDMA)
     @"iPhone6,1" on iPhone 5s(GSM)
     @"iPhone6,2" on iPhone 5s(GSM+CDMA)
     @"iPhone7,1" on iPhone 6 Plus
     @"iPhone7,2" on iPhone 6
     */
    
    NSDictionary *deviceTypes = @{
                                 @"iPhone5,1": @"iphone5",
                                 @"iPhone5,2": @"iphone5",
                                 @"iPhone5,3": @"iphone5c",
                                 @"iPhone5,4": @"iphone5c",
                                 @"iPhone6,1": @"iphone5s",
                                 @"iPhone6,2": @"iphone5s",
                                 @"iPhone7,1": @"iphone6plus",
                                 @"iPhone7,2": @"iphone6",
                                 };

    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *soinnName = [NSString stringWithCString:systemInfo.machine
                                          encoding:NSUTF8StringEncoding];
    NSString* result = [NSString string];
    
    if(deviceTypes[soinnName]) {
        result =deviceTypes[soinnName];
    }
    else {
        result=@"general";
    }
    return result;
    
}

//hide status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// Implement a single scroll view delegate method
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return _predMapImageView;
}


//////////////////////////////////////////////////
-(double)soinnCalculateCoordinateErrorFor:(double) tx withValue: (double)ty andValue: (double) px andValue: (double) py{
    double tappedX = tx;
    double tappedY = ty;
    double predictedX = px;
    double predictedY = py;
    double result = ((predictedX-tappedX)*(predictedX-tappedX))+((predictedY-tappedY)*(predictedY-tappedY));
    return sqrt(result);
}

////////////////////////////////////////////////////////////////////////

-(void) callSoinn: (int) soinnApiFlag{
    if(soinnApiFlag ==1){
         //call soinn learnApi
        [self callLearnApi];
    }
    else if (soinnApiFlag ==2){
        //call soinn predictApi
        [self callPredictApi];
    }
    else if (soinnApiFlag ==3){
        //call soinn learnXYApi
        [self callLearnXYApi];
    }
}

//alert view actions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    //alertview tag for algorimthically predicting location
    if(alertView.tag==999){
        if([title isEqualToString:@"1 second"]){
            _soinn_sec_range =[NSNumber numberWithInt:1 ];
            NSString * output= [self predictLocationWithAlgo:mutArrofSubarr];
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"Algorithm Prediction"
                                                            message:output
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
        }
        
        else if([title isEqualToString:@"3 seconds"]){
            _soinn_sec_range =[NSNumber numberWithInt:3 ];
            NSString * output= [self predictLocationWithAlgo:mutArrofSubarr];
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"Algorithm Prediction"
                                                            message:output
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });

            
        }
        else if([title isEqualToString:@"5 seconds"]){
            _soinn_sec_range =[NSNumber numberWithInt:5];
            NSString * output= [self predictLocationWithAlgo:mutArrofSubarr];
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"Algorithm Prediction"
                                                            message:output
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });

            
        }
        else if([title isEqualToString:@"10 seconds"]){
            _soinn_sec_range =[NSNumber numberWithInt:10 ];
            NSString * output= [self predictLocationWithAlgo:mutArrofSubarr];
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"Algorithm Prediction"
                                                            message:output
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });

             
        }
        else {}
        
    }
    
    //alertview tag for saving algorithmically predicted data to text file
    if(alertView.tag==777){
        if([title isEqualToString:@"Cancel"])
        {
            
        }
        else if([title isEqualToString:@"Save"]){
            //current time for saving data to .txt file
            NSString *currentTimeStamp;
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
            currentTimeStamp = [dateFormatter stringFromDate:now];
            
            NSMutableString * loggedTimeAndData = [NSMutableString stringWithFormat: @"\nTime recorded:%@\n",currentTimeStamp];
            [loggedTimeAndData appendFormat:@"%@",loggedData];
            
            NSString* dataToBeSavedToTxtFile = loggedTimeAndData;
            logThisPrediction(dataToBeSavedToTxtFile, @"locationLogFile.txt");
            [loggedData setString:@""];
            dataToBeSavedToTxtFile=@"";
        }
    }

    
    //alertview tag for saving soin data to text file
    if(alertView.tag==888){
        if([title isEqualToString:@"Cancel"])
        {
            
        }
        else if([title isEqualToString:@"Save"]){
            //current time for saving data to .txt file
            NSString *currentTimeStamp;
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
            currentTimeStamp = [dateFormatter stringFromDate:now];
            
            //NSMutableString * loggedTimeAndData = [NSMutableString stringWithFormat: @"\nTime recorded:%@\n",currentTimeStamp];
            //[loggedTimeAndData appendFormat:@"%@",loggedData];
            
           // NSString* dataToBeSavedToTxtFile = loggedTimeAndData;
           // logThisPrediction(dataToBeSavedToTxtFile, @"soinnLogFile.txt");
            logThisPrediction(loggedData, @"soinnLogFile.txt");
            [loggedData setString:@""];
            //dataToBeSavedToTxtFile=@"";
        }
    }

    //default alert view is for soin api calls
    else if (alertView.tag==111){
        if([title isEqualToString:@"1 second"]){
            _soinn_sec_range =[NSNumber numberWithInt:1 ];
            [self callSoinn:[_learnPredictApiCallFlag intValue]];
        }
        
        else if([title isEqualToString:@"3 seconds"]){
            _soinn_sec_range =[NSNumber numberWithInt:3 ];
            [self callSoinn:[_learnPredictApiCallFlag intValue]];
      
        }
        else if([title isEqualToString:@"5 seconds"]){
            _soinn_sec_range =[NSNumber numberWithInt:5];
            [self callSoinn:[_learnPredictApiCallFlag intValue]];
        }
        else if([title isEqualToString:@"10 seconds"]){
            _soinn_sec_range =[NSNumber numberWithInt:10 ];
            [self callSoinn:[_learnPredictApiCallFlag intValue]];
         }
        else {}
           
    }
    
}

////////////////////////////////////////////////////////////////////////
- (IBAction)algoPredictBtnPress:(id)sender {
    
    NSString *alertMessage = [NSString stringWithFormat:@"Predict location using algorithm?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Algorithm"
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"1 second",@"3 seconds",@"5 seconds",@"10 seconds", nil];
    
    alert.tag =999;
    [alert show];
}

- (IBAction)saveBtnPressSoinn:(id)sender {
    //send xy to learnxy API
    NSString *alertMessage = [NSString stringWithFormat:@"Save data to text file?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOINN"
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    alert.tag =888;
    [alert show];
}

- (IBAction)learnXYBtnPress:(id)sender {
    
    _learnPredictApiCallFlag =[NSNumber numberWithInt:3 ];
    
    //send xy to learnxy API
    NSString *alertMessage = [NSString stringWithFormat:@"Learn XY coordinates and beacons?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOINN"
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"1 second",@"3 seconds",@"5 seconds",@"10 seconds", nil];
    alert.tag =111;
    [alert show];
}
- (IBAction)predictBtnPress:(id)sender {
    
    _learnPredictApiCallFlag =[NSNumber numberWithInt:2 ];
    
    //call predict API
    NSString *alertMessage = [NSString stringWithFormat:@"Predict location?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOINN"
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"1 second",@"3 seconds",@"5 seconds",@"10 seconds", nil];
    alert.tag =111;
    [alert show];
}
- (IBAction)learnBtnPress:(id)sender {
    
    _learnPredictApiCallFlag =[NSNumber numberWithInt:1 ];
    
    //call learn API
    NSString *alertMessage = [NSString stringWithFormat:@"Learn beacons?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOINN"
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"1 second",@"3 seconds",@"5 seconds",@"10 seconds", nil];
    alert.tag =111;
    [alert show];
}

////////////////////////////////////////////////////////////////////////
//Handle Tap

//Find and convert tapped point to corresponding map coordinates
- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    NSArray *subviews = [_predMapImageView subviews];
    
    // Remove old red circles on screen
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    // Draw a square where the touch occurred; MAP IS SIDEWAYS ON PHONE SO X AND Y ARE DIFFERENT
    //predictedXPixDim = predPtY;
    //predictedYPixDim = predPtX;
    
    UIView *predPointView = [[UIView alloc] init];
    [predPointView setBackgroundColor:[UIColor redColor]];
    predPointView.frame = CGRectMake(predictedXPixDim, predictedYPixDim, 3, 3);
    [_predMapImageView addSubview:predPointView];
    
    CGPoint tappedPoint = [recognizer locationInView:_predMapImageView];
    //float changeHeight = (FLOOR_PLAN_HEIGHT/mapImageView.frame.size.height);
    
    //Using scrollview frame size
    //correctedXCGFloat = tappedPoint.y * (FLOOR_PLAN_HEIGHT/_predMapImageView.frame.size.height);
    correctedXCGFloat = tappedPoint.y * (FLOOR_PLAN_HEIGHT/_scrollView.frame.size.height);
    
    //Using scrollview frame size
    //correctedYCGFloat = tappedPoint.x * (FLOOR_PLAN_WIDTH/_predMapImageView.frame.size.width);
    correctedYCGFloat = tappedPoint.x * (FLOOR_PLAN_WIDTH/_scrollView.frame.size.width);
    
    //NSLog(@"Touch Using UITapGestureRecognizer x : %f y : %f", xCoordinate, yCoordinate);
    
    _correctedXCoordinate = [NSNumber numberWithFloat:correctedXCGFloat];
    _correctedYCoordinate = [NSNumber numberWithFloat:correctedYCGFloat];
    
    double errorSabun = [self soinnCalculateCoordinateErrorFor:[_correctedXCoordinate doubleValue] withValue:[_correctedYCoordinate doubleValue] andValue:predictedX andValue:predictedY];
    
    [_predictedCoordLabel setText:[NSString stringWithFormat:@"predicted x: %f predicted y: %f\nx: %@  y: %@, error: %f", predictedX, predictedY, _correctedXCoordinate, _correctedYCoordinate,errorSabun]];
    
    theErrorDiff = errorSabun;
     //[_predictedCoordLabel sizeToFit];
    
    
    // Draw a square where the touch occurred
    UIView *touchView = [[UIView alloc] init];
    [touchView setBackgroundColor:[UIColor blueColor]];
    touchView.frame = CGRectMake(tappedPoint.x, tappedPoint.y, 3, 3);
    //touchView.layer.cornerRadius = 15;
    [_predMapImageView addSubview:touchView];
    
    
    
    
}

//mark tapped point with red dot
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   /*
    NSArray *subviews = [_predMapImageView subviews];
   
    // Remove old red circles on screen
   for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    //Mark tapped area on map
    UITouch *touch = [touches anyObject];
    if ([touch view] == _predMapImageView)
    {
        // Enumerate over all the touches and draw a red dot on the screen where the touches were
        [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            // Get a single touch and it's location
            UITouch *touch = obj;
            CGPoint touchPoint = [touch locationInView: _predMapImageView];
            
            // Draw a square where the touch occurred
            UIView *touchView = [[UIView alloc] init];
            [touchView setBackgroundColor:[UIColor blueColor]];
            touchView.frame = CGRectMake(touchPoint.x, touchPoint.y, 6, 6);
            //touchView.layer.cornerRadius = 15;
            [_predMapImageView addSubview:touchView];
            //[mapScrollView addSubview: mapImageView];
            
            //add predicted x and y if available
            if ((predictedXPixDim >-1) && (predictedYPixDim >- 1)){
                UIView *predPointView = [[UIView alloc] init];
                [predPointView setBackgroundColor:[UIColor redColor]];
                predPointView.frame = CGRectMake(predictedXPixDim, predictedYPixDim, 6, 6);
                [_predMapImageView addSubview:predPointView];
                [_scrollView addSubview:_predMapImageView];
            }
            
        }];
        
    } //endif
    */
}
///////////////////////////////////////////////////////////////////
/**
 Function makes call to SOINN's LearnXY Api
 http://stackoverflow.com/questions/14213471/parsing-json-with-afnetworking-give-results-with-round-brackets
 **/

-(void)callLearnXYApi{
    [loggedData setString:@""];
    //default coordinates for soinn predict map are 0,0
    if(_correctedXCoordinate == nil){
        _correctedXCoordinate = [NSNumber numberWithDouble:0.0];
    }
    if(_correctedYCoordinate == nil){
        _correctedYCoordinate = [NSNumber numberWithDouble:0.0];
    }
    
    NSString *correctedXCoordString = [_correctedXCoordinate stringValue];
    NSString *correctedYCoordString = [_correctedYCoordinate stringValue];
    NSString *learnXYApiRequestUrl = @"http://153.149.174.102/learnxy";
    
    //device information
    UIDevice *device = [UIDevice currentDevice];
    NSString *osver= device.systemVersion;
    NSString *model = device.model;
    NSString *phone_id = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *soinn_name = [self machineName];
    
    
    //current time for saving data to .txt file
    NSString *currentTimeStamp;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    currentTimeStamp = [dateFormatter stringFromDate:now];

    

/*Example json body request for soinn apis below
 *
    NSArray* beaconParamForApi = @[
                             @{
                                 @"datetime":@"2014-11-25T10:04:28",
                                 @"signal_array":
                                     @[
                                         @{
                                             @"rssi":@(-100),
                                             @"uuid":@"00000000-8e5b-1001-b000-001c4db3db2c",
                                             @"major":@(5),
                                             @"minor":@(5)
                                             },
                                         @{
                                             @"rssi":@(-78),
                                             @"uuid":@"00000000-8e5b-1001-b000-001c4db3db2c",
                                             @"major":@(101),
                                             @"minor":@(105)
                                             }
                                         ]
                                 }
                             ];
 
    NSLog(@"beaconParamForApi: %@",beaconParamForApi);
    */

    //prep data to be saved
    //[loggedData appendFormat:@"%@,",currentTimeStamp];
    NSMutableArray* dtSigs = [NSMutableArray array];
    NSArray *beaconParamForApi = [NSArray array];
    for (int i= 0; i<[_soinn_sec_range intValue]; i++){
        if(i>=mutArrofSubarr.count) break;
        NSArray *subArray = mutArrofSubarr[i];
        NSString *theTimeStamp =@"";
        NSMutableArray *sigParam = [NSMutableArray array];
      
        for(int j =0; j< subArray.count; j++){
            Beacons * b= subArray[j];
            if(![theTimeStamp isEqualToString:b.timeStamp]){
                theTimeStamp = [NSString stringWithString:b.timeStamp];
            }
            int theRssi =[b.rssi intValue];
            int theMaj= [b.major intValue];
            int theMin= [b.minor intValue];
            NSArray* sigTemp = @{
                                 @"rssi":@(theRssi),
                                 @"uuid":@"00000000-8e5b-1001-b000-001c4db3db2c",
                                 @"major":@(theMaj),
                                 @"minor":@(theMin)
                                 };
            [sigParam addObject: sigTemp];
 
        }
        NSArray* datetimeSigsParam= @{
                                      @"datetime": theTimeStamp,
                                      @"signal_array": sigParam
                                      };
        
        [dtSigs addObject:datetimeSigsParam];
        //beaconParamForApi = dtSigs;  
    }
   
    NSArray *debugArray = mutArrofSubarr;
    NSLog(@"mutArrofSubarr(total beacons): %@",debugArray);
    
    beaconParamForApi = dtSigs;
    NSLog(@"beaconParamForApi: %@",beaconParamForApi);
 
   //send json  request to location api via apigee
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"osver": osver,
                                 @"model": model,
                                 @"phone_id":phone_id,
                                 @"soinn_name":soinn_name,
                                 @"soinn_sec_range":[NSNumber numberWithInt:[_soinn_sec_range intValue]],
                                 @"signals_array":beaconParamForApi,
                                 @"x":correctedXCoordString,
                                 @"y":correctedYCoordString
                                 };
    
    
     NSLog(@"parameters: %@", parameters);
    
    //log request body
   // [loggedData appendFormat:@"Request Body:\n%@,%@,%@,%@,%@,%@,%@,%@\n",osver,model,phone_id,soinn_name,[_soinn_sec_range stringValue],beaconParamForApi,correctedXCoordString,correctedYCoordString];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:learnXYApiRequestUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        //NSArray* responseArray = responseObject;
        
        NSString* status = responseObject[@"status"];
        NSString* message = responseObject[@"message"];
        
        NSLog(@"%@", status);
        
        if ([status isEqualToString:@"success"]) {
            NSString* messageAndCorrectedXY =[message stringByAppendingFormat:@"%@, learned x: %@, learned y: %@", message,correctedXCoordString,correctedYCoordString];
            
            // double errorSabun = [self soinnCalculateCoordinateErrorFor:[_correctedXCoordinate doubleValue] withValue:[_correctedYCoordinate doubleValue] andValue:predictedX andValue:predictedY];
            
            //log response body
            //[loggedData appendFormat:@"Learned XY:%f,%f\nCoordinate error difference:%f\nResponse Body:\n%@,%@\n",[_correctedXCoordinate doubleValue], [_correctedYCoordinate doubleValue], theErrorDiff,status,messageAndCorrectedXY];
            
            NSString* apiCalled = @"learnxy";
            
            //log body
            [loggedData appendFormat:@"%@,%@,,,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n\n",currentTimeStamp,apiCalled,correctedXCoordString,correctedYCoordString,[NSNumber numberWithInt:[_soinn_sec_range intValue]],osver,model,phone_id,soinn_name,beaconParamForApi,message,[NSString stringWithFormat:@"%f",theErrorDiff]];
            
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:status
                                                            message:messageAndCorrectedXY
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            

            
        }
        else{
    
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:status
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
        }
        
         
        

    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"HTTP Request Error: %@", error);
    }];


}
//////////////////////////////////////////////////////////
-(void)callPredictApi{
    [loggedData setString:@""];
    NSString *predictApiRequestUrl = @"http://153.149.174.102/predict";
    
    //device information
    UIDevice *device = [UIDevice currentDevice];
    NSString *osver= device.systemVersion;
    NSString *model = device.model;
    NSString *phone_id = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *soinn_name = [self machineName];
    
    
    //current time for saving data to .txt file
    NSString *currentTimeStamp;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    currentTimeStamp = [dateFormatter stringFromDate:now];

    //prep data to be saved
    //[loggedData appendFormat:@"API: Predict\nTime called:%@\n",currentTimeStamp];
    
    NSMutableArray* dtSigs = [NSMutableArray array];
    NSArray *beaconParamForApi = [NSArray array];
    for (int i= 0; i<[_soinn_sec_range intValue]; i++){
        if(i>=mutArrofSubarr.count) break;
        NSArray *subArray = mutArrofSubarr[i];
        NSString *theTimeStamp =@"";
        NSMutableArray *sigParam = [NSMutableArray array];
        
        for(int j =0; j< subArray.count; j++){
            Beacons * b= subArray[j];
            if(![theTimeStamp isEqualToString:b.timeStamp]){
                theTimeStamp = [NSString stringWithString:b.timeStamp];
            }
            int theRssi =[b.rssi intValue];
            int theMaj= [b.major intValue];
            int theMin= [b.minor intValue];
            NSArray* sigTemp = @{
                                 @"rssi":@(theRssi),
                                 @"uuid":@"00000000-8e5b-1001-b000-001c4db3db2c",
                                 @"major":@(theMaj),
                                 @"minor":@(theMin)
                                 };
            [sigParam addObject: sigTemp];
            
        }
        NSArray* datetimeSigsParam= @{
                                      @"datetime": theTimeStamp,
                                      @"signal_array": sigParam
                                      };
        
        [dtSigs addObject:datetimeSigsParam];
        //beaconParamForApi = dtSigs;
    }
    
    
    
    NSArray *debugArray = mutArrofSubarr;
    NSLog(@"mutArrofSubarr(total beacons): %@",debugArray);
    
    beaconParamForApi = dtSigs;
    NSLog(@"beaconParamForApi: %@",beaconParamForApi);
    
    
    //send json  request to location api via apigee
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"osver": osver,
                                 @"model": model,
                                 @"phone_id":phone_id,
                                 @"soinn_name":soinn_name,
                                 @"soinn_sec_range":[NSNumber numberWithInt:[_soinn_sec_range intValue]],
                                 @"signals_array":beaconParamForApi
                                 };
    
    NSLog(@"JSON Request: %@", parameters);
    //log request body
    //[loggedData appendFormat:@"Request Body:\n%@,%@,%@,%@,%@,%@\n",osver,model,phone_id,soinn_name,[_soinn_sec_range stringValue],beaconParamForApi];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:predictApiRequestUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON Response: %@", responseObject);
        
        //NSArray* responseArray = responseObject;
        
        NSString* status = responseObject[@"status"];
        NSString* message = responseObject[@"message"];
        NSString* x = responseObject[@"x"];
        NSString* y= responseObject[@"y"];
        
        double predX = [x doubleValue];
        double predY= [y doubleValue];
        predictedX = predX;
        predictedY = predY;
        
        NSLog(@"%@", status);
        
        if ([status isEqualToString:@"success"]) {
            NSString *messageAndXY = [message stringByAppendingFormat:@"%@, x:%@, y%@", message,x,y];
            
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:status
                                                            message:messageAndXY
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
            NSString *correctedXCoordString = [_correctedXCoordinate stringValue];
            NSString *correctedYCoordString = [_correctedYCoordinate stringValue];
            
            
            
            //Map update
            // Remove old red circles on screen
            NSArray *subviews = [_predMapImageView subviews];
            for (UIView *view in subviews) {
                [view removeFromSuperview];
            }
            
            double predPtX = predX/(FLOOR_PLAN_HEIGHT/_predMapImageView.frame.size.height);
            double predPtY = predY/(FLOOR_PLAN_WIDTH/_predMapImageView.frame.size.width);
            
            // Draw a square where the touch occurred; MAP IS SIDEWAYS ON PHONE SO X AND Y ARE DIFFERENT
            predictedXPixDim = predPtY;
            predictedYPixDim = predPtX;
            
            UIView *predPointView = [[UIView alloc] init];
            [predPointView setBackgroundColor:[UIColor redColor]];
            predPointView.frame = CGRectMake(predPtY, predPtX, 3, 3);
            [_predMapImageView addSubview:predPointView];
            
            [_predictedCoordLabel setText:[NSString stringWithFormat:@"predicted x: %f predicted y: %f\nx: %@  y: %@", predictedX, predictedY, _correctedXCoordinate, _correctedYCoordinate]] ;
            //[_predictedCoordLabel sizeToFit];
            
            //double errorSabun = [self soinnCalculateCoordinateErrorFor:[_correctedXCoordinate doubleValue] withValue:[_correctedYCoordinate doubleValue] andValue:predictedX andValue:predictedY];
            
            //log response body
          //  [loggedData appendFormat:@"Learned XY:%f,%f\nCoordinate error difference:%f\nResponse Body:\n%@,%@\n",[_correctedXCoordinate doubleValue], [_correctedYCoordinate doubleValue],theErrorDiff,status,messageAndXY];
            
            NSString* apiCalled = @"predict";
            
            //log body
           [loggedData appendFormat:@"%@,%@,%f,%f,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n\n",currentTimeStamp,apiCalled,predictedX,predictedY,correctedXCoordString,correctedYCoordString,[NSNumber numberWithInt:[_soinn_sec_range intValue]],osver,model,phone_id,soinn_name,beaconParamForApi,message,[NSString stringWithFormat:@"%f",theErrorDiff]];
            //log body
            //[loggedData appendFormat:@"%@,%@,,,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n\n",currentTimeStamp,apiCalled,correctedXCoordString,correctedYCoordString,[NSNumber numberWithInt:[_soinn_sec_range intValue]],osver,model,phone_id,soinn_name,beaconParamForApi,message,[NSString stringWithFormat:@"%f",theErrorDiff]];



            
        }
        else{
            
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:status
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
        }
        
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"HTTP Request Error: %@", error);
          }];
 
}

///////////////////////////////////////////////////////////////////
-(void)callLearnApi{
    [loggedData setString:@""];
    NSString *learnApiRequestUrl = @"http://153.149.174.102/learn";
    
    //device information
    UIDevice *device = [UIDevice currentDevice];
    NSString *osver= device.systemVersion;
    NSString *model = device.model;
    NSString *phone_id = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *soinn_name = [self machineName];
    
    NSString *correctedXCoordString = [_correctedXCoordinate stringValue];
    NSString *correctedYCoordString = [_correctedYCoordinate stringValue];
    
    //current time for saving data to .txt file
    NSString *currentTimeStamp;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    currentTimeStamp = [dateFormatter stringFromDate:now];
    
    //prep data to be saved
    //[loggedData appendFormat:@"API: Learn\nTime called:%@\n",currentTimeStamp];
    
    NSMutableArray* dtSigs = [NSMutableArray array];
    NSArray *beaconParamForApi = [NSArray array];
    for (int i= 0; i<[_soinn_sec_range intValue]; i++){
        if(i>=mutArrofSubarr.count) break;
        NSArray *subArray = mutArrofSubarr[i];
        NSString *theTimeStamp =@"";
        NSMutableArray *sigParam = [NSMutableArray array];
        
        for(int j =0; j< subArray.count; j++){
            Beacons * b= subArray[j];
            if(![theTimeStamp isEqualToString:b.timeStamp]){
                theTimeStamp = [NSString stringWithString:b.timeStamp];
            }
            int theRssi =[b.rssi intValue];
            int theMaj= [b.major intValue];
            int theMin= [b.minor intValue];
            
            NSArray* sigTemp = @{
                                 @"rssi":@(theRssi),
                                 @"uuid":@"00000000-8e5b-1001-b000-001c4db3db2c",
                                 @"major":@(theMaj),
                                 @"minor":@(theMin)
                                 };
            [sigParam addObject: sigTemp];
            
        }
        NSArray* datetimeSigsParam= @{
                                      @"datetime": theTimeStamp,
                                      @"signal_array": sigParam
                                      };
        
        [dtSigs addObject:datetimeSigsParam];
        //beaconParamForApi = dtSigs;
    }
    
    
    
    NSArray *debugArray = mutArrofSubarr;
    NSLog(@"mutArrofSubarr(total beacons): %@",debugArray);
    
    beaconParamForApi = dtSigs;
    
    NSLog(@"beaconParamForApi: %@",beaconParamForApi);
    
    
    //send json  request to location api via apigee
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"osver": osver,
                                 @"model": model,
                                 @"phone_id":phone_id,
                                 @"soinn_name":soinn_name,
                                 @"soinn_sec_range":[NSNumber numberWithInt:[_soinn_sec_range intValue]],
                                 @"signals_array":beaconParamForApi
                                 };
    
    //log request body
    //[loggedData appendFormat:@"Request Body:\n%@,%@,%@,%@,%@,%@\n",osver,model,phone_id,soinn_name,[_soinn_sec_range stringValue],beaconParamForApi];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:learnApiRequestUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        //NSArray* responseArray = responseObject;
        
        NSString* status = responseObject[@"status"];
        NSString* message = responseObject[@"message"];
        
        NSLog(@"%@", status);
        
        //double errorSabun = [self soinnCalculateCoordinateErrorFor:[_correctedXCoordinate doubleValue] withValue:[_correctedYCoordinate doubleValue] andValue:predictedX andValue:predictedY];
        
        //log response body
        //[loggedData appendFormat:@"Learned XY:%f,%f\nCoordinate error difference:%f\nResponse Body:\n%@,%@\n",[_correctedXCoordinate doubleValue], [_correctedYCoordinate doubleValue],theErrorDiff,status,message];
        
        if ([status isEqualToString:@"success"]) {
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:status
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
            NSString* apiCalled = @"learn";
            
            //log body
            //[loggedData appendFormat:@"%@,%@,,,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n\n",currentTimeStamp,apiCalled,_correctedXCoordinate,_correctedYCoordinate,[NSNumber numberWithInt:[_soinn_sec_range intValue]],osver,model,phone_id,soinn_name,beaconParamForApi,message,[NSString stringWithFormat:@"%f",theErrorDiff]];
             [loggedData appendFormat:@"%@,%@,,,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n\n",currentTimeStamp,apiCalled,correctedXCoordString,correctedYCoordString,[NSNumber numberWithInt:[_soinn_sec_range intValue]],osver,model,phone_id,soinn_name,beaconParamForApi,message,[NSString stringWithFormat:@"%f",theErrorDiff]];
            

            
            
        }
        else{
            
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:status
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            int duration = 2; // duration in seconds
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
        }
        
        
        
        
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"HTTP Request Error: %@", error);
          }];
    
    
}



///////////////////////////////////////////////////////////
//output nslog to text file in Documents folder in app
void logThisPrediction(NSString* Msg, NSString *logFileName)
{
    NSArray* findingMachine = [Msg componentsSeparatedByString:@"%"];
    NSString* outputString = [NSString stringWithString:[findingMachine objectAtIndex:0]];
    va_list argptr;
    // va_start(argptr, Msg);
    
    for(int i = 1; i < [findingMachine count]; i++) {
        if ([[findingMachine objectAtIndex:i] hasPrefix:@"i"]||[[findingMachine objectAtIndex:i] hasPrefix:@"d"]) {
            int argument = va_arg(argptr, int); /* next Arg */
            outputString = [outputString stringByAppendingFormat:@"%i", argument];
            NSRange range;
            range.location = 0;
            range.length = 1;
            NSString* tmpStr = [[findingMachine objectAtIndex:i] stringByReplacingCharactersInRange:range withString:@""];
            outputString = [outputString stringByAppendingString:tmpStr];
        }
        else if ([[findingMachine objectAtIndex:i] hasPrefix:@"@"]) {
            id argument = va_arg(argptr, id);
            // add argument and next patr of message
            outputString = [outputString stringByAppendingFormat:@"%@", argument];
            NSRange range;
            range.location = 0;
            range.length = 1;
            NSString* tmpStr = [[findingMachine objectAtIndex:i] stringByReplacingCharactersInRange:range withString:@""];
            outputString = [outputString stringByAppendingString:tmpStr];
        }
        else if ([[findingMachine objectAtIndex:i] hasPrefix:@"."]) {
            double argument = va_arg(argptr, double);
            // add argument and next patr of message
            outputString = [outputString stringByAppendingFormat:@"%f", argument];
            NSRange range;
            range.location = 0;
            range.length = 3;
            NSString* tmpStr = [[findingMachine objectAtIndex:i] stringByReplacingCharactersInRange:range withString:@""];
            outputString = [outputString stringByAppendingString:tmpStr];
        }
        else if ([[findingMachine objectAtIndex:i] hasPrefix:@"f"]) {
            double argument = va_arg(argptr, double);
            // add argument and next patr of message
            outputString = [outputString stringByAppendingFormat:@"%f", argument];
            NSRange range;
            range.location = 0;
            range.length = 1;
            NSString* tmpStr = [[findingMachine objectAtIndex:i] stringByReplacingCharactersInRange:range withString:@""];
            outputString = [outputString stringByAppendingString:tmpStr];
        }
        else {
            outputString = [outputString stringByAppendingString:@"%"];
            outputString = [outputString stringByAppendingString:[findingMachine objectAtIndex:i]];
        }
    }
    //  va_end(argptr);
    //NSString * logFileNme= logFileName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *  filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:logFileName];
    NSError* theError = nil;
    NSString * fileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&theError];
    if (theError != nil||[fileString length]==0) {
        fileString = @"";
    }
    //fileString = [fileString stringByAppendingFormat:@"\n%@",outputString];
    fileString = [fileString stringByAppendingFormat:@"%@",outputString];
    if(![fileString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&theError])
    {
        NSLog(@"Logging problem");
    }
    
    NSLog(@"%@",outputString);
    //fileNumber++;
}

////////////////////////////////////////////////////////////////////
/**
 calls algorithm api to predict location
 */

-(NSString*) predictLocationWithAlgo: (NSMutableArray*) beaconArr
{
    NSMutableArray *bArray = beaconArr;
    NSMutableString *parameters = [NSMutableString string];
    NSString *locationApiRequest = @"http://test-iac.smp.apigw.net/locationapi?";
    
    NSString *username =@"inoue";
    NSString* output = [NSString string];
    algoPredictedLocationResponse = [NSArray array];
    NSString* algoPredX= [NSString string];
    NSString* algoPredY= [NSString string];
    NSString* errorFlag = [NSString string];
    
    
    NSArray *beaconParamForApi = [NSArray array];
    for (int i= 0; i< [_soinn_sec_range intValue]; i++){
        if(i>=bArray.count) break;
        NSArray *subArray = bArray[i];
        NSString *theTimeStamp =@"";
        
        for(int j =0; j< subArray.count; j++){
            Beacons * b= subArray[j];
            if(![theTimeStamp isEqualToString:b.timeStamp]){
                theTimeStamp = [NSString stringWithString:b.timeStamp];
            }
            int theRssi =[b.rssi intValue];
            int theMaj= [b.major intValue];
            int theMin= [b.minor intValue];
            [parameters appendFormat:@"%d%d=%d&",theMaj,theMin,theRssi];
            
        }
    }
    
    [parameters appendFormat:@"username=%@",username];
    locationApiRequest = [locationApiRequest stringByAppendingFormat:@"%@",parameters];
    
    //send json  request to location api via apigee
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:locationApiRequest parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        // NSArray *responseArray = responseObject;
        algoPredictedLocationResponse = responseObject;
        
        NSString *x = [NSString stringWithFormat:@"%@,",algoPredictedLocationResponse[0]];
        [algoPredX stringByAppendingString:x];
        NSString *y = [NSString stringWithFormat:@"%@,",algoPredictedLocationResponse[1]];
        [algoPredY stringByAppendingString:y];
        [output stringByAppendingFormat:@"%@,%@",x,y];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSString *s = [NSString stringWithFormat:@"error: %@",error];
        [output stringByAppendingFormat:@"%@",s];
        [errorFlag stringByAppendingString:@"true"];
        
    }];
    
    if(![errorFlag isEqualToString:@"true"]){
       // double errorSabun = [self soinnCalculateCoordinateErrorFor:[_correctedXCoordinate doubleValue] withValue:[_correctedYCoordinate doubleValue] andValue:predictedX andValue:predictedY];
        [_predictedCoordLabel setText:[NSString stringWithFormat:@"predicted x: %@ predicted y: %@\nx: %@  y: %@, error: %f", algoPredX, algoPredY, _correctedXCoordinate, _correctedYCoordinate,theErrorDiff]];
        
        double predPtX = [algoPredX doubleValue]/(FLOOR_PLAN_HEIGHT/_predMapImageView.frame.size.height);
        double predPtY = [algoPredY doubleValue]/(FLOOR_PLAN_WIDTH/_predMapImageView.frame.size.width);
        
        // Draw a square where the touch occurred; MAP IS SIDEWAYS ON PHONE SO X AND Y ARE DIFFERENT
        predictedXPixDim = predPtY;
        predictedYPixDim = predPtX;
        
        UIView *predPointView = [[UIView alloc] init];
        [predPointView setBackgroundColor:[UIColor yellowColor]];
        predPointView.frame = CGRectMake(predPtY, predPtX, 6, 6);
        [_predMapImageView addSubview:predPointView];
        
        [_predictedCoordLabel setText:[NSString stringWithFormat:@"algo x: %f algo y: %f\nx: %@  y: %@", predictedX, predictedY, _correctedXCoordinate, _correctedYCoordinate]] ;
        //[_predictedCoordLabel sizeToFit];
    }
    
    return  [NSString stringWithFormat:@"%@",output];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end

