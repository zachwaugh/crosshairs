//
//  CHView.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHView.h"


NSRect NSRectFromTwoPoints(NSPoint a, NSPoint b)
{
	NSRect r;
	
	r.origin.x = MIN(a.x, b.x);
	r.origin.y = MIN(a.y, b.y);
	
	r.size.width = ABS(a.x - b.x);
	r.size.height = ABS(a.y - b.y);
	
	return r;
}


NSRect NSRectSquareFromTwoPoints(NSPoint a, NSPoint b)
{
	NSRect r;
	
	r.origin.x = MIN(a.x, b.x);
	r.origin.y = MIN(a.y, b.y);
	
	float width;
	float height;
	
	width = ABS(a.x - b.x);
	height = ABS(a.y - b.y);
	
	r.size.width = MIN(width, height);
	r.size.height = MIN(width, height);
	
	return r;
}


@implementation CHView

// retained
@synthesize textAttrs;

// assigned
@synthesize startPoint, box, dragging, drawing;


- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];

	if (self)
	{
		self.box = NSZeroRect;
		self.dragging = NO;
		self.drawing = NO;
	}

	return self;
}


- (void)dealloc
{
	self.textAttrs = nil;
	
	[super dealloc];
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}


- (void)awakeFromNib
{
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor blackColor]];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	[attrs setObject:[NSFont fontWithName:@"Helvetica Bold" size:36.0] forKey:NSFontAttributeName];
	[attrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[attrs setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
	[paragraphStyle release];
	
	[attrs setObject:shadow forKey:NSShadowAttributeName];
	[shadow release];
	
	self.textAttrs = attrs;
	self.box = NSZeroRect;
	self.dragging = NO;
	
	[[self window] makeFirstResponder:self];
}


- (void)cancelOperation:(id)sender
{
	self.box = NSZeroRect;
	[self setNeedsDisplay:YES];
	[NSApp hide:nil];
}


#pragma mark -
#pragma mark Move via keyboard arrows

- (void)moveUp:(id)sender
{
	self.box = NSOffsetRect(self.box, 0, 1);
	[self setNeedsDisplay:YES];
}


- (void)moveDown:(id)sender
{
	self.box = NSOffsetRect(self.box, 0, -1);
	[self setNeedsDisplay:YES];
}


- (void)moveLeft:(id)sender
{
	self.box = NSOffsetRect(self.box, -1, 0);
	[self setNeedsDisplay:YES];
}


- (void)moveRight:(id)sender
{
	self.box = NSOffsetRect(self.box, 1, 0);
	[self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark mouse handlers

- (void)mouseDown:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	self.startPoint = point;
	
	if (NSPointInRect(point, self.box))
	{
		self.dragging = YES;
	}
	else
	{
		self.drawing = YES;
	}

}


- (void)mouseMoved:(NSEvent *)event
{
	//NSPoint point = [event locationInWindow];
}


- (void)mouseDragged:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if (self.dragging)
	{
		self.box = NSOffsetRect(self.box, point.x - self.startPoint.x, point.y - self.startPoint.y);
		self.startPoint = point;
	}
	else
	{
		//[[NSCursor crosshairCursor] set];
		[[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"crosshairs.png"] hotSpot:NSMakePoint(10, 10)] set];

		if ([event modifierFlags] & NSShiftKeyMask)
		{
			self.box = NSRectSquareFromTwoPoints(self.startPoint, point);
		}
		else
		{
			self.box = NSRectFromTwoPoints(self.startPoint, point);
		}
	}

	[self setNeedsDisplay:YES];
}


- (void)mouseUp:(NSEvent *)event
{
	//[[NSCursor arrowCursor] set];
	self.dragging = NO;
	self.drawing = NO;
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
	if (!NSEqualRects(self.box, NSZeroRect))
	{
		[[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
		NSRectFill(self.box);
		
		NSBezierPath *outline = [NSBezierPath bezierPathWithRect:NSInsetRect(self.box, 0.5, 0.5)];
		[[NSColor whiteColor] set];
		[outline setLineWidth:1.0];
		[outline stroke];
		
		if (!self.drawing && !self.dragging)
		{
			NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(self.box.origin.x - 5.5, self.box.origin.y - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMinX(self.box) - 5.5, NSMaxY(self.box) - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMaxX(self.box) - 5.5, NSMinY(self.box) - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMidX(self.box) - 5.5, NSMaxY(self.box) - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMaxX(self.box) - 5.5, NSMidY(self.box) - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMinX(self.box) - 5.5, NSMidY(self.box) - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMaxX(self.box) - 5.5, NSMaxY(self.box) - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMidX(self.box) - 5.5, NSMinY(self.box) - 5.5, 10, 10)];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
		}
		
		// draw instructional text
		NSString *dimensions = [NSString stringWithFormat:@"%d x %d", (int)round(self.box.size.width), (int)round(self.box.size.height)];
		
		NSSize textSize = [dimensions sizeWithAttributes:self.textAttrs];
		NSRect textRect = NSMakeRect(self.box.origin.x, (self.box.size.height - textSize.height) / 2 + self.box.origin.y, self.box.size.width, textSize.height);
		[dimensions drawInRect:textRect withAttributes:self.textAttrs];
	}
}


@end
