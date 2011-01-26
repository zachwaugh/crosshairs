//
//  DMPreferences.h
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CHPreferences : NSObject

+ (void)registerDefaults;
+ (int)numberOfLaunches;
+ (void)incrementNumberOfLaunches;
+ (NSDate *)firstLaunchDate;
+ (void)setFirstLaunchDate:(NSDate *)date;
+ (NSString *)clipboardFormat;
+ (NSColor *)primaryOverlayColor;
+ (NSColor *)alternateOverlayColor;
+ (void)setLastColor:(NSColor *)color;
+ (NSColor *)lastOverlayColor;
+ (BOOL)switchedColors;
+ (void)setSwitchedColors:(BOOL)switched;
+ (BOOL)showDimensionsOutside;
+ (NSInteger)globalHotKeyCode;
+ (NSInteger)globalHotKeyFlags;
+ (void)setGlobalHotKeyCode:(NSInteger)keyCode;
+ (void)setGlobalHotKeyFlags:(NSInteger)flags;
+ (BOOL)showInDock;
+ (void)setShowInDock:(BOOL)show;

@end
