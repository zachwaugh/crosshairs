//
//  CHView.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#define HANDLE_SIZE 8
#define HANDLE_CENTER (HANDLE_SIZE / 2.0)

#import "CHOverlayView.h"


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


@interface CHOverlayView ()

- (void)refresh;
- (void)clearOverlay;
- (void)toggleColors;

- (NSRect)resizedRectForPoint:(NSPoint)point;
- (NSRect)topLeft;
- (NSRect)topCenter;
- (NSRect)topRight;
- (NSRect)bottomRight;
- (NSRect)bottomLeft;
- (NSRect)bottomCenter;
- (NSRect)leftCenter;
- (NSRect)rightCenter;
- (NSRect)adjustedOverlayRect;

@end


@implementation CHOverlayView

// retained
@synthesize textAttrs, fillColor, crosshairsCursor, resizeLeftDiagonalCursor, resizeRightDiagonalCursor;

// assigned
@synthesize startPoint, lastPoint, lastPointInOverlay, overlayRect, dragging, drawing, resizing, shiftPressed, commandPressed, resizeDirection, alternateColor, fillOpacity;


- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];

	if (self)
	{
		self.overlayRect = NSZeroRect;
		self.fillOpacity = 0.25;
		self.fillColor = [NSColor colorWithCalibratedWhite:0.0 alpha:self.fillOpacity];
		self.alternateColor = NO;
		self.dragging = NO;
		self.drawing = NO;
		self.resizing = NO;
		self.shiftPressed = NO;
		self.commandPressed = NO;
		self.lastPointInOverlay = NO;
		self.crosshairsCursor = [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"crosshairs_cursor.png"] hotSpot:NSMakePoint(10, 10)] autorelease];
		self.resizeLeftDiagonalCursor = [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_cursor_diagonal_left.tiff"] hotSpot:NSMakePoint(8, 8)] autorelease];
		self.resizeRightDiagonalCursor = [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"resize_cursor_diagonal_right.tiff"] hotSpot:NSMakePoint(8, 8)] autorelease];

		// Setup text attributes
		NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[paragraphStyle setAlignment:NSCenterTextAlignment];
		
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
		[shadow setShadowOffset:NSMakeSize(0, -1)];
		
		NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
		[attrs setObject:[NSFont fontWithName:@"Helvetica Bold" size:36.0] forKey:NSFontAttributeName];
		[attrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[attrs setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
		[attrs setObject:shadow forKey:NSShadowAttributeName];
		
		self.textAttrs = attrs;
	}

	return self;
}


- (void)dealloc
{
	self.textAttrs = nil;
	self.fillColor = nil;
	self.crosshairsCursor = nil;
	self.resizeLeftDiagonalCursor = nil;
	self.resizeRightDiagonalCursor = nil;
	
	[super dealloc];
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}


- (void)resetCursorRects
{
	[self discardCursorRects];
	[self addCursorRect:[self visibleRect] cursor:self.crosshairsCursor];
	
	if (!NSIsEmptyRect(self.overlayRect))
	{
		[self addCursorRect:NSInsetRect(self.overlayRect, 2, 2) cursor:[NSCursor openHandCursor]];
		[self addCursorRect:[self leftCenter] cursor:[NSCursor resizeLeftRightCursor]];
		[self addCursorRect:[self rightCenter] cursor:[NSCursor resizeLeftRightCursor]];
		[self addCursorRect:[self topLeft] cursor:self.resizeLeftDiagonalCursor];
		[self addCursorRect:[self topRight] cursor:self.resizeRightDiagonalCursor];
		[self addCursorRect:[self bottomLeft] cursor:self.resizeRightDiagonalCursor];
		[self addCursorRect:[self bottomRight] cursor:self.resizeLeftDiagonalCursor];
		[self addCursorRect:[self topCenter] cursor:[NSCursor resizeUpDownCursor]];
		[self addCursorRect:[self bottomCenter] cursor:[NSCursor resizeUpDownCursor]];
	}
}


#pragma mark -
#pragma mark Move via keyboard arrows

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	// Handle tab key switching colors
	if ([[event charactersIgnoringModifiers] characterAtIndex:0] == NSTabCharacter)
	{
		[self toggleColors];
		return YES;
	}
	else if ([[event charactersIgnoringModifiers] characterAtIndex:0] == NSDeleteCharacter)
	{
		[self clearOverlay];
		return YES;
	}
	
	return [super performKeyEquivalent:event];
}


- (void)clearOverlay
{
	self.overlayRect = NSZeroRect;
	[self refresh];
}


- (void)toggleColors
{
	self.alternateColor = !self.alternateColor;
	self.fillColor = [NSColor colorWithCalibratedWhite:self.isAlternateColor alpha:self.fillOpacity];
	[self.textAttrs setObject:[NSColor colorWithCalibratedWhite:!self.isAlternateColor alpha:1.0] forKey:NSForegroundColorAttributeName];
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:self.isAlternateColor alpha:1.0]];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	[self.textAttrs setObject:shadow forKey:NSShadowAttributeName];
	 
	[self setNeedsDisplayInRect:[self adjustedOverlayRect]];
}


- (void)moveUp:(id)sender
{
	if (self.isCommandPressed)
	{
		self.fillOpacity = (self.fillOpacity < 1) ? self.fillOpacity + 0.1 : 1.0;
		self.fillColor = [NSColor colorWithCalibratedWhite:self.isAlternateColor alpha:self.fillOpacity];
		[self setNeedsDisplayInRect:[self adjustedOverlayRect]];
	}
	else
	{
		self.overlayRect = NSOffsetRect(self.overlayRect, 0, (self.isShiftPressed) ? 10 : 1);
	}
}


- (void)moveDown:(id)sender
{
	if (self.isCommandPressed)
	{
		self.fillOpacity = ((self.fillOpacity - 0.1) > 0.05) ? self.fillOpacity - 0.1 : 0.05;
		self.fillColor = [NSColor colorWithCalibratedWhite:self.isAlternateColor alpha:self.fillOpacity];
		
		[self setNeedsDisplayInRect:[self adjustedOverlayRect]];
	}
	else
	{
		self.overlayRect = NSOffsetRect(self.overlayRect, 0, (self.isShiftPressed) ? -10 : -1);
	}
}


- (void)moveLeft:(id)sender
{
	self.overlayRect = NSOffsetRect(self.overlayRect, (self.isShiftPressed) ? -10 : -1, 0);
}


- (void)moveRight:(id)sender
{
	self.overlayRect = NSOffsetRect(self.overlayRect, (self.isShiftPressed) ? 10 : 1, 0);
}


- (void)flagsChanged:(NSEvent *)event
{
	self.shiftPressed = ([event modifierFlags] & NSShiftKeyMask) ? YES : NO;
	self.commandPressed = ([event modifierFlags] & NSCommandKeyMask) ? YES : NO;
}


#pragma mark -
#pragma mark mouse handlers

- (void)mouseDown:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	self.startPoint = point;
	self.lastPoint = point;
	
	if (NSPointInRect(point, [self leftCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeLeftCenter;
		[[self window] disableCursorRects];
		[[NSCursor resizeLeftRightCursor] push];
	}
	else if (NSPointInRect(point, [self rightCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeRightCenter;
		[[self window] disableCursorRects];
		[[NSCursor resizeLeftRightCursor] push];
	}
	else if (NSPointInRect(point, [self topCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopCenter;
		[[self window] disableCursorRects];
		[[NSCursor resizeUpDownCursor] push];
	}
	else if (NSPointInRect(point, [self bottomCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomCenter;
		[[self window] disableCursorRects];
		[[NSCursor resizeUpDownCursor] push];
	}
	else if (NSPointInRect(point, [self topLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopLeft;
		[[self window] disableCursorRects];
		[self.resizeLeftDiagonalCursor push];
	}
	else if (NSPointInRect(point, [self topRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopRight;
		[[self window] disableCursorRects];
		[self.resizeRightDiagonalCursor push];
	}
	else if (NSPointInRect(point, [self bottomLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomLeft;
		[[self window] disableCursorRects];
		[self.resizeRightDiagonalCursor push];
	}
	else if (NSPointInRect(point, [self bottomRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomRight;
		[[self window] disableCursorRects];
		[self.resizeLeftDiagonalCursor push];
	}
	else if (NSPointInRect(point, self.overlayRect))
	{
		self.dragging = YES;
		[[self window] disableCursorRects];
		[[NSCursor closedHandCursor] push];
	}
	else
	{
		self.drawing = YES;
	}
}


//- (void)mouseMoved:(NSEvent *)event
//{
//	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
//	
//	BOOL pointInOverlay = NSPointInRect(point, self.overlayRect);
//	
//	if (!pointInOverlay && self.lastPointInOverlay)
//	{
//		NSLog(@"invalidating rects");
//		[[self window] invalidateCursorRectsForView:self];
//	}
//	
//	self.lastPointInOverlay = pointInOverlay;
//}


- (void)mouseDragged:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if (self.isResizing)
	{
		self.overlayRect = [self resizedRectForPoint:point];
	}
	else if (self.isDragging)
	{
		self.overlayRect = NSOffsetRect(self.overlayRect, point.x - self.startPoint.x, point.y - self.startPoint.y);
		self.startPoint = point;
	}
	else
	{
		if ([event modifierFlags] & NSShiftKeyMask)
		{
			self.overlayRect = NSRectSquareFromTwoPoints(self.startPoint, point);
		}
		else
		{
			self.overlayRect = NSRectFromTwoPoints(self.startPoint, point);
		}
	}
	
	self.lastPoint = point;
}


- (void)mouseUp:(NSEvent *)event
{
	if (self.isDragging || self.isResizing)
	{
		[NSCursor pop];
		[[self window] enableCursorRects];
	}
	
	self.dragging = NO;
	self.drawing = NO;
	self.resizing = NO;
	[self refresh];
}


#pragma mark  -
#pragma mark Drawing

- (void)refresh
{
	[self setNeedsDisplayInRect:[self adjustedOverlayRect]];
	[[self window] invalidateCursorRectsForView:self];
}


- (void)drawRect:(NSRect)dirtyRect
{
	if (!NSIsEmptyRect(self.overlayRect))
	{
		[self.fillColor set];
		NSRectFill(self.overlayRect);
		
		// Draw dashed outline of rect
		//CGFloat pattern[2] = { 4.0, 4.0 };
		
		//NSBezierPath *outline = [NSBezierPath bezierPathWithRect:NSInsetRect(self.overlayRect, -0.5, -0.5)];
		//NSBezierPath *outline = [NSBezierPath bezierPathWithRect:self.overlayRect];
		
		//[[NSColor whiteColor] set];
		//[outline stroke];
//		[[NSColor blackColor] set];
//		[outline stroke];
		
//		[[NSColor whiteColor] set];
//		[outline setLineDash:pattern count:2 phase:0];
//		[outline setLineWidth:1.0];
//		[outline stroke];
		
		
		if (!self.isDrawing && !self.isDragging)
		{
			// top left
			NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:[self topLeft]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			
			// top center
			circle = [NSBezierPath bezierPathWithOvalInRect:[self topCenter]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			
			// top right
			circle = [NSBezierPath bezierPathWithOvalInRect:[self topRight]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			
			// right center
			circle = [NSBezierPath bezierPathWithOvalInRect:[self rightCenter]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			
			// bottom right
			circle = [NSBezierPath bezierPathWithOvalInRect:[self bottomRight]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			
			// bottom center
			circle = [NSBezierPath bezierPathWithOvalInRect:[self bottomCenter]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			
			// bottom left
			circle = [NSBezierPath bezierPathWithOvalInRect:[self bottomLeft]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
			
			
			// left center
			circle = [NSBezierPath bezierPathWithOvalInRect:[self leftCenter]];
			[[NSColor grayColor] set];
			[circle fill];
			[[NSColor whiteColor] set];
			[circle stroke];
		}
		
		NSString *dimensions = [NSString stringWithFormat:@"%d x %d", (int)round(self.overlayRect.size.width), (int)round(self.overlayRect.size.height)];
		
		NSSize textSize = [dimensions sizeWithAttributes:self.textAttrs];
		NSRect textRect = NSMakeRect(self.overlayRect.origin.x, (self.overlayRect.size.height - textSize.height) / 2 + self.overlayRect.origin.y, self.overlayRect.size.width, textSize.height);
		[dimensions drawInRect:textRect withAttributes:self.textAttrs];
	}
}


#pragma mark -
#pragma mark Rectangle generation/adjustment methods

// Override setter to refresh display
- (void)setOverlayRect:(NSRect)newRect
{
	[self setNeedsDisplayInRect:[self adjustedOverlayRect]];
	
	overlayRect = newRect;
	
	[self refresh];
}


- (NSRect)adjustedOverlayRect
{
	return NSInsetRect(self.overlayRect, -HANDLE_SIZE, -HANDLE_SIZE);
}


- (NSRect)resizedRectForPoint:(NSPoint)point
{
	NSRect newRect = self.overlayRect;
	
	if (self.resizeDirection == CHResizeLeftCenter)
	{
		float delta = self.lastPoint.x - point.x;
		
		newRect.origin.x = point.x;
		newRect.size.width += delta;
	}
	else if (self.resizeDirection == CHResizeRightCenter)
	{
		float delta = point.x - self.lastPoint.x;
		
		newRect.size.width += delta;
	}
	else if (self.resizeDirection == CHResizeTopCenter)
	{
		float delta = point.y - self.lastPoint.y;
		
		newRect.size.height += delta;
	}
	else if (self.resizeDirection == CHResizeBottomCenter)
	{
		float delta = self.lastPoint.y - point.y;
		
		newRect.origin.y = point.y;
		newRect.size.height += delta;
	}
	else if (self.resizeDirection == CHResizeTopLeft)
	{
		float deltaX = self.lastPoint.x - point.x; 
		float deltaY = point.y - self.lastPoint.y;
		
		newRect.origin.x = point.x;
		newRect.size.height += deltaY;
		newRect.size.width += deltaX;
	}
	else if (self.resizeDirection == CHResizeTopRight)
	{
		float deltaX = point.x - self.lastPoint.x;
		float deltaY = point.y - self.lastPoint.y;
		
		newRect.size.width += deltaX;
		newRect.size.height += deltaY;
	}
	else if (self.resizeDirection == CHResizeBottomLeft)
	{
		float deltaX = self.lastPoint.x - point.x;
		float deltaY = self.lastPoint.y - point.y;
		
		newRect.origin = point;
		newRect.size.width += deltaX;
		newRect.size.height += deltaY;
	}
	else if (self.resizeDirection == CHResizeBottomRight)
	{
		float deltaX = point.x - self.lastPoint.x; 
		float deltaY = self.lastPoint.y - point.y;
		
		newRect.origin.y = point.y;
		newRect.size.height += deltaY;
		newRect.size.width += deltaX;
	}	
	
	return newRect;
}


- (NSRect)topLeft
{
	return NSMakeRect(NSMinX(self.overlayRect) - HANDLE_CENTER, NSMaxY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)topCenter
{
	return NSMakeRect(NSMidX(self.overlayRect) - HANDLE_CENTER, NSMaxY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)topRight
{
	return NSMakeRect(NSMaxX(self.overlayRect) - HANDLE_CENTER, NSMaxY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}

								
- (NSRect)rightCenter
{
	return NSMakeRect(NSMaxX(self.overlayRect) - HANDLE_CENTER, NSMidY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)bottomRight
{
	return NSMakeRect(NSMaxX(self.overlayRect) - HANDLE_CENTER, NSMinY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}

								
- (NSRect)bottomLeft
{
	return NSMakeRect(self.overlayRect.origin.x - HANDLE_CENTER, self.overlayRect.origin.y - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)bottomCenter
{
	return NSMakeRect(NSMidX(self.overlayRect) - HANDLE_CENTER, NSMinY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)leftCenter
{
	return NSMakeRect(NSMinX(self.overlayRect) - HANDLE_CENTER, NSMidY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);	
}

@end
