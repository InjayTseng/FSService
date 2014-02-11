//
//  VenueMapViewController.m
//  FSQProject
//
//  Created by David Tseng on 1/16/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "VenueMapViewController.h"
#import "FSService.h"
#import "FSVenue.h"
#import "SVProgressHUD.h"
#import "VenueDetailViewController.h"

#define DEFAULT_LAT 25.032609
#define DEFAULT_LON 121.558727
#define TAG_LBTEXT 111
@interface VenueMapViewController ()

@end

@interface VenueAnnotation : NSObject<MKAnnotation> {
}
@property (nonatomic, retain) NSString *mPinType;
@end

@implementation VenueMapViewController

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
    if (self.targetLocation == nil) {
        self.targetLocation = [[CLLocation alloc]initWithLatitude:DEFAULT_LAT longitude:DEFAULT_LON];
    }
    MKPointAnnotation *target = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D loc = [self.targetLocation coordinate];
    target.coordinate = loc;
    target.title = @"Target";
//    target.subtitle = vs.categories;
    //        point.subtitle = @"I'm here!!!";
    [self.mapView addAnnotation:target];
    
    
    MKCoordinateRegion region;
    region.center = [self.targetLocation coordinate];
    region.span.latitudeDelta = 0.001;
    region.span.longitudeDelta = 0.001;
    self.mapView.delegate = self;
    [self.mapView setRegion:region animated:NO/YES];
    
//    [SVProgressHUD showWithStatus:@"讀取中"];
    
    [self setNearbyVenuesArray:[[Data sharedInstance] nearbyVenues]];
    [self.mapView setShowsUserLocation:YES];
    [self addVenueAnnotations];
    
//    [FSService getVenuesWithIconForLocation:self.targetLocation sortEnable:YES andComplete:^(NSArray *venuesArray) {
//        
//        [self setNearbyVenuesArray:venuesArray];
//        if (self.nearbyVenuesArray!=nil) {
//            
//            [self addVenueAnnotations];
//            [SVProgressHUD dismiss];
//        }
//    }];
    
    
//    [FSService getVenuesForLocation:self.targetLocation sortEnable:YES andComplete:^(NSArray *venuesArray) {
//        [self setNearbyVenuesArray:[NSArray arrayWithArray:venuesArray]];
//        if (self.nearbyVenuesArray!=nil) {
//            
//            [FSService downloadCategoryIconsIn:self.nearbyVenuesArray andComplete:^{
//                
//                [SVProgressHUD dismiss];
//                [self addVenueAnnotations];
//                
//            }];
//        }
//    }];
//
    //[self.mapView setShowsUserLocation:YES];
}

-(void)addVenueAnnotations{

    for (FSVenue* vs in self.nearbyVenuesArray){
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D loc = vs.location.coordinate;
        point.coordinate = loc;
        point.title = vs.name;
        point.subtitle = vs.categories;
//        point.subtitle = @"I'm here!!!";
        [self.mapView addAnnotation:point];
    }

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
    
    if ([[annotation title] isEqualToString:@"Target"]) {
        static NSString *identifier = @"TargetLocation";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;

        return annotationView;
    }
    

    static NSString *identifier = @"VenueLocation";
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//    MKPinAnnotationView *annotationView =
//    (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc]
                          initWithAnnotation:annotation
                          reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    NSString* cateFileName = [self saftyFileName:[annotation subtitle]];
    UIImage* lastTimeImage = [self loadImageWithName:cateFileName] ;
    if (lastTimeImage == nil) {
//        NSURL * imageURL = [NSURL URLWithString:venue.categorieIconUrl];
//        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
//        UIImage * image = [UIImage imageWithData:imageData];
//        [cell.imageView setImage:image];
//        [self saveImage:image andName:cateFileName];
    }else{
        
        [annotationView setImage:lastTimeImage];
        //[cell.imageView setImage:lastTimeImage];
    }
    
    
    UIButton*myButton =[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    myButton.frame =CGRectMake(0,0,40,40);
    [myButton addTarget:self action:@selector(annotaionViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [myButton setRestorationIdentifier:[annotation title]];
    annotationView.rightCalloutAccessoryView = myButton;
    
    
//    UILabel * lbNumber = [[UILabel alloc]initWithFrame:CGRectMake(-10,-40, 300, 50)];
//    [lbNumber setTextAlignment:NSTextAlignmentCenter];
//    NSString* show  = [annotation title];
//    [lbNumber setText:show];
//    [lbNumber setBackgroundColor:[UIColor clearColor]];
//    [lbNumber setTextColor:[UIColor colorWithRed:79./255. green:154./255. blue:234./255. alpha:1.]];
//    [lbNumber setFont:[UIFont boldSystemFontOfSize:12]];
//    [lbNumber setTag:TAG_LBTEXT];
//    [annotationView addSubview:lbNumber];
    
    
//    // Create a UIButton object to add on the
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [rightButton setTitle:annotation.title forState:UIControlStateNormal];
//    [annotationView setRightCalloutAccessoryView:rightButton];
//    
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
//    [leftButton setTitle:annotation.title forState:UIControlStateNormal];
//    [annotationView setLeftCalloutAccessoryView:leftButton];
    
    return annotationView;
    
    


}


-(void)annotaionViewClicked:(id)sender{
    
    UIButton *btn = sender;
    //    NSLog(@"sender %@",btn.restorationIdentifier);
    //Site *site = [[DataManager shareInstance] searchSiteByTitle:btn.restorationIdentifier];
    //[self navigatesToDetailbySite:site];
    FSVenue *vn = [self getVenueByname:btn.restorationIdentifier];
    NSLog(@"Go to %@",vn.name);
    
    
    //[self dismissViewControllerAnimated:YES completion:^{
    //   self.selectBlock(site);
    //}];
    
    VenueDetailViewController *dv = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueDetailViewController"];
    
    [dv setCurrentVenue:vn];
//    [dv setTitleName:site.name];
//    [dv.lbCanRent setText:site.availBike];
//    [dv.lbCanPark setText:site.capacity];
//    [dv setCurrentSite:site];
//    [dv goLocation:[site.lat doubleValue] andLon:[site.lng doubleValue] withName:site.name];
    [self.navigationController pushViewController:dv animated:YES];

}

-(FSVenue*)getVenueByname:(NSString*)name{

    for (FSVenue *vn in self.nearbyVenuesArray){

        if ([vn.name isEqualToString:name]) {
            
            return vn;
        }
    }
    return nil;
}


//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
//}


#pragma mark - temp

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



@end
