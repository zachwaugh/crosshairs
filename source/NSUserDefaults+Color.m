//
//  NSUserDefaults+Color.m
//  Crosshairs
//
//  Created by Zach Waugh on 10/31/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import "NSUserDefaults+Color.h"

@implementation NSUserDefaults (Color)

- (void)setColor:(NSColor *)color forKey:(NSString *)key
{
    NSData *data = [NSArchiver archivedDataWithRootObject:color];
    [self setObject:data forKey:key];
}

- (NSColor *)colorForKey:(NSString *)key
{
    NSColor *color = nil;
    NSData *data = [self dataForKey:key];
    
    if (data) {
        color = (NSColor *)[NSUnarchiver unarchiveObjectWithData:data];
    }
    
    return color;
}

@end
