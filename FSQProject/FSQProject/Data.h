//
//  Data.h
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"

@interface Data : NSObject

+(Data *) sharedInstance;

@property (strong, nonatomic) FSVenue *selected;
@property (strong, nonatomic) NSArray *nearbyVenues;

@end
