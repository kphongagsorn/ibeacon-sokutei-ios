//
//  MapViewController.m
//  ibeaconsokutei
//
//  Created by Phongagsorn Kevin on 10/7/14.
//  Copyright (c) 2014 Phongagsorn Kevin. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

//Tamachi 16fl dimensions in meters; adjusted to account for imageview bounds
#define FLOOR_PLAN_HEIGHT 73.05 //73.34 //82.34  //73.34 ; true dimensions : 72 m
#define FLOOR_PLAN_WIDTH 37.58 //38.726 //+ (550+600+650 mm) ; true dimensions : 37.8 m ((7200m*5)+(*550m+600m+650m))

//pinch zoom min/max sizes in pixels
#define IMAGE_MIN_SIZE 320
#define IMAGE_MAX_SIZE 4680


//NSString *appendedBeaconD =@"";
CGFloat xCGFloat = 0;
CGFloat yCGFloat = 0;
float zoomScale = 1;

UIImage *mapImg;

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // mapImg=[UIImage imageNamed:@"edit-ibeacon-map.png"];
    //mapImageView=[[UIImageView alloc]initWithImage:mapImg];
    
    //fill image view for map with map png file
    mapImageView.contentMode = UIViewContentModeScaleToFill;
    //mapImageView.clipsToBounds =YES;
    
    //mapImageView.autoresizingMask = UIViewAutoresizingNone;
    
    //border around map image
    mapImageView.layer.borderColor = [UIColor blackColor].CGColor;
    mapImageView.layer.borderWidth = 1.0f;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//hide status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}



////////////////////////////////////////////////////////////////////////
//Pinch Zoom and Pan

//Handle Pinch Zoom
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    //zoomScale = recognizer.scale;
    float adjustedXCoordinate = xCGFloat * recognizer.scale;
    float adjustedYCoordinate = yCGFloat * recognizer.scale;
    [coordinatesLabel setText:[NSString stringWithFormat:@" x: %f  y: %f", adjustedXCoordinate, adjustedYCoordinate]] ;
    
    //[coordinatesLabel setText:[NSString stringWithFormat:@" x: %@  y: %@", _xCoordinate, _yCoordinate]] ;
    
}

//Handle Pan
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}


////////////////////////////////////////////////////////////////////////
//Handle Tap

//Find and convert tapped point to corresponding map coordinates
- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    
    CGPoint tappedPoint = [recognizer locationInView:mapImageView];
    //float changeHeight = (FLOOR_PLAN_HEIGHT/mapImageView.frame.size.height);
    xCGFloat = tappedPoint.y * (FLOOR_PLAN_HEIGHT/mapImageView.frame.size.height);
    
    //NSLog(@"tappedpointX: %f", tappedPoint.x);
    //NSLog(@"%f", changeHeight);
    //CGFloat xCoordinate = mapImageView.frame.size.height;
    //float changeWidth = (FLOOR_PLAN_WIDTH/mapImageView.frame.size.width);
    //NSLog(@"%f", changeWidth);
    //NSLog(@"tappedpointY: %f", tappedPoint.y);
    
    yCGFloat = tappedPoint.x * (FLOOR_PLAN_WIDTH/mapImageView.frame.size.width);
    //CGFloat yCoordinate = mapImageView.frame.size.width;
    
    //NSLog(@"Touch Using UITapGestureRecognizer x : %f y : %f", xCoordinate, yCoordinate);
    
    _xCoordinate = [NSNumber numberWithFloat:xCGFloat];
    _yCoordinate = [NSNumber numberWithFloat:yCGFloat];
    
    [coordinatesLabel setText:[NSString stringWithFormat:@"x: %@  y: %@", _xCoordinate, _yCoordinate]] ;
    

    
    
}

//mark tapped point with red dot
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Remove old red circles on screen
    NSArray *subviews = [mapImageView subviews];
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    //Mark tapped area on map
    UITouch *touch = [touches anyObject];
    if ([touch view] == mapImageView)
    {
        // Enumerate over all the touches and draw a red dot on the screen where the touches were
        [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            // Get a single touch and it's location
            UITouch *touch = obj;
            CGPoint touchPoint = [touch locationInView: mapImageView];
            
            // Draw a red square where the touch occurred
            UIView *touchView = [[UIView alloc] init];
            [touchView setBackgroundColor:[UIColor redColor]];
            touchView.frame = CGRectMake(touchPoint.x, touchPoint.y, 6, 6);
            //touchView.layer.cornerRadius = 15;
            [mapImageView addSubview:touchView];
            //[mapScrollView addSubview: mapImageView];
            
        }];
        
    } //endif
}

/*
 //code for dragging point on map, not finished yet
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint touchPoint = [touch locationInView:mapImageView];
    current_point=[touch locationInView:mapImageView];
    
    [self DrawLine:start_point end:current_point];
    start_point=current_point;
 
    
}
-(void)DrawLine: (CGPoint)start end:(CGPoint)end{
    
    context= UIGraphicsGetCurrentContext();
    CGColorSpaceRef space_color= CGColorSpaceCreateDeviceRGB();
    CGFloat component[]={1.0,0.0,0.0,1};
    CGColorRef color = CGColorCreate(space_color, component);
    
    //draw line
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context,end.x, end.y);
    CGContextStrokePath(context);
}
 */



@end
