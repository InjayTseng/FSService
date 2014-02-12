//
//  ViewController.m
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "NearByVenuesViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AutoCoding+RecursiveParsing.h"
#import "FSService.h"
#import "VenueMapViewController.h"
#import "SVProgressHUD.h"
#import "VenueDetailViewController.h"


@interface NearByVenuesViewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) FSVenue *selected;
@property (strong, nonatomic) NSArray *nearbyVenues;
@property (strong, nonatomic) IBOutlet UITableView *tbView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end

@implementation NearByVenuesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"附近景點";
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    [self rightButtonCreate];
    [self getVenuesForLocation];
}

-(void)rightButtonCreate{

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"地圖模式"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(btnGetSpecificLocationClicked:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}
-(void)initRightBarButton{
    
    //UIImage* image3 = [UIImage imageNamed:@"reload_blue.png"];
    CGRect frameimg = CGRectMake(100, 100,100,80);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setTitle:@"123" forState:UIControlStateNormal];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        [someButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    } else {
        
    }
    [someButton addTarget:self action:@selector(getVenuesForLocation)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem=mailbutton;
}

- (void)updateRightBarButtonStatus {
    //self.navigationItem.rightBarButtonItem.enabled = [Foursquare2 isAuthorized];
    if ([Foursquare2 isAuthorized]) {
        NSLog(@"isAuthorized.");
    }else{
        NSLog(@"not Authorized.");
    }
}

- (void)getVenuesForLocation{
    
    [SVProgressHUD showWithStatus:@"請稍後"];
    [FSService getVenuesWithIconForLocation:self.targetLocation sortEnable:YES andComplete:^(NSArray *venuesArray) {

        [self setNearbyVenues:venuesArray];
        [[FSData sharedInstance] setNearbyVenues:venuesArray];
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
    
    VenueMapViewController *vm = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueMapViewController"];
    [vm setTargetLocation:self.targetLocation];
    [self.navigationController pushViewController:vm animated:YES];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [SVProgressHUD setStatus:@"Searching..."];
    FSVenue *venue = self.nearbyVenues[indexPath.row];

    VenueDetailViewController *vv = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueDetailViewController"];
    [vv setCurrentVenue:venue];
    [self.navigationController pushViewController:vv animated:YES];


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
