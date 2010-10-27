//
//  DMPreferences.m
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHPreferences.h"
#import "CHGlobals.h"

@implementation CHPreferences

+ (void)registerDefaults
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:@"{width} {height}" forKey:DMCopyFormatKey];
	//[defaultValues setObject:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] forKey:DMPrimaryOverlayColorKey];
	//[defaultValues setObject:[NSColor colorWithCalibratedWhite:1.0 alpha:0.25] forKey:DMAlternateOverlayColorKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

@end
