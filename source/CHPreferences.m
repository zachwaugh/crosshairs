//
//  DMPreferences.m
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHPreferences.h"
#import "CHGlobals.h"
#import "NSUserDefaults+Color.h"

@implementation CHPreferences

+ (void)registerDefaults
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	
	[defaults setObject:@"{w}x{h}" forKey:CHClipboardFormatKey];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]] forKey:CHPrimaryOverlayColorKey];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] forKey:CHAlternateOverlayColorKey];
  [defaults setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]] forKey:CHLastOverlayColorKey];
  [defaults setObject:[NSNumber numberWithInt:0] forKey:CHNumberOfLaunchesKey];
  [defaults setObject:[NSNumber numberWithBool:NO] forKey:CHSwitchedOverlayColorsKey];
  [defaults setObject:[NSNumber numberWithBool:NO] forKey:CHStartAtLoginKey];
  [defaults setObject:[NSNumber numberWithBool:NO] forKey:CHShowInDockKey];
  [defaults setObject:[NSNumber numberWithInt:19] forKey:CHGlobalHotKeyCode];
  [defaults setObject:[NSNumber numberWithInt:(NSShiftKeyMask | NSCommandKeyMask)] forKey:CHGlobalHotKeyFlags];
  
  
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


#pragma mark -
#pragma mark Trial

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


#pragma -
#pragma mark Preferences


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

@end
