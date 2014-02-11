//
//  DemoViewController.m
//  FSQProject
//
//  Created by David Tseng on 2/11/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "DemoViewController.h"
#import "NearbyVenuesViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface DemoViewController ()<CLLocationManagerDelegate>
- (IBAction)btnFixedLocationClicked:(id)sender;
- (IBAction)btnCurrentLocationClicked:(id)sender;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation DemoViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnFixedLocationClicked:(id)sender {
    
    NearByVenuesViewController *nv = [self.storyboard instantiateViewControllerWithIdentifier:@"NearbyVenuesViewController"];
    
//    CLLocation *loc = [[CLLocation alloc]initWithLatitude:37.33240904999999 longitude:122.0305121099999];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:24.983977 longitude:121.541721];
    
    
    
    [nv setTargetLocation:loc];
    
    [self.navigationController pushViewController:nv
                                         animated:YES];
    
    
}

- (IBAction)btnCurrentLocationClicked:(id)sender {
    
    NearByVenuesViewController *nv = [self.storyboard instantiateViewControllerWithIdentifier:@"NearbyVenuesViewController"];
    
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
    
    [nv setTargetLocation:loc];
    
    [self.navigationController pushViewController:nv
                                         animated:YES];
    
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //[self setupMapForLocatoion:newLocation];
}




@end
