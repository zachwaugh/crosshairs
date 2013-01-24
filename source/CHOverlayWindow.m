//
//  CHWindow.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHOverlayWindow.h"
#import "CHAppDelegate.h"

@implementation CHOverlayWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{	
	if ((self =[super initWithContentRect:contentRect styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask) backing:NSBackingStoreBuffered defer:NO])) {
		[self setBackgroundColor:[NSColor clearColor]];
		//[window setBackgroundColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]];
		[self setLevel:NSStatusWindowLevel];
		[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
		[self setAlphaValue:1.0];
		[self setOpaque:NO];
		[self setHasShadow:NO];
		[self setMovableByWindowBackground:NO];
		[self setIgnoresMouseEvents:NO];
		[self setBecomesKeyOnlyIfNeeded:YES];
		//[window setAcceptsMouseMovedEvents:YES];
	}

	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)awakeFromNib
{
	NSRect windowRect = NSZeroRect;
	
	for (NSScreen *screen in [NSScreen screens]) {
    windowRect = NSUnionRect([screen frame], windowRect);
	}
  	
	[self setFrame:windowRect display:YES animate:NO];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	//NSLog(@"(CHOverlayWindow) performKeyEquivalent: %@, %c", [event characters], [event keyCode]);
	NSString *characters = [event charactersIgnoringModifiers];

	if (([event modifierFlags] & NSCommandKeyMask) && [characters length] == 1 && [characters isEqualToString:@"h"]) {
		[(CHAppDelegate *)[NSApp delegate] deactivateApp];
		return YES;
	} else {
		return [super performKeyEquivalent:event];
	}
}

@end
