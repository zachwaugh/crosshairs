//
//  CHWindow.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHWindow.h"


@implementation CHWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{	
	NSWindow *window = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	[window setBackgroundColor:[NSColor clearColor]];
	//[window setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5]];
	[window setLevel:NSStatusWindowLevel];
	[window setAlphaValue:1.0];
	[window setOpaque:NO];
	[window setHasShadow:NO];
	[window setMovableByWindowBackground:NO];
	[window setAcceptsMouseMovedEvents:YES];
	[window setIgnoresMouseEvents:NO];
	
	return window;
}


- (BOOL)canBecomeKeyWindow
{
	return YES;
}


- (void)awakeFromNib
{
	[self makeKeyAndOrderFront:nil];
}


@end
