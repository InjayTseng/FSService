//
//  VenueDetailViewController.h
//  FSQProject
//
//  Created by David Tseng on 2/11/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVenue.h"
#import "MWPhotoBrowser.h"


@interface VenueDetailViewController : UIViewController<MWPhotoBrowserDelegate>{
    UISegmentedControl *_segmentedControl;
    NSMutableArray *_selections;
}

@property FSVenue *currentVenue;
@property (weak, nonatomic) IBOutlet UILabel *lbCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnGoToLink;
- (IBAction)btnRouteToPlace:(id)sender;
- (IBAction)btnImageShowClicked:(id)sender;
- (IBAction)btnCallClicked:(id)sender;
- (IBAction)btnGotoLinkClicked:(id)sender;

@end
