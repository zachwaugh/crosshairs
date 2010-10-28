//
//  CHView.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#define HANDLE_SIZE 9
#define HANDLE_CENTER (HANDLE_SIZE / 2.0)

#import "CHOverlayView.h"
#import "NSCursor+Custom.h"

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

- (void)updateCursorsForPoint:(NSPoint)point;
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
- (NSRect)drawingRect;

- (void)drawHandleInRect:(NSRect)rect;

@end


@implementation CHOverlayView

// retained
@synthesize textAttrs, smallTextAttrs, fillColor;

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

		// Setup text attributes
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
		[shadow setShadowOffset:NSMakeSize(0, -1)];
		
		NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
		[attrs setObject:[NSFont fontWithName:@"Helvetica Bold" size:36.0] forKey:NSFontAttributeName];
		[attrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[attrs setObject:shadow forKey:NSShadowAttributeName];
		
		self.textAttrs = attrs;
		self.smallTextAttrs = [attrs mutableCopy];
		[self.smallTextAttrs setObject:[NSFont fontWithName:@"Helvetica Bold" size:14.0] forKey:NSFontAttributeName];		
	}

	return self;
}


- (void)dealloc
{
	self.textAttrs = nil;
	self.smallTextAttrs = nil;
	self.fillColor = nil;
	
	[super dealloc];
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}


- (BOOL)isFlipped
{
	return YES;
}


//- (void)resetCursorRects
//{
//	[self discardCursorRects];
//	
//	[self addCursorRect:[self visibleRect] cursor:[NSCursor crosshairsCursor]];
//	
//	if (!NSIsEmptyRect(self.overlayRect))
//	{
//		[self addCursorRect:self.overlayRect cursor:[NSCursor openHandCursor]];
//		
//		[self addCursorRect:[self leftCenter] cursor:[NSCursor resizeLeftRightCursor]];
//		[self addCursorRect:[self rightCenter] cursor:[NSCursor resizeLeftRightCursor]];
//		[self addCursorRect:[self topLeft] cursor:[NSCursor resizeLeftDiagonalCursor]];
//		[self addCursorRect:[self topRight] cursor:[NSCursor resizeRightDiagonalCursor]];
//		[self addCursorRect:[self bottomLeft] cursor:[NSCursor resizeRightDiagonalCursor]];
//		[self addCursorRect:[self bottomRight] cursor:[NSCursor resizeLeftDiagonalCursor]];
//		[self addCursorRect:[self topCenter] cursor:[NSCursor resizeUpDownCursor]];
//		[self addCursorRect:[self bottomCenter] cursor:[NSCursor resizeUpDownCursor]];
//	}
//}


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
	else if ([[event charactersIgnoringModifiers] characterAtIndex:0] == NSDeleteCharacter || [[event charactersIgnoringModifiers] characterAtIndex:0] == NSDeleteFunctionKey)
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
	 
	[self setNeedsDisplayInRect:[self drawingRect]];
}


		 
- (void)moveUp:(id)sender
{
	if (self.isCommandPressed)
	{
		self.fillOpacity = (self.fillOpacity < 1) ? self.fillOpacity + 0.1 : 1.0;
		self.fillColor = [NSColor colorWithCalibratedWhite:self.isAlternateColor alpha:self.fillOpacity];
		[self setNeedsDisplayInRect:[self drawingRect]];
	}
	else
	{
		self.overlayRect = NSOffsetRect(self.overlayRect, 0, (self.isShiftPressed) ? -10 : -1);
	}
}


- (void)moveDown:(id)sender
{
	if (self.isCommandPressed)
	{
		self.fillOpacity = ((self.fillOpacity - 0.1) > 0.05) ? self.fillOpacity - 0.1 : 0.05;
		self.fillColor = [NSColor colorWithCalibratedWhite:self.isAlternateColor alpha:self.fillOpacity];
		
		[self setNeedsDisplayInRect:[self drawingRect]];
	}
	else
	{
		self.overlayRect = NSOffsetRect(self.overlayRect, 0, (self.isShiftPressed) ? 10 : 1);
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
		//[[self window] disableCursorRects];
		[[NSCursor resizeLeftRightCursor] set];
	}
	else if (NSPointInRect(point, [self rightCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeRightCenter;
		//[[self window] disableCursorRects];
		[[NSCursor resizeLeftRightCursor] set];
	}
	else if (NSPointInRect(point, [self topCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopCenter;
		//[[self window] disableCursorRects];
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (NSPointInRect(point, [self bottomCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomCenter;
		//[[self window] disableCursorRects];
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (NSPointInRect(point, [self topLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopLeft;
		//[[self window] disableCursorRects];
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self topRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopRight;
		//[[self window] disableCursorRects];
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self bottomLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomLeft;
		//[[self window] disableCursorRects];
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self bottomRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomRight;
		//[[self window] disableCursorRects];
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (NSPointInRect(point, self.overlayRect))
	{
		self.dragging = YES;
		//[[self window] disableCursorRects];
		[[NSCursor closedHandCursor] set];
	}
	else
	{
		self.drawing = YES;
	}
}


- (void)mouseMoved:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	
	[self updateCursorsForPoint:point];
}


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
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	[self updateCursorsForPoint:point];
	
	if (self.isDragging || self.isResizing)
	{
		//[NSCursor pop];
		//[[self window] enableCursorRects];
	}
	
	
	
	self.dragging = NO;
	self.drawing = NO;
	self.resizing = NO;
	[self refresh];
}


- (void)updateCursorsForPoint:(NSPoint)point
{
	if (NSPointInRect(point, [self leftCenter]))
	{
		[[NSCursor resizeLeftRightCursor] set];
	}
	else if (NSPointInRect(point, [self rightCenter]))
	{
		[[NSCursor resizeLeftRightCursor] set];
	}
	else if (NSPointInRect(point, [self topCenter]))
	{
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (NSPointInRect(point, [self bottomCenter]))
	{
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (NSPointInRect(point, [self topLeft]))
	{
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self topRight]))
	{
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self bottomLeft]))
	{
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self bottomRight]))
	{
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (NSPointInRect(point, self.overlayRect))
	{
		[[NSCursor openHandCursor] set];
	}
	else
	{
		[[NSCursor crosshairsCursor] set];
	}
}


#pragma mark  -
#pragma mark Drawing

- (void)refresh
{
	if (!self.isDrawing)
	{
		[[self window] invalidateCursorRectsForView:self];
	}
	
	[self setNeedsDisplayInRect:[self drawingRect]];
}


- (void)drawRect:(NSRect)dirtyRect
{
	if (!NSIsEmptyRect(self.overlayRect))
	{
		[self.fillColor set];
		NSRectFill(self.overlayRect);		
		
		if (!self.isDrawing && !self.isDragging && !self.isResizing)
		{
			// draw handles
			[self drawHandleInRect:[self topLeft]];			
			[self drawHandleInRect:[self topCenter]];	
			[self drawHandleInRect:[self topRight]];	
			[self drawHandleInRect:[self rightCenter]];	
			[self drawHandleInRect:[self bottomRight]];	
			[self drawHandleInRect:[self bottomCenter]];	
			[self drawHandleInRect:[self bottomLeft]];	
			[self drawHandleInRect:[self leftCenter]];
		}
		
		NSString *dimensions = [NSString stringWithFormat:@"%d x %d", (int)round(self.overlayRect.size.width), (int)round(self.overlayRect.size.height)];
		
		NSSize textSize = [dimensions sizeWithAttributes:self.textAttrs];
		NSRect textRect = NSMakeRect((self.overlayRect.size.width - textSize.width) / 2 + self.overlayRect.origin.x, (self.overlayRect.size.height - textSize.height) / 2 + self.overlayRect.origin.y, textSize.width, textSize.height);
		
		// Only draw text if it will fit in overlay
		if (NSContainsRect(self.overlayRect, textRect))
		{
			[dimensions drawInRect:textRect withAttributes:self.textAttrs];
		}
		else
		{

		}
		
		textSize = [dimensions sizeWithAttributes:self.smallTextAttrs];
		NSRect dimensionsBoxRect = NSMakeRect(NSMidX(self.overlayRect) - ((textSize.width + 20) / 2), NSMaxY(self.overlayRect) + 5, textSize.width + 20, textSize.height + 4);
		
		textRect = dimensionsBoxRect;
		textRect.origin.x += (dimensionsBoxRect.size.width - textSize.width) / 2;
		textRect.origin.y += (dimensionsBoxRect.size.height - textSize.height) / 2;
		textRect.size.width = textSize.width;
		
		NSBezierPath *dimensionsBox = [NSBezierPath bezierPathWithRoundedRect:dimensionsBoxRect xRadius:10 yRadius:10];
		[[NSColor colorWithCalibratedWhite:0.0 alpha:0.75] set];
		[dimensionsBox fill];
		[dimensions drawInRect:textRect withAttributes:self.smallTextAttrs];
	}
}


- (void)drawHandleInRect:(NSRect)rect
{
	NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:rect];
	[[NSColor grayColor] set];
	[circle fill];
	[[NSColor whiteColor] set];
	[circle stroke];
}


#pragma mark -
#pragma mark Rectangle generation/adjustment methods

// Override setter to refresh display
- (void)setOverlayRect:(NSRect)newRect
{
	[self setNeedsDisplayInRect:[self drawingRect]];
	
	overlayRect = newRect;
	
	[self refresh];
}


// Rect that encompasses current drawing area
- (NSRect)drawingRect
{
	// overlay rect + padding for handles and dimensions
	float handles = (HANDLE_SIZE + 1) / 2;
	float xInset = -handles;
	float yInset = -(handles + 15);
	
	NSRect drawingRect = NSOffsetRect(NSInsetRect(self.overlayRect, xInset, yInset), 0, 15);
	
	if (drawingRect.size.width < 100) drawingRect.size.width = 100;
	//if (drawingRect.size.height < 100) drawingRect.size.height = 100;
	
	return drawingRect;
}


- (NSRect)resizedRectForPoint:(NSPoint)point
{
	NSRect newRect = self.overlayRect;
	
	if (self.resizeDirection == CHResizeLeftCenter)
	{
		float delta = self.lastPoint.x - point.x;
		
		newRect.origin.x -= delta;
		newRect.size.width += delta;
	}
	else if (self.resizeDirection == CHResizeRightCenter)
	{
		float delta = point.x - self.lastPoint.x;
		
		newRect.size.width += delta;
	}
	else if (self.resizeDirection == CHResizeBottomCenter)
	{
		float delta = point.y - self.lastPoint.y;
		
		newRect.size.height += delta;
	}
	else if (self.resizeDirection == CHResizeTopCenter)
	{
		float delta = self.lastPoint.y - point.y;
		
		newRect.origin.y -= delta;
		newRect.size.height += delta;
	}
	else if (self.resizeDirection == CHResizeBottomLeft)
	{
		float deltaX = self.lastPoint.x - point.x; 
		float deltaY = point.y - self.lastPoint.y;
		
		newRect.origin.x -= deltaX;
		newRect.size.height += deltaY;
		newRect.size.width += deltaX;
	}
	else if (self.resizeDirection == CHResizeBottomRight)
	{
		float deltaX = point.x - self.lastPoint.x;
		float deltaY = point.y - self.lastPoint.y;
		
		newRect.size.width += deltaX;
		newRect.size.height += deltaY;
	}
	else if (self.resizeDirection == CHResizeTopLeft)
	{
		float deltaX = self.lastPoint.x - point.x;
		float deltaY = self.lastPoint.y - point.y;
		
		newRect.origin.x -= deltaX;
		newRect.origin.y -= deltaY;
		newRect.size.width += deltaX;
		newRect.size.height += deltaY;
	}
	else if (self.resizeDirection == CHResizeTopRight)
	{
		float deltaX = point.x - self.lastPoint.x; 
		float deltaY = self.lastPoint.y - point.y;
		
		newRect.origin.y -= deltaY;
		newRect.size.height += deltaY;
		newRect.size.width += deltaX;
	}	
	
	return newRect;
}


- (NSRect)topLeft
{
	return NSMakeRect(NSMinX(self.overlayRect) - HANDLE_CENTER, NSMinY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)topCenter
{
	return NSMakeRect(NSMidX(self.overlayRect) - HANDLE_CENTER, NSMinY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)topRight
{
	return NSMakeRect(NSMaxX(self.overlayRect) - HANDLE_CENTER, NSMinY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}

								
- (NSRect)rightCenter
{
	return NSMakeRect(NSMaxX(self.overlayRect) - HANDLE_CENTER, NSMidY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)bottomRight
{
	return NSMakeRect(NSMaxX(self.overlayRect) - HANDLE_CENTER, NSMaxY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}

								
- (NSRect)bottomLeft
{
	return NSMakeRect(NSMinX(self.overlayRect) - HANDLE_CENTER, NSMaxY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)bottomCenter
{
	return NSMakeRect(NSMidX(self.overlayRect) - HANDLE_CENTER, NSMaxY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);
}


- (NSRect)leftCenter
{
	return NSMakeRect(NSMinX(self.overlayRect) - HANDLE_CENTER, NSMidY(self.overlayRect) - HANDLE_CENTER, HANDLE_SIZE, HANDLE_SIZE);	
}

@end
