//
//  Data.m
//  FSQProject
//
//  Created by David Tseng on 1/10/14.
//  Copyright (c) 2014 David Tseng. All rights reserved.
//

#import "FSData.h"

@implementation FSData
+(FSData *) sharedInstance
{
    static FSData *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
