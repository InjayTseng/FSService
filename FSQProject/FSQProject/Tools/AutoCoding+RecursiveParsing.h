//
//  AutoCoding+RecursiveParsing.h
//  MDT1
//
//  Created by Allen Lee on 13/7/3.
//  Copyright (c) 2013年 CSI Technology Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoCoding.h"

@interface NSDate (ToStringForAutoCoding)
- (NSString *)toStringForAutoCoding;
@end


@interface NSObject (AutoCoding_DictionaryRepresentationRecursive)
- (NSString *)jsonString;
- (NSDictionary *)dictionaryRepresentationRecursive;
@end