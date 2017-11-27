//
//  ViewController.h
//  CarMovement
//
//  Created by Yogesh Raj on 11/27/17.
//  Copyright © 2017 Yogesh Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController : UIViewController<GMSMapViewDelegate>
{
    GMSMarker *driverMarker;
}
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property CLLocationCoordinate2D oldCoordinate;
@property(assign,nonatomic) double *lat;
@property(assign,nonatomic) double *lng;

@end

