//
//  ViewController.m
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "ViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AutoCoding+RecursiveParsing.h"
#import "FSService.h"

@interface ViewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) FSVenue *selected;
@property (strong, nonatomic) NSArray *nearbyVenues;

@property (strong, nonatomic) IBOutlet UITableView *tbView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Main";
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    [self.locationManager startUpdatingLocation];
    //[self updateRightBarButtonStatus];
	// Do any additional setup after loading the view, typically from a nib.
    [self getVenuesForLocation:self.locationManager.location];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    
    //[self setupMapForLocatoion:newLocation];
}


- (void)updateRightBarButtonStatus {
    self.navigationItem.rightBarButtonItem.enabled = [Foursquare2 isAuthorized];
    if ([Foursquare2 isAuthorized]) {
        NSLog(@"isAuthorized.");
    }else{
        NSLog(@"not Authorized.");
    }
}

- (void)getVenuesForLocation:(CLLocation *)location {
    
    [FSService getVenuesForLocation:location andComplete:^(NSArray *venuesArray) {
        self.nearbyVenues = venuesArray;
        [self showResult];
    }];
    
}

-(void)showResult{
 
    if (self.nearbyVenues != nil) {
        for (FSVenue * vn in self.nearbyVenues){
            NSLog(@"%@",[vn dictionaryRepresentationRecursive]);
        }
    }
    
    [self.tbView reloadData];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.nearbyVenues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [self.nearbyVenues[indexPath.row] name];
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    if (venue.location.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m, %@",
                                     venue.location.distance,
                                     venue.location.address];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m",
                                     venue.location.distance];
    }
    
    NSString* cateFileName = [self saftyFileName:venue.categories];
    UIImage* lastTimeImage = [self loadImageWithName:cateFileName] ;
    if (lastTimeImage == nil) {
        NSURL * imageURL = [NSURL URLWithString:venue.categorieIconUrl];
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage * image = [UIImage imageWithData:imageData];
        [cell.imageView setImage:image];
        [self saveImage:image andName:cateFileName];
    }else{
        
        [cell.imageView setImage:lastTimeImage];
    }


    
    return cell;
    
}

-(NSString*)saftyFileName:(NSString*)name{

    if (name==nil) {
        return @"x";
    }
    NSString* string = [NSString stringWithString:name];
    string = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return string;
}

- (void)saveImage: (UIImage*)image andName:(NSString*)name
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@",name] ];
        NSData* data = UIImagePNGRepresentation(image);
        
        NSLog(@"save %@ %i",name,[data writeToFile:path atomically:YES]);
    }
}
- (UIImage*)loadImageWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@",name] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
