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
	NSWindow *result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	[result setBackgroundColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.25]];
	[result setLevel:NSStatusWindowLevel];
	[result setAlphaValue:1.0];
	[result setOpaque:NO];
	[result setHasShadow:NO];
	[result setMovableByWindowBackground:NO];
	
	return result;
}


- (BOOL)canBecomeKeyWindow
{
	return YES;
}


- (void)awakeFromNib
{
	[self makeKeyAndOrderFront:nil];
	[self setAcceptsMouseMovedEvents:YES];
}


@end
