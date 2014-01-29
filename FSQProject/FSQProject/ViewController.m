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
#import "VenueMapViewController.h"
#import "SVProgressHUD.h"


@interface ViewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) FSVenue *selected;
@property (strong, nonatomic) NSArray *nearbyVenues;

@property (strong, nonatomic) IBOutlet UITableView *tbView;


@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

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
//    [self getVenuesForLocation];
    [self initRightBarButton];
}

-(void)initRightBarButton{
    UIImage* image3 = [UIImage imageNamed:@"reload_blue.png"];
    CGRect frameimg = CGRectMake(100, 100,30,30);
    UIButton* someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(getVenuesForLocation)
              forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem=mailbutton;
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

- (void)getVenuesForLocation{
    
    
    
    [SVProgressHUD setStatus:@"Searching..."];
    [FSService getVenuesWithIconForLocation:self.locationManager.location sortEnable:YES andComplete:^(NSArray *venuesArray) {

        [self setNearbyVenues:venuesArray];
        if (self.nearbyVenues!=nil) {
//            
//            [self addVenueAnnotations];
            [[self tbView] reloadData];
            [SVProgressHUD dismiss];
        }
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
- (IBAction)btnGetSpecificLocationClicked:(id)sender {
    
    CLLocation* loc = [[CLLocation alloc]initWithLatitude: 25.032609 longitude:121.558727];

    VenueMapViewController *vm = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueMapViewController"];
    [vm setTargetLocation:loc];
    [self.navigationController pushViewController:vm animated:YES];

}

//-(void)getRestaurantsFrom:(CLLocation*)loc andComplete:(XBLOCK)complete{
//
//    [FSService getVenuesForLocation:loc andComplete:^(NSArray *venuesArray) {
//        self.nearbyVenues = venuesArray;
//        [[Data sharedInstance] setNearbyVenues:[NSArray arrayWithArray:self.nearbyVenues]];
//        VenueMapViewController *vm = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueMapViewController"];
//        [vm setTargetLocation:loc];
//        [vm setNearbyVenuesArray:[NSArray arrayWithArray:venuesArray]];
//        [self.navigationController pushViewController:vm animated:YES];
//    }];
//    
//}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [SVProgressHUD setStatus:@"Searching..."];
    FSVenue *venue = self.nearbyVenues[indexPath.row];
//    [FSService getVenueTips:venue.venueId andComplete:^(NSArray *asdsa) {
//       
//    }];
    [FSService getVenuesPhoto:venue.venueId andComplete:^(NSArray *photoArray, NSArray *thumbnilArray) {
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        NSMutableArray *thumbs = [[NSMutableArray alloc] init];
        
        for (NSString* url in photoArray){
            
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
        }
        
        for (NSString* url in thumbnilArray){
            
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
        }
        
        self.photos = photos;
        self.thumbs = thumbs;
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        browser.displayNavArrows = YES;
        browser.displaySelectionButtons = NO;
        browser.alwaysShowControls = YES;
//        browser.wantsFullScreenLayout = YES;
        browser.zoomPhotosToFill = YES;
        browser.enableGrid = YES;
        browser.startOnGrid = YES;
        [browser setCurrentPhotoIndex:0];

        // Show
        [SVProgressHUD dismiss];
        if (self.photos.count != 0) {
            
            [self.navigationController pushViewController:browser animated:YES];
        }else{
        
            [SVProgressHUD showErrorWithStatus:@"沒有照片"];
        }
    }];

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




#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}





@end
