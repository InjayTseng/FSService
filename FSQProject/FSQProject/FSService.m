//
//  FSService.m
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "FSService.h"

@implementation FSService

+ (void)getVenuesWithIconForLocation:(CLLocation *)location sortEnable:(BOOL)isSort andComplete:(ARRAYBLOCK)complete{

    [self getVenuesForLocation:location sortEnable:isSort andComplete:^(NSArray *venuesArray) {
        
        if (venuesArray != nil && venuesArray.count>0) {
            
            [self downloadCategoryIconsIn:venuesArray andComplete:^{

                complete(venuesArray);
            }];
        }else{
            complete(venuesArray);
        }

    }];
}

+ (void)getVenuesForLocation:(CLLocation *)location sortEnable:(BOOL)isSort andComplete:(ARRAYBLOCK)complete{

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
                                          NSArray * venuesArray = [converter convertToObjects:venues];
                                          if (complete !=nil) {
                                              
                                              if (isSort) {
                                                  NSArray* sortedArray = [self sortByDistance:venuesArray];
                                                  complete(sortedArray);
                                              }else{
                                                  complete(venuesArray);
                                              }
                                          }
                                      }
                                  }];
}

+(NSArray*)sortByDistance:(NSArray*)array{

    NSArray *sortedArray = [array sortedArrayUsingComparator:^(FSVenue *a, FSVenue *b) {
        return [a.location.distance compare:b.location.distance];
    }];

    return sortedArray;
}

+(void)downloadCategoryIconsIn:(NSArray*)array andComplete:(XBLOCK)complete{
    
    for (FSVenue* ve in array){

        NSString* cateFileName = [self saftyFileName:ve.categories];
        
        //First See if there is the icon in bundle
        UIImage* imageInBundle = [UIImage imageNamed:cateFileName];
        if (imageInBundle == nil) {
    
            //See if it has saved last time open.
            UIImage* lastTimeImage = [self loadImageWithName:cateFileName] ;
            if (lastTimeImage == nil) {
                
                //Fetch new icon and save.
                NSURL * imageURL = [NSURL URLWithString:ve.categorieIconUrl];
                NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage * image = [UIImage imageWithData:imageData];
                [self saveImage:image andName:cateFileName];
            }
            
        }else{
            
            [self saveImage:imageInBundle andName:cateFileName];
        }
    }
    complete();
}


+(NSString*)saftyFileName:(NSString*)name{
    
    if (name==nil) {
        return @"x";
    }
    NSString* string = [NSString stringWithString:name];
    string = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return string;
}

+ (void)saveImage: (UIImage*)image andName:(NSString*)name
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
+ (UIImage*)loadImageWithName:(NSString*)name
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
