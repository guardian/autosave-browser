//
//  FileURLValueTransformer.m
//  AutosaveBrowser
//
//  Created by localhome on 13/06/2016.
//  Copyright (c) 2016 Guardian News & Media. All rights reserved.
//

#import "FileURLValueTransformer.h"

@implementation FileURLValueTransformer
- (id) init
{
    self = [super init];
    
    [NSValueTransformer setValueTransformer:self forName:@"FileURLValueTransformer"];
    return self;
}

+ (Class) transformedValueClass
{
    return [NSURL class];
}

+ (BOOL) allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSURL fileURLWithPath:value isDirectory:YES];
}

- (id)reverseTransformedValue:(id)value
{
    return [value path];
}

@end
