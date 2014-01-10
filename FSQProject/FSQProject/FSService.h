//
//  FSService.h
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Foursquare2.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
typedef void(^XBLOCK)();
typedef void(^ARRAYBLOCK)(NSArray*);

@interface FSService : NSObject

+ (void)getVenuesForLocation:(CLLocation *)location andComplete:(ARRAYBLOCK)complete;

@end
