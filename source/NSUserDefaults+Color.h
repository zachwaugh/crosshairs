//
//  NSUserDefaults+Color.h
//  Crosshairs
//
//  Created by Zach Waugh on 10/31/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSUserDefaults (Color)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;

@end
