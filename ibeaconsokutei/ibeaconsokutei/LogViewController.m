//
//  LogViewController.m
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 6/19/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import "LogViewController.h"
#import "ViewController.h"
#import "PredLocMapViewController.h"
#import <AdSupport/ASIdentifierManager.h>
#import <AFHTTPRequestOperationManager.h>

@interface LogViewController ()

@end

@implementation LogViewController

NSString *txtFileData=@"";
NSMutableString *txtFileMutable ;
NSString *beaconData =@"";
NSString *beaconDataLogOutput =@"";

NSString *uuid=@"00000000-8e5b-1001-b000-001c4db3db2c";
NSMutableArray* beaconArrayObj;
NSMutableArray* mutSubArrBeaconCopy;
NSMutableArray* soinnBeaconArrData;

NSMutableArray* medianBeaconArrayObj;
NSString *predictedLocation=@"";
NSArray *predictedLocationArr;

NSMutableString *outputPredLoc;

int soinnFlag =0;
int secondsRange;



//int fileNumber = 0; //for creating seperate log text files

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //NSMutableString *beaconDataMutable = [beaconData mutableCopy];
    
    [super viewDidLoad];
    soinnFlag = 0;
    // Do any additional setup after loading the view.
    
    outputPredLoc=[NSMutableString string];
    
    //split beacon data in string
    NSArray* beaconArrayString = [_logText componentsSeparatedByString:@"|"];
    
    //if no beacon data in array
    if ([beaconArrayString[0]isEqualToString:@""]) {
        _logTextView.text =@"No recorded iBeacons";
        
    }
    
    //if beacon data is found
    else{
        
         beaconArrayObj=[[NSMutableArray alloc] init];
         medianBeaconArrayObj=[[NSMutableArray alloc] init];
         predictedLocationArr =[[NSArray alloc] init];
        
        
        //last string in beaconArrayString is null; not including it in beacon object array
        for (int i=0; i<beaconArrayString.count-1; i++) {
            NSArray *beaconInfo = [beaconArrayString[i] componentsSeparatedByString:@","];
            //Beacons *b = [[Beacons alloc]initWithMinor:beaconInfo[1] Rssi:beaconInfo[2] Major:beaconInfo[0]];
            NSNumber *mjor = [NSNumber numberWithInt:[beaconInfo[0] intValue]];
            NSNumber *mnor = [NSNumber numberWithInt:[beaconInfo[1] intValue]];
            NSNumber *rssi = [NSNumber numberWithInt:[beaconInfo[2] intValue]];
            NSNumber *accuracy =[NSNumber numberWithInt:[beaconInfo[3] intValue]];
            NSString *timeStamp =beaconInfo[4];
            
            
            NSNumber *zero;
            zero=[NSNumber numberWithInt: 0];
            
            if (rssi == zero) {
                rssi = [NSNumber numberWithInt:-100];
                Beacons *b = [[Beacons alloc]initWithMajor:mjor Minor:mnor Rssi:rssi Accuracy:accuracy TimeStamp:timeStamp];
                beaconArrayObj[i] =b;
            }
            else{
                Beacons *b = [[Beacons alloc]initWithMajor:mjor Minor:mnor Rssi:rssi Accuracy:accuracy TimeStamp:timeStamp];
                beaconArrayObj[i] =b;
            }
        }
        
        //sorting for beacons
        NSSortDescriptor *major = [NSSortDescriptor sortDescriptorWithKey:@"major" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *minor = [NSSortDescriptor sortDescriptorWithKey:@"minor" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *rssi = [NSSortDescriptor sortDescriptorWithKey:@"rssi" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *timeSorting = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES selector:@selector(compare:)];
       
        
        NSArray *descriptors = @[major, minor, timeSorting];
        //NSArray *descriptors = @[timeSorting];
        [beaconArrayObj sortUsingDescriptors:descriptors];
        
        //debug purposes only
        for(int i=0; i<beaconArrayObj.count; i++){
            Beacons *b = beaconArrayObj[i];
           // NSLog(@"%@,%@,%@\n", b.major, b.minor, b.rssi);
        }
        
        //NSLog(@"%@", beaconArrayObj);
        
   
        // Array to hold subbeacon array and separate beacons based on minor
        NSMutableArray *mutableArrayOfSubarrays = [NSMutableArray array];
       // NSUInteger length = [beaconArrayObj count];
        NSUInteger location = 0;
        NSNumber *bMinor;
        NSNumber *cMinor;
        NSNumber *bMajor;
        NSNumber *cMajor;
        
     
        int j = 1;//comparison beacon incrementer
        for (int i =0; i<beaconArrayObj.count; i++) {
            if (j==beaconArrayObj.count) {
                [mutableArrayOfSubarrays addObject:[beaconArrayObj subarrayWithRange:NSMakeRange(location, j-location)]];
                break;
            }
            else{
                Beacons *beacon= beaconArrayObj[i];
                Beacons *compareBeacon = beaconArrayObj[j];
                bMajor = beacon.major;
                cMajor = compareBeacon.major;
                bMinor = beacon.minor;
                cMinor = compareBeacon.minor;

                if ([bMajor isEqualToNumber: cMajor] && [bMinor isEqualToNumber: cMinor]) {
                    //keep reading
                }
                
                else{
                    [mutableArrayOfSubarrays addObject:[beaconArrayObj subarrayWithRange:NSMakeRange(location, j-location)]];
                    int temp = j;
                    location = temp;
                    /*
                    if(i==0){
                        location = temp+1;
                    }
                    else{
                        location = temp;
                    }
                     */
                }//endelse
                
            }//end else
            j++;//increment beacon to compare one beacon ahead
        }//end for
        
        
        /*
        for(int i=0; i<mutableArrayOfSubarrays.count; i++){
            NSLog(@"%s\n","New Sub Array");
            NSMutableArray *sub = mutableArrayOfSubarrays[i];
            for (int j =0; j<sub.count; j++) {
                Beacons *b = sub[i];
                NSLog(@"%@,%@,%@\n",b.major, b.minor, b.rssi);
            }
           NSLog(@"%s\n\n"," ");
        }
        */
        
        //mutablestring for displaying beacon information on logviewcontroller textview
        NSMutableString *beaconDataMutable = [beaconData mutableCopy];
        
        //for log output file
        NSMutableString *beaconDataLogOutputMutable = [beaconDataLogOutput mutableCopy];
        
        //clear screen on each view log
        if (![beaconDataMutable isEqual:@""]) {
            [beaconDataMutable setString:@""];
        }
        /*
        for (int i=0; i<beaconArrayObj.count; i++) {
            Beacons *eachBeacon = beaconArrayObj[i];
            beaconData = [beaconData stringByAppendingFormat:@"major :%@, ", eachBeacon.major];
            beaconData = [beaconData stringByAppendingFormat:@"minor: %@, rssi: %@ \n", eachBeacon.minor, eachBeacon.rssi];
            //beaconData = [beaconData stringByAppendingString:@"\n"];
        }
      */
        
        //write to text file with timestamp and coordinates
        /*NSString *timeStamp;
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        timeStamp = [dateFormatter stringFromDate:now];
         */
        
        
        //device and os info
        UIDevice *device = [UIDevice currentDevice];
        
        //int middleBeaconArrayObjCounter = 0;
        //get and print middle value
        for (int i=0; i<mutableArrayOfSubarrays.count; i++) {
            NSMutableArray *subArray = [mutableArrayOfSubarrays objectAtIndex:i];
            //int middle = lroundf((subArray.count/2));
            //Beacons *middleBeacon = subArray[middle];
            /*
            beaconDataMutable = [beaconDataMutable stringByAppendingString:@"Middle Beacon: \n"];
            beaconDataMutable = [beaconDataMutable stringByAppendingFormat:@"major: %@, ", middleBeacon.major];
            beaconDataMutable = [beaconDataMutable stringByAppendingFormat:@"minor: %@, rssi: %@ \n\n", middleBeacon.minor, middleBeacon.rssi];
             */
           // [beaconDataMutable appendString:@"Middle Beacon: \n"];
           // [beaconDataMutable appendFormat:@"major: %@, ", middleBeacon.major];
            //[beaconDataMutable appendFormat:@"minor: %@, rssi: %@ \n\n", middleBeacon.minor, middleBeacon.rssi];
            
           // medianBeaconArrayObj[middleBeaconArrayObjCounter] = middleBeacon;
           // middleBeaconArrayObjCounter++;
         
            //print beacon list
           // [beaconDataMutable appendString:@"Beacon list: \n"];
            for (int j = 0; j<subArray.count; j++) {
                Beacons *eachBeacon =subArray[j];
               // [beaconDataMutable appendFormat:@"major :%@, ", eachBeacon.major];
           //     [beaconDataMutable appendFormat:@"minor: %@, rssi: %@ \n", eachBeacon.minor, eachBeacon.rssi];
                
                
                NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                //output for log file
                [beaconDataLogOutputMutable appendFormat:@"%@,%@,%@,%@,%@,%@,%@,%@\n",eachBeacon.timeStamp,device.systemVersion,device.model ,adId,eachBeacon.rssi,uuid,eachBeacon.major,eachBeacon.minor];
                
            }
            
            //line breaks for easier reading
           // [beaconDataMutable appendString:@"\n"];
        }
        //predictLocation(medianBeaconArrayObj);
        
        //[beaconDataMutable appendString:@"\n"];//line break for each 測定箇所
        //[beaconDataMutable appendString:@"\n"];//line break for each 測定箇所
        
        NSLog(@"mutableSubArray: %@", mutableArrayOfSubarrays);
        mutSubArrBeaconCopy =mutableArrayOfSubarrays;
      
        beaconData = beaconDataMutable;
        beaconDataLogOutput = beaconDataLogOutputMutable;
        
        //print out beacon information to log text view
        //_logTextView.text = beaconDataMutable;
        _logTextView.text = beaconDataLogOutputMutable;
        
        /*
        //write to text file with timestamp and coordinates
        NSString *timeStamp;
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        timeStamp = [dateFormatter stringFromDate:now];
         */
        
        txtFileMutable = [txtFileData mutableCopy];
        
        
        //11/11/14 COORDINATE INFO HERE!!!
        //[txtFileMutable appendString:timeStamp];
        //[txtFileMutable appendString:@"\n\n"];
        //[txtFileMutable appendFormat:@"Timer (sec): %@, One reading per %@ sec(s)\n\n", _timerTime, _readingInterval];
        //[txtFileMutable appendFormat:@"x: %@, y: %@ \n\n", _coordinateTextX, _coordinateTextY];
        //[txtFileMutable appendString:beaconData];
        
        
        [txtFileMutable appendString:beaconDataLogOutput];
        [beaconDataLogOutputMutable setString:@""];
        
        //txtFileData = txtFileMutable;
        
        /*
        txtFileData =[[timeStamp stringByAppendingString:@"\n\n"] stringByAppendingFormat:@"Timer duration: %@, Reading interval: %@ \n\n", _timerTime, _readingInterval];
        
        txtFileData = [txtFileData stringByAppendingFormat:@"x: %@, y: %@ \n\n", _coordinateTextX, _coordinateTextY];


       // NSString *txtFileData =[[timeStamp stringByAppendingString:@"\n\n"] stringByAppendingFormat:@"x: %@, y: %@ \n\n", _coordinateTextX, _coordinateTextY];
 
        
        
        txtFileData = [txtFileData stringByAppendingString:beaconData];
        */
        
        //write to text file
        //logThis(txtFileData);
        //logThis(beaconData);
        
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//////////////////////////////////////////////////
//send data to soinn learn ap

- (IBAction)sendLocationDataSoinnLearnXY:(id)sender {
    soinnFlag = 1;
    //display location information via alert message
    NSString *alertMessage = [NSString stringWithFormat:@"Select Second Range"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOINN"
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"1 second", @"3 seconds", @"5 seconds", @"10 seconds", nil];
    [alert show];

}

//////////////////////////////////////////////////
//send data to soinn predict api

- (IBAction)sendLocationDataForSoinnPredict:(id)sender {
    soinnFlag = 2;
    //display location information via alert message
    NSString *alertMessage = [NSString stringWithFormat:@"Select Second Range"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOINN"
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"1 second", @"3 seconds", @"5 seconds", @"10 seconds", nil];
    [alert show];
    
}


//////////////////////////////////////////////////

//predict location using algorithm
//parameters: NSMutable ArrayList
void predictLocation(NSMutableArray* beaconArr){
    
    NSMutableArray *bArray = beaconArr;
    NSMutableString *parameters = [NSMutableString string];
    NSString *locationApiRequest = @"http://test-iac.smp.apigw.net/locationapi?";
   
    NSString *username =@"inoue";
    
    
   // NSDictionary *parametersDict = [NSString string];
    
    //[parameters appendString:@"{"];
    for (int i =0; i<bArray.count; i++) {
        Beacons *beacon= bArray[i];
        [parameters appendFormat:@"%@%@=%@&",beacon.major,beacon.minor,beacon.rssi];
        //parametersDict
    }
    
    [parameters appendFormat:@"username=%@",username];
    locationApiRequest = [locationApiRequest stringByAppendingFormat:@"%@",parameters];
    
   
    //send json  request to location api via apigee
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:locationApiRequest parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
       // NSArray *responseArray = responseObject;
        predictedLocationArr = responseObject;
        
        NSString *s = [NSString stringWithFormat:@"predicted x: %@, predicted y: %@",predictedLocationArr[0],predictedLocationArr[1]];
        //[predictedLocation appendFormat:@"%@",s];
        //[predictedLocation stringByAppendingString:s];
        predictedLocation = s;
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
  //  NSLog(@"%@", predictedLocation);
    
    //return predictedLocation;
}
//////////////////////////////////////////////////
-(double)calculateCoordinateErrorFor:(double) tx withValue: (double)ty andValue: (double) px andValue: (double) py{
    double tappedX = tx;
    double tappedY = ty;
    double predictedX = px;
    double predictedY = py;
    double result = ((predictedX-tappedX)*(predictedX-tappedX))+((predictedY-tappedY)*(predictedY-tappedY));
    return sqrt(result);
}


//////////////////////////////////////////////////
//save beacon data to text file
- (IBAction)saveBeaconData:(id)sender {
    txtFileData = txtFileMutable;
    
    if(txtFileData.length==0){
        _logTextView.text = @"No beacons to save";
        //UIImage *checkmark =[UIImage imageNamed:@"x-mark.png"];
        //[_checkmarkIM setImage:checkmark];
        //display location information via alert message
        NSString *alertMessage = [NSString stringWithFormat:@"%@",@"No beacon data found"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Information"
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        

    }
    else{
        [txtFileMutable appendString:@"\n"];//add extra line break
        logThis(txtFileData,@"logFile.txt");
        //NSLog(txtFileData);
        
        
        //clear string of previous reading
        [txtFileMutable setString:@""];
         txtFileData =@"";
  
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iBeacon Information"
                                                        message:@"Beacon data saved successfully"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

/////////////////////////////////////////////////////
//alert view for saving predicted location and setting soinn second range
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    soinnBeaconArrData = [[NSMutableArray alloc] init];
   
    
    
    if([title isEqualToString:@"Save"])
    {
        logThis(outputPredLoc, @"locationLogFile.txt");
    }
    else if([title isEqualToString:@"Cancel"])
    {
        
    }
    else if([title isEqualToString:@"1 second"]){
        secondsRange =1;
        int secondsCounter= 1;
        for(int i = 0; i <[mutSubArrBeaconCopy count];i++){
            secondsCounter =1;
            NSMutableArray *subArray = [mutSubArrBeaconCopy objectAtIndex:i];
            for (int j= 0; j<subArray.count; j++ ){
                [soinnBeaconArrData addObject:subArray[j]];
                /*
                if(secondsCounter>secondsRange){
                    secondsCounter =1;
                    break;
                }
                else{
                    [soinnBeaconArrData addObject:subArray[j]];
                    secondsCounter++;
                }
                 */
 
            }
        }
        NSLog(@"soinnBeaconArrData: %@",soinnBeaconArrData);
        
        
        [self performSegueWithIdentifier:@"segue.soinnpred.alert" sender:self];
    }

    else if([title isEqualToString:@"3 seconds"]){
        secondsRange =3;
        int secondsCounter= 1;
        for(int i = 0; i <[mutSubArrBeaconCopy count];i++){
            secondsCounter =1;
            NSMutableArray *subArray = [mutSubArrBeaconCopy objectAtIndex:i];
            for (int j= 0; j<subArray.count; j++ ){
                [soinnBeaconArrData addObject:subArray[j]];
                /*
                if(secondsCounter>secondsRange){
                    secondsCounter =1;
                    break;
                }
                else{
                    [soinnBeaconArrData addObject:subArray[j]];
                    secondsCounter++;
                }
                 */
                
            }
            NSLog(@"subArr: %@",subArray);
        }
        NSLog(@"soinnBeaconArrData: %@",soinnBeaconArrData);
        
        
         [self performSegueWithIdentifier:@"segue.soinnpred.alert" sender:self];
    
    }
    else if([title isEqualToString:@"5 seconds"]){
        secondsRange =5;
        int secondsCounter= 1;
        for(int i = 0; i <[mutSubArrBeaconCopy count];i++){
            secondsCounter =1;
            NSMutableArray *subArray = [mutSubArrBeaconCopy objectAtIndex:i];
            for (int j= 0; j<subArray.count; j++ ){
                [soinnBeaconArrData addObject:subArray[j]];
                /*
                if(secondsCounter>secondsRange){
                    secondsCounter =1;
                    break;
                }
                else{
                    [soinnBeaconArrData addObject:subArray[j]];
                    secondsCounter++;
                }
                 */
                
            }
        }
        NSLog(@"soinnBeaconArrData: %@",soinnBeaconArrData);
        
        
         [self performSegueWithIdentifier:@"segue.soinnpred.alert" sender:self];
        
    }
    else if([title isEqualToString:@"10 seconds"]){
        secondsRange =10;
        int secondsCounter= 1;
        for(int i = 0; i <[mutSubArrBeaconCopy count];i++){
            secondsCounter =1;
            NSMutableArray *subArray = [mutSubArrBeaconCopy objectAtIndex:i];
            for (int j= 0; j<subArray.count; j++ ){
                [soinnBeaconArrData addObject:subArray[j]];
                /*
                if(secondsCounter>secondsRange){
                    secondsCounter =1;
                    break;
                }
                else{
                    [soinnBeaconArrData addObject:subArray[j]];
                    secondsCounter++;
                }
                 */
                
            }
        }
        NSLog(@"soinnBeaconArrData: %@",soinnBeaconArrData);
        
        
         [self performSegueWithIdentifier:@"segue.soinnpred.alert" sender:self];
    
    }
    else {}
   
}




/////////////////////////////////////////////////////
//get location data to text file
- (IBAction)savePredictLocation:(id)sender {
     //predictLocation(medianBeaconArrayObj);
   
    //if(predictedCoordinateLocation.length ==0){
    
    
    if(_predictedLocFromVC.length == 0){
    //if(predictedLocation.length ==0){
        //display x mark
       // UIImage *checkmark =[UIImage imageNamed:@"x-mark.png"];
       // [_predictCheckMarkIM setImage:checkmark];
        
        //display location information via alert message
        NSString *alertMessage = [NSString stringWithFormat:@"%@",@"Unable to predict location"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Information"
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else {
        //make timestamp
        NSString *timeStamp;
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        timeStamp = [dateFormatter stringFromDate:now];
        
        
        
        double tappedXCoord = [_coordinateTextX doubleValue];
        double tappedYCoord = [_coordinateTextY doubleValue];
        //double predictedXCoord = [predictedLocationArr[0] doubleValue];
        //double predictedYCoord = [predictedLocationArr[1]doubleValue];
        
        NSArray* plArr = [_predictedLocFromVC componentsSeparatedByString: @","];
        
        double predictedXCoord = [plArr[0] doubleValue];
        double predictedYCoord = [plArr[1]doubleValue];
        
        
        
       // double errorSabun = [self calculateCoordinateErrorFor: tappedXCoord withValue: tappedYCoord andValue: predictedXCoord andValue: predictedYCoord];
        double errorSabun = [self calculateCoordinateErrorFor: tappedXCoord withValue: tappedYCoord andValue: predictedXCoord andValue: predictedYCoord];
        
   
        // NSLog(@"%f",errorSabun);
        
        //device and os info
        UIDevice *device = [UIDevice currentDevice];
        NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        
        //[output appendFormat:@"%@,%@,%@,%@,tapped x: %@,tapped y: %@,%@,error: %f\n",timeStamp,device.systemVersion,device.model,adId,_coordinateTextX,_coordinateTextY, predictedLocation, errorSabun];
        
        [outputPredLoc appendFormat:@"%@,%@,%@,%@,tapped x: %@,tapped y: %@,predicted x: %@,predicted y: %@,error: %f\n",timeStamp,device.systemVersion,device.model,adId,_coordinateTextX,_coordinateTextY, plArr[0],plArr[1], errorSabun];
        
        [outputPredLoc appendString:@"\n"];
        
        //NSLog(@"output saved to locationLogFile: %@",outputPredLoc);
        
        //write to separate log file frome beacon data
        //logThis(output, @"locationLogFile.txt");
        
        
        //display location information via alert message
        NSString *alertMessage = [NSString stringWithFormat:@"tapped x: %@,tapped y: %@, predicted x: %@, predicted y: %@, error: %f",_coordinateTextX,_coordinateTextY, plArr[0],plArr[1],  errorSabun];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Information"
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save", nil];
        [alert show];
    }
    
    
}

///////////////////////////////////////////////////////////
//output nslog to text file in Documents folder in app
void logThis(NSString* Msg, NSString *logFileName)
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
    NSString * logFileNme= logFileName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *  filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:logFileName];
   // NSString *  filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"logFile.txt"];
    //NSString *filePath= [[paths objectAtIndex:0]stringByAppendingFormat:@"%i", fileNumber];
    //NSString *filePath =[[paths objectAtIndex:0] stringByAppendingPathComponent:@"logFile"];
    //filePath =[filePath stringByAppendingFormat:@"%i", fileNumber];
    //filePath =[filePath stringByAppendingString:@".txt"];
    
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

//segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PredLocMapViewController class]]){
        
        PredLocMapViewController *destination = [segue destinationViewController];
        destination.beaconData = soinnBeaconArrData;
        destination.learnPredictApiCallFlag= [NSNumber numberWithInt: soinnFlag];
        destination.soinn_sec_range = [NSNumber numberWithInt:secondsRange];
        //destination.tappedCoordinateX = [NSNumber numberWithDouble:[_coordinateTextX doubleValue]];
        //destination.tappedCoordinateY = [NSNumber numberWithDouble:[_coordinateTextY doubleValue]];
        /*
        if(soinnFlag==1){
            //learn
        } else if (soinnFlag ==2){
            //predict
            destination.learnPredictApiCallFlag==soinnFlag;
        }
         */
        /*
        destination.logText = appendedBeaconD;
        NSString* timeString = [NSString stringWithFormat:@"%f", timeTick];
        destination.timeAsText=timeString;
        destination.coordinateTextX = [NSString stringWithFormat:@"%f", xCoordinate];
        destination.coordinateTextY = [NSString stringWithFormat:@"%f", yCoordinate];
        
        
        //CGFloat tt =[_timerTimeFromSettings floatValue];
        CGFloat tt = originalTimerValue/1000;
        destination.timerTime = [NSString stringWithFormat:@"%f", tt];
        //CGFloat schtimerInterv = [_timeIntervalFromSettings floatValue];
        CGFloat schtimerInterv = originalRps;
        destination.readingInterval = [NSString stringWithFormat:@"%f",schtimerInterv];
        
        //destination.numOfReadings = [NSString stringWithFormat:@"%f", originalNumOfReadings];
        
        //destination.predictedLocFromVC = [self predictRealTimeLocationWithMajorMinor:tempB];
        
        
        destination.predictedLocFromVC = foundBeaconsRealTimeStr;
        
        //NSLog(@"foundBeaconsRealTimeStr: %@",foundBeaconsRealTimeStr);
        
        //  NSLog(@"predictedLocationFromMainVC string to LogVC: %@",destination.predictedLocFromVC);
         */
        
    }
  
}


/*
 - (BOOL)textView:(UITextView *)textView
 shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
 {
 if ([text isEqualToString:@"\n"])
 {
 [textView resignFirstResponder];
 }
 return YES;
 }
 
 - (IBAction)handleDoneButtonClick:(id)sender {
 // _logText = @" ";
 }
 */


@end
