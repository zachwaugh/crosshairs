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
  NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:@"{w} {h}" forKey:CHCopyFormatKey];
	[defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]] forKey:CHPrimaryOverlayColorKey];
	[defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]] forKey:CHAlternateOverlayColorKey];
  [defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]] forKey:CHLastOverlayColorKey];
  [defaultValues setObject:[NSNumber numberWithBool:NO] forKey:CHSwitchedOverlayColorsKey];
  [defaultValues setObject:[NSNumber numberWithBool:NO] forKey:CHShowDimensionsOutsideKey];
  [defaultValues setObject:[NSNumber numberWithBool:NO] forKey:CHStartAtLoginKey];
  [defaultValues setObject:[NSNumber numberWithInt:19] forKey:CHGlobalHotKeyCode];
  [defaultValues setObject:[NSNumber numberWithInt:(NSShiftKeyMask | NSCommandKeyMask)] forKey:CHGlobalHotKeyFlags];
  
  
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


+ (NSString *)copyFormat
{
  return [[NSUserDefaults standardUserDefaults] stringForKey:CHCopyFormatKey];
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


+ (BOOL)showDimensionsOutside
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:CHShowDimensionsOutsideKey];
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


@end
