//
//  FSService.m
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "FSService.h"

@implementation FSService
+ (void)getVenuesForLocation:(CLLocation *)location andComplete:(ARRAYBLOCK)complete{

    
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:nil
                                     limit:nil
                                    intent:intentCheckin
                                    radius:@(500)
                                categoryId:nil
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc]init];
                                          if (complete !=nil) {
                                              complete([converter convertToObjects:venues]);
                                          }
                                      }
                                  }];
}

@end
