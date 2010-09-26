//
//  CHStatusItemView.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/26/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHStatusItemView.h"


@implementation CHStatusItemView

@synthesize delegate, image, highlighted;

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];

	if (self)
	{
		self.image = [NSImage imageNamed:@"crosshairs.png"];
		self.highlighted = NO;
	}
	
	return self;
}


- (void)dealloc
{
	self.delegate = nil;
	self.image = nil;
	
	[super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

	if (self.highlighted)
	{
		[[NSColor blueColor] set];
		NSRectFill([self bounds]);
	}
	
	[self.image drawAtPoint:NSMakePoint(([self bounds].size.width - [self.image size].width) / 2 - 0.5, ([self bounds].size.height - [self.image size].height) / 2 - 0.5)	fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}



- (void)rightMouseDown:(NSEvent *)event
{
	if ([self.delegate respondsToSelector:@selector(didRightClickStatusItem:)])
	{
		[self.delegate didRightClickStatusItem:event];
	}
}


- (void)mouseDown:(NSEvent *)event
{
	self.highlighted = YES;
	[self setNeedsDisplay:YES];
	
	if ([self.delegate respondsToSelector:@selector(didClickStatusItem)])
	{
		[self.delegate didClickStatusItem];
	}
}


- (void)mouseUp:(NSEvent *)theEvent
{
	self.highlighted = NO;
	[self setNeedsDisplay:YES];
}


@end
