//
//  DateTimeValueTransformer.m
//  AutosaveBrowser
//
//  Created by Local Home on 04/06/2018.
//  Copyright © 2018 Guardian News & Media. All rights reserved.
//

#import "DateTimeValueTransformer.h"

@implementation DateTimeValueTransformer
- (id) init
{
    self = [super init];
    
    [NSValueTransformer setValueTransformer:self forName:@"DateTimeValueTransformer"];
    return self;
}

+ (Class) transformedValueClass
{
    return [NSString class];
}

+ (BOOL) allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    NSDate *date = (NSDate *)value;
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateStyle = NSDateFormatterLongStyle;
    f.timeStyle = NSDateFormatterLongStyle;
    f.locale = [NSLocale autoupdatingCurrentLocale];
    
    return [f stringFromDate:date];
}

//- (id)reverseTransformedValue:(id)value
//{
//    return [value path];
//}
@end
