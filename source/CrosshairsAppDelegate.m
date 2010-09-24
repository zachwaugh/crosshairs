//
//  CrosshairsAppDelegate.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CrosshairsAppDelegate.h"

@implementation CrosshairsAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.window setFrame:[[NSScreen mainScreen] frame] display:YES];
}

@end
