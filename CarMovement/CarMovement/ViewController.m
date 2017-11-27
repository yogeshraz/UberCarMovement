//
//  ViewController.m
//  CarMovement
//
//  Created by Yogesh Raj on 11/27/17.
//  Copyright © 2017 Yogesh Raj. All rights reserved.
//

#import "ViewController.h"
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@interface ViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
    
    //set old coordinate
    //
    self.oldCoordinate = CLLocationCoordinate2DMake(37.708800859999997,-122.46812260999999);
    
    // Create a GMSCameraPosition that tells the map to display the marker
    //
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.708800859999997
                                                            longitude:-122.46812260999999
                                                                 zoom:2];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = NO;
    self.mapView.settings.rotateGestures = NO;
    self.mapView.delegate = self;
    self.view = self.mapView;
    
    // Creates a marker in the center of the map.
    //
    driverMarker = [[GMSMarker alloc] init];
    driverMarker.position = self.oldCoordinate;
    driverMarker.icon = [UIImage imageNamed:@"car"];
    driverMarker.map = self.mapView;
}

#pragma mark - Car Movement
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [self RZCarMovement:driverMarker OldCoordinate:_oldCoordinate NewCoordinate:manager.location.coordinate Map:self.mapView Bearing:0];  //instead value 0, pass latest bearing value from backend
    
    self.oldCoordinate = manager.location.coordinate;
}


-(void)RZCarMovement:(GMSMarker *)marker OldCoordinate:(CLLocationCoordinate2D )oldCoordinate NewCoordinate:(CLLocationCoordinate2D )newCoordinate Map:(GMSMapView *)mapView Bearing:(float )bearing
{
    CGFloat calBearing = [self getHeadingForDirectionFromCoordinate:oldCoordinate toCoordinate:newCoordinate];
    CLLocationDegrees degrees = calBearing;
    marker.groundAnchor = CGPointMake(0.5, .05);
    marker.rotation = degrees;
    marker.position = oldCoordinate;
    
    //marker movement animation
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
        driverMarker.groundAnchor = CGPointMake(0.5, 0.5);
        driverMarker.rotation = degrees; //New bearing value from backend after car movement is done
    }];
    
    driverMarker.position = newCoordinate; //this can be new position after car moved from old position to new position with animation
    driverMarker.map = mapView;
    driverMarker.groundAnchor = CGPointMake(0.5, 0.5);
    driverMarker.rotation = [self getHeadingForDirectionFromCoordinate:oldCoordinate toCoordinate:newCoordinate]; //found bearing value by calculation
    [CATransaction commit];
    
    [self RZCarMovementMoved:marker];
    
    marker.position = newCoordinate;
    marker.rotation = calBearing;
}

#pragma mark Get Direction
- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

#pragma mark - RZCarMovementDelegate
- (void)RZCarMovementMoved:(GMSMarker * _Nonnull)Marker {
    driverMarker = Marker;
    driverMarker.map = self.mapView;
    
    //animation to make car icon in center of the mapview
    //
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:driverMarker.position zoom:17.5f];
    [self.mapView animateWithCameraUpdate:updatedCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
