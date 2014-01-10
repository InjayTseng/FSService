//
//  FSConverter.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import "FSConverter.h"
#import "FSVenue.h"

@implementation FSConverter

- (NSArray *)convertToObjects:(NSArray *)venues {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:venues.count];
    for (NSDictionary *v  in venues) {
        FSVenue *ann = [[FSVenue alloc]init];
        ann.name = v[@"name"];
        ann.venueId = v[@"id"];
        NSArray* categories = v[@"categories"];
        if (categories.count>0) {
            NSDictionary* categoryDic = [categories objectAtIndex:0];
            ann.categories = categoryDic[@"name"];
            NSDictionary* subcategoryDic = categoryDic[@"icon"];
            NSMutableString * urlcombined = [[NSMutableString alloc]initWithString:@""];
            
            [urlcombined appendString:subcategoryDic[@"prefix"]];
            [urlcombined appendString:@"bg_32"];
            [urlcombined appendString:subcategoryDic[@"suffix"]];
            
            ann.categorieIconUrl = [NSString stringWithString:urlcombined];
        }
//        ann.categories = v[@"categories"][@"name"];
        ann.location.address = v[@"location"][@"address"];
        ann.location.distance = v[@"location"][@"distance"];
        
        [ann.location setCoordinate:CLLocationCoordinate2DMake([v[@"location"][@"lat"] doubleValue],
                                                      [v[@"location"][@"lng"] doubleValue])];
        
        ann.contact.phone = v[@"contact"][@"phone"];
        ann.contact.link = v[@"url"];
        
        [objects addObject:ann];
    }
    return objects;
}

@end
