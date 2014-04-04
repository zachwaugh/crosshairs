//
//  DMPreferences.h
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Notifications
extern NSString * const CHColorsDidChangeNotification;


// User defaults keys
extern NSString * const CHClipboardFormatKey;
extern NSString * const CHPrimaryOverlayColorKey;
extern NSString * const CHAlternateOverlayColorKey;
extern NSString * const CHLastOverlayColorKey;
extern NSString * const CHSwitchedOverlayColorsKey;
extern NSString * const CHShowDimensionsOutsideKey;
extern NSString * const CHInvertedOverlayModeKey;
extern NSString * const CHStartAtLoginKey;
extern NSString * const CHGlobalHotKeyCode;
extern NSString * const CHGlobalHotKeyFlags;
extern NSString * const CHShowInDockKey;
extern NSString * const CHActivateAppKey;
extern NSString * const CHNumberOfLaunchesKey;
extern NSString * const CHFirstLaunchDateKey;
extern NSString * const CHTrialHashKey;
extern NSString * const CHRightMouseEscapeKey;

@interface CHPreferences : NSObject

+ (void)registerDefaults;

// Trial
+ (int)numberOfLaunches;
+ (void)incrementNumberOfLaunches;
+ (NSDate *)firstLaunchDate;
+ (void)setFirstLaunchDate:(NSDate *)date;
+ (NSString *)trialHash;
+ (void)setTrialHash:(NSString *)hash;

// Preferences
+ (NSString *)clipboardFormat;
+ (NSColor *)primaryOverlayColor;
+ (NSColor *)alternateOverlayColor;
+ (void)setLastColor:(NSColor *)color;
+ (NSColor *)lastOverlayColor;
+ (BOOL)switchedColors;
+ (void)setSwitchedColors:(BOOL)switched;
+ (BOOL)invertedOverlayMode;
+ (void)setInvertedOverlayMode:(BOOL)inverted;
+ (NSInteger)globalHotKeyCode;
+ (NSInteger)globalHotKeyFlags;
+ (void)setGlobalHotKeyCode:(NSInteger)keyCode;
+ (void)setGlobalHotKeyFlags:(NSInteger)flags;
+ (BOOL)showInDock;
+ (void)setShowInDock:(BOOL)show;
+ (BOOL)activateApp;
+ (BOOL)rightMouseEscape;

@end
