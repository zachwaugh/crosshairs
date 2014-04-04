//
//  DMPreferences.m
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHPreferences.h"
#import "NSUserDefaults+Color.h"

// Notifications
NSString * const CHColorsDidChangeNotification = @"CHColorsDidChangeNotification";

// User defaults keys
NSString * const CHClipboardFormatKey = @"clipboardFormat";
NSString * const CHPrimaryOverlayColorKey = @"primaryOverlayColor";
NSString * const CHAlternateOverlayColorKey = @"alternateOverlayColor";
NSString * const CHLastOverlayColorKey = @"lastOverlayColor";
NSString * const CHSwitchedOverlayColorsKey = @"switchedOverlayColors";
NSString * const CHShowDimensionsOutsideKey = @"showDimensionsOutside";
NSString * const CHInvertedOverlayModeKey = @"invertedOverlayMode";
NSString * const CHStartAtLoginKey = @"startAtLogin";
NSString * const CHGlobalHotKeyCode = @"globalHotKeyCode";
NSString * const CHGlobalHotKeyFlags = @"globalHotKeyFlags";
NSString * const CHShowInDockKey = @"showInDock";
NSString * const CHActivateAppKey = @"activateApp";
NSString * const CHNumberOfLaunchesKey = @"numberOfLaunches";
NSString * const CHFirstLaunchDateKey = @"firstLaunchDate";
NSString * const CHTrialHashKey = @"trialHash";
NSString * const CHRightMouseEscapeKey = @"rightMouseEscape";


@implementation CHPreferences

+ (void)registerDefaults
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	
	defaults[CHClipboardFormatKey] = @"{w}x{h}";
	defaults[CHPrimaryOverlayColorKey] = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
	defaults[CHAlternateOverlayColorKey] = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.718 green:0.854 blue:0.978 alpha:1.000]];
    defaults[CHLastOverlayColorKey] = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
    defaults[CHNumberOfLaunchesKey] = @0;
    defaults[CHSwitchedOverlayColorsKey] = @NO;
    defaults[CHStartAtLoginKey] = @NO;
    defaults[CHInvertedOverlayModeKey] = @NO;
    defaults[CHShowInDockKey] = @NO;
    defaults[CHActivateAppKey] = @NO;
    defaults[CHRightMouseEscapeKey] = @NO;
    defaults[CHGlobalHotKeyCode] = @19;
    defaults[CHGlobalHotKeyFlags] = @(NSShiftKeyMask | NSCommandKeyMask);
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

#pragma mark - Trial

+ (int)numberOfLaunches
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:CHNumberOfLaunchesKey];
}

+ (void)incrementNumberOfLaunches
{
    NSInteger launches = [CHPreferences numberOfLaunches] + 1;
    
    [[NSUserDefaults standardUserDefaults] setInteger:launches forKey:CHNumberOfLaunchesKey];
}

+ (NSDate *)firstLaunchDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:CHFirstLaunchDateKey];
}

+ (void)setFirstLaunchDate:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:CHFirstLaunchDateKey];
}

+ (NSString *)trialHash
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:CHTrialHashKey];
}

+ (void)setTrialHash:(NSString *)hash
{
    [[NSUserDefaults standardUserDefaults] setObject:hash forKey:CHTrialHashKey];
}

#pragma - Preferences

+ (NSString *)clipboardFormat
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:CHClipboardFormatKey];
}

+ (NSColor *)primaryOverlayColor
{
    return [[NSUserDefaults standardUserDefaults] colorForKey:CHPrimaryOverlayColorKey];
}

+ (NSColor *)alternateOverlayColor
{
    return [[NSUserDefaults standardUserDefaults] colorForKey:CHAlternateOverlayColorKey];
}

+ (void)setLastColor:(NSColor *)color
{
    [[NSUserDefaults standardUserDefaults] setColor:color forKey:CHLastOverlayColorKey];
}

+ (NSColor *)lastOverlayColor
{
    return [[NSUserDefaults standardUserDefaults] colorForKey:CHLastOverlayColorKey];
}

+ (BOOL)switchedColors
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CHSwitchedOverlayColorsKey];
}

+ (void)setSwitchedColors:(BOOL)switched
{
    [[NSUserDefaults standardUserDefaults] setBool:switched forKey:CHSwitchedOverlayColorsKey];
}

+ (BOOL)invertedOverlayMode
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CHInvertedOverlayModeKey];
}

+ (void)setInvertedOverlayMode:(BOOL)inverted
{
    [[NSUserDefaults standardUserDefaults] setBool:inverted forKey:CHInvertedOverlayModeKey];
}

+ (NSInteger)globalHotKeyCode
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:CHGlobalHotKeyCode];
}

+ (void)setGlobalHotKeyCode:(NSInteger)keyCode
{
    [[NSUserDefaults standardUserDefaults] setInteger:keyCode forKey:CHGlobalHotKeyCode];
}

+ (NSInteger)globalHotKeyFlags
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:CHGlobalHotKeyFlags];
}

+ (void)setGlobalHotKeyFlags:(NSInteger)flags
{
    [[NSUserDefaults standardUserDefaults] setInteger:flags forKey:CHGlobalHotKeyFlags];
}

+ (BOOL)showInDock
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CHShowInDockKey];
}

+ (void)setShowInDock:(BOOL)show
{
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:CHShowInDockKey];
}

+ (BOOL)activateApp
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CHActivateAppKey];
}

+ (BOOL)rightMouseEscape
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CHRightMouseEscapeKey];
}

@end
