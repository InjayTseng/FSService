//
//  AutoCoding+RecursiveParsing.m
//  MDT1
//
//  Created by Allen Lee on 13/7/3.
//  Copyright (c) 2013年 CSI Technology Group. All rights reserved.
//

#import "AutoCoding+RecursiveParsing.h"

@implementation NSDate (ToStringForAutoCoding)
- (NSString *)toStringForAutoCoding	{
	return [self description];
}
@end


@implementation NSObject (AutoCoding_DictionaryRepresentationRecursive)

- (NSString *)jsonString		{
	id jsonObject = [self dictionaryRepresentationRecursive];
	
	NSError * err;
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:(0) error:&err];
	NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	if (!jsonString || err) {
		NSLog(@"LOG:  err: %@",err);
		return nil;
	}
	return jsonString;
}

- (NSDictionary *)dictionaryRepresentationRecursive	{
	
	NSDictionary * codableProperties = [self codableProperties];
	NSArray * allPropertyNames = [codableProperties allKeys];
	NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:allPropertyNames.count];
	
	[codableProperties enumerateKeysAndObjectsUsingBlock:^(NSString * propertyName, Class propertyClass, BOOL *stop) {
		
		id obj = [self valueForKey:propertyName];
		if ([propertyClass isSubclassOfClass:[NSString class]] ||
			[propertyClass isSubclassOfClass:[NSNumber class]] ||
			[propertyClass isSubclassOfClass:[NSNull class]] )		{
			
			//do nothing...
		}else if ([propertyClass isSubclassOfClass:[NSDate class]])	{
			
			obj = [obj toStringForAutoCoding];
			
		}else if ([propertyClass isSubclassOfClass:[NSArray class]])	{
			NSMutableArray * array = [NSMutableArray arrayWithCapacity:[obj count]];
			
			[obj enumerateObjectsUsingBlock:^(id subObj, NSUInteger idx, BOOL *stop) {
				id theObj = [subObj dictionaryRepresentationRecursive];
				[array addObject:theObj];
			}];
			obj = array;
			
		}else if ([propertyClass isSubclassOfClass:[NSDictionary class]] )	{
			NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:[obj count]];
			
			[obj enumerateKeysAndObjectsUsingBlock:^(id key, id subObj, BOOL *stop) {
				id theObj = [subObj dictionaryRepresentationRecursive];
				[dictionary setObject:theObj forKey:key];
			}];
			obj = dictionary;
			
		}else	{
			obj = [obj dictionaryRepresentationRecursive];
		}
		
		if (obj == nil) {
			obj = [NSNull null];
		}
		[dic setValue:obj forKey:propertyName];
	}];
	
	return dic;
}

@end