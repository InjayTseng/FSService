//
//  VenueDetailViewController.m
//  FSQProject
//
//  Created by David Tseng on 2/11/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "VenueDetailViewController.h"
#import "AutoCoding.h"
#import "FSVenue.h"
#import "FSService.h"
#import "SVProgressHUD.h"
@interface VenueDetailViewController ()

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end

@implementation VenueDetailViewController

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
    
    if (![[self.currentVenue contact] link]) {
        self.btnGoToLink.alpha = 0.3;
        self.btnGoToLink.enabled = FALSE;
    }else{
        
        NSString *linkshow = @"官網連結";
        [self.btnGoToLink setTitle:linkshow forState:UIControlStateNormal];
    }
    
    if (![[self.currentVenue contact] phone]) {
        self.btnCall.alpha = 0.3;
        self.btnCall.enabled = FALSE;
        
        
    }else{
    
        NSString *callshow = [NSString stringWithFormat:@"打給 %@",[[self.currentVenue contact] phone]];
        [self.btnCall setTitle:callshow forState:UIControlStateNormal];
        
    }
    
//    NSLog(@"%@",[self.currentVenue dictionaryRepresentation]);
//    NSLog(@"%@ %@ ",[[self.currentVenue contact] link],[[self.currentVenue contact] phone]);
    self.navigationItem.title = self.currentVenue.name;
    self.lbCategory.text = self.currentVenue.categories;
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRouteToPlace:(id)sender {
    
    [self routeFrom:25.03224425354909 andLon:121.5583175891882 toLocation:self.currentVenue.location.coordinate.latitude andLon:self.currentVenue.location.coordinate.longitude];
    
}

- (IBAction)btnImageShowClicked:(id)sender {
    
    [FSService getVenuesPhoto:self.currentVenue.venueId andComplete:^(NSArray *photoArray, NSArray *thumbnilArray) {
        
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
- (IBAction)btnGotoLinkClicked:(id)sender {
    

}
- (IBAction)btnCallClicked:(id)sender {
    
    NSString *callStr = [NSString stringWithFormat:@"tel:%@",[[self.currentVenue contact] phone]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callStr]];

}


-(void)routeFrom:(double)lat1 andLon:(double)lon1 toLocation:(double)lat2 andLon:(double)lon2{
    
    CLLocationCoordinate2D location1;
    location1.latitude = lat1;
    location1.longitude = lon1;
    
    CLLocationCoordinate2D location2;
    location2.latitude = lat2;
    location2.longitude = lon2;
    
    MKPlacemark *annotation1 = [[MKPlacemark alloc]initWithCoordinate:location1 addressDictionary:nil];
    MKMapItem *curItem = [[MKMapItem alloc]initWithPlacemark:annotation1];
    
    MKPlacemark *annotation2 = [[MKPlacemark alloc]initWithCoordinate:location2 addressDictionary:nil];
    MKMapItem *toItem = [[MKMapItem alloc]initWithPlacemark:annotation2];
    
    NSArray *array = [[NSArray alloc] initWithObjects:curItem,toItem,nil];
    NSDictionary *dicOption = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
                                MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES] };
    [MKMapItem openMapsWithItems:array launchOptions:dicOption];
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
