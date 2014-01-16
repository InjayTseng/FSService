//
//  VenueMapViewController.h
//  FSQProject
//
//  Created by David Tseng on 1/16/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface VenueMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation* targetLocation;
@property (strong, nonatomic) NSArray * nearbyVenuesArray;

@end

