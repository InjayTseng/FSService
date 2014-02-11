//
//  ViewController.h
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
@interface NearByVenuesViewController : UIViewController <MWPhotoBrowserDelegate>{
    UISegmentedControl *_segmentedControl;
    NSMutableArray *_selections;
    
}

@property (strong, nonatomic) CLLocation* targetLocation;


@end
