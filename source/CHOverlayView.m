//
//  CHView.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#define HANDLE_SIZE 12
#define HANDLE_CENTER (HANDLE_SIZE / 2.0)

#import "CHOverlayView.h"
#import "CHGlobals.h"
#import "NSCursor+Custom.h"
#import "CHPreferences.h"

NSRect CHRectFromTwoPoints(NSPoint a, NSPoint b)
{
	NSRect r;
	
	r.origin.x = MIN(a.x, b.x);
	r.origin.y = MIN(a.y, b.y);
	
	r.size.width = ABS(a.x - b.x);
	r.size.height = ABS(a.y - b.y);
	
	return r;
}


NSRect CHRectSquareFromTwoPoints(NSPoint a, NSPoint b)
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


NSPoint CHIntegralPoint(NSPoint p)
{
	p.x = round(p.x);
	p.y = round(p.y);
	
	return p;
}


@interface CHOverlayView ()

- (void)updateCursorsForPoint:(NSPoint)point;
- (void)refresh;

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
- (void)drawDimensionsBox;

@end


@implementation CHOverlayView

// retained
@synthesize textAttrs, smallTextAttrs, fillColor, primaryColor, alternateColor, handle;

// assigned
@synthesize startPoint, lastPoint, lastPointInOverlay, overlayRect, dragging, drawing, hovering, resizing, shiftPressed, commandPressed, resizeDirection, switchedColors, fillOpacity, showDimensionsOutside;


- (id)initWithFrame:(NSRect)frame
{
	NSLog(@"initWithFrame");
	self = [super initWithFrame:frame];

	if (self)
	{
		self.overlayRect = NSZeroRect;
		self.fillColor = [CHPreferences lastOverlayColor];
    self.primaryColor = [CHPreferences primaryOverlayColor];
    self.alternateColor = [CHPreferences alternateOverlayColor];
    self.fillOpacity = [self.fillColor alphaComponent];
		self.handle = [NSImage imageNamed:@"handle.png"];
		self.switchedColors = [CHPreferences switchedColors];
		self.dragging = NO;
    self.hovering = NO;
		self.drawing = NO;
		self.resizing = NO;
		self.shiftPressed = NO;
		self.commandPressed = NO;
		self.lastPointInOverlay = NO;
    [self bind:@"showDimensionsOutside" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.showDimensionsOutside" options:nil];

		// Setup overlay text attributes
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:self.switchedColors alpha:1.0]];
		[shadow setShadowOffset:NSMakeSize(0, -1)];
		
		self.textAttrs = [NSMutableDictionary dictionary];
		[self.textAttrs setObject:[NSFont fontWithName:@"Helvetica Bold" size:20.0] forKey:NSFontAttributeName];
		[self.textAttrs setObject:[NSColor colorWithCalibratedWhite:!self.switchedColors alpha:1.0] forKey:NSForegroundColorAttributeName];
		[self.textAttrs setObject:shadow forKey:NSShadowAttributeName];
		
    
    // setup dimensions bubble text attrs
    shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor blackColor]];
		[shadow setShadowOffset:NSMakeSize(0, -1)];
    
		self.smallTextAttrs = [NSMutableDictionary dictionary];
    [self.smallTextAttrs setObject:shadow forKey:NSShadowAttributeName];
    [self.smallTextAttrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[self.smallTextAttrs setObject:[NSFont fontWithName:@"Helvetica Bold" size:14.0] forKey:NSFontAttributeName];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorsDidChange:) name:CHColorsDidChangeNotification object:nil];
	}

	return self;
}


- (void)dealloc
{
	self.textAttrs = nil;
	self.smallTextAttrs = nil;
	self.fillColor = nil;
  self.primaryColor = nil;
  self.alternateColor = nil;
	
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
	[super dealloc];
}


- (void)resetCursorRects
{
  [self addCursorRect:[self visibleRect] cursor:[NSCursor crosshairsCursor]];
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}


- (BOOL)isFlipped
{
	return YES;
}


#pragma mark -
#pragma mark Keyboard handling

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	NSLog(@"(CHOverlayView) performKeyEquivalent: %@, %c", [event characters], [event keyCode]);
	NSString *characters = [event charactersIgnoringModifiers];
	
	if ([characters characterAtIndex:0] == NSTabCharacter) 
	{
		// Handle tab key switching colors
		[self toggleColors];
		return YES;
	}
	else if ([characters characterAtIndex:0] == NSDeleteCharacter || [characters characterAtIndex:0] == NSDeleteFunctionKey)
	{
		// Delete overlay
		[self clearOverlay];
		return YES;
	}
	
	return [super performKeyEquivalent:event];
}


- (void)moveUp:(id)sender
{
	if (self.isCommandPressed)
	{
		self.fillOpacity = (self.fillOpacity < 1) ? self.fillOpacity + 0.1 : 1.0;
		self.fillColor = [self.fillColor colorWithAlphaComponent:self.fillOpacity];
    [CHPreferences setLastColor:self.fillColor];
    
		[self refresh];
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
		self.fillColor = [self.fillColor colorWithAlphaComponent:self.fillOpacity];
		[CHPreferences setLastColor:self.fillColor];
    
		[self refresh];
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
	NSPoint point = CHIntegralPoint([self convertPoint:[event locationInWindow] fromView:nil]);
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
		[[NSCursor resizeLeftRightCursor] set];
	}
	else if (NSPointInRect(point, [self topCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopCenter;
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (NSPointInRect(point, [self bottomCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomCenter;
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (NSPointInRect(point, [self topLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopLeft;
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self topRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopRight;
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self bottomLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomLeft;
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (NSPointInRect(point, [self bottomRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomRight;
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (NSPointInRect(point, self.overlayRect))
	{
		self.dragging = YES;
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
	
  BOOL wasHovering = self.hovering;
	[self updateCursorsForPoint:point];
  
  if (wasHovering != self.hovering)
  {
    [self refresh];
  }
}


- (void)mouseDragged:(NSEvent *)event
{
	NSPoint point = CHIntegralPoint([self convertPoint:[event locationInWindow] fromView:nil]);

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
			self.overlayRect = CHRectSquareFromTwoPoints(self.startPoint, point);
		}
		else
		{
			self.overlayRect = CHRectFromTwoPoints(self.startPoint, point);
		}
	}
	
	self.lastPoint = point;
}


- (void)mouseUp:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	[self updateCursorsForPoint:point];
	
	self.dragging = NO;
	self.drawing = NO;
	self.resizing = NO;
	[self refresh];
}


// Cursor handling
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
  
  
  // Only show handles if mouse is over overlay
  self.hovering = (NSPointInRect(point, NSInsetRect([self drawingRect], -20, -20)));
}


#pragma mark  -
#pragma mark Drawing

- (void)clearOverlay
{
	self.overlayRect = NSZeroRect;
  self.hovering = NO;
  [[NSCursor crosshairsCursor] set];
	[self refresh];
}


- (void)refresh
{
	[self setNeedsDisplayInRect:[self drawingRect]];
}


- (void)drawRect:(NSRect)dirtyRect
{
  //NSLog(@"overlay rect: %@", NSStringFromRect(self.overlayRect));
  
	if (!NSIsEmptyRect(self.overlayRect))
	{    
		[self.fillColor set];
		NSRectFill(self.overlayRect);		
		
		if (!self.isDrawing && !self.isDragging && !self.isResizing && self.isHovering)
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
		
    [self drawDimensionsBox];		
	}
}


// Draw a resize handle in the specified rect
- (void)drawHandleInRect:(NSRect)rect
{
  rect = NSIntegralRect(rect);
  [self.handle drawInRect:NSMakeRect(rect.origin.x, rect.origin.y, HANDLE_SIZE, HANDLE_SIZE) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	
//  NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:rect];
//	[[NSColor colorWithCalibratedRed:0.129 green:0.384 blue:0.812 alpha:1.000] set];
//	[circle fill];
//	[[NSColor whiteColor] set];
//	[circle stroke];
}


- (void)drawDimensionsBox
{
  NSString *dimensions = [NSString stringWithFormat:@"%d x %d", (int)round(self.overlayRect.size.width), (int)round(self.overlayRect.size.height)];
  
  NSSize textSize;
  NSRect textRect;
  
  textSize = [dimensions sizeWithAttributes:self.textAttrs];
  textRect = NSMakeRect((self.overlayRect.size.width - textSize.width) / 2 + self.overlayRect.origin.x, (self.overlayRect.size.height - textSize.height) / 2 + self.overlayRect.origin.y, textSize.width, textSize.height);

  BOOL textFitsInRect = (NSContainsRect(self.overlayRect, textRect));
  
  // Only draw text if it will fit in overlay
  if (textFitsInRect && !self.showDimensionsOutside)
  {
    [dimensions drawInRect:textRect withAttributes:self.textAttrs];
  }
  
  if (!textFitsInRect || self.showDimensionsOutside)
  {
    // Draw dimensions bubble
    textSize = [dimensions sizeWithAttributes:self.smallTextAttrs];
    NSRect dimensionsBoxRect = NSMakeRect(NSMidX(self.overlayRect) - ((textSize.width + 20) / 2), NSMaxY(self.overlayRect) + 11, textSize.width + 20, textSize.height + 4);
    
    textRect = dimensionsBoxRect;
    textRect.origin.x += (dimensionsBoxRect.size.width - textSize.width) / 2;
    textRect.origin.y += (dimensionsBoxRect.size.height - textSize.height) / 2;
    textRect.size.width = textSize.width;
    
    NSBezierPath *dimensionsBox = [NSBezierPath bezierPathWithRoundedRect:dimensionsBoxRect xRadius:10 yRadius:10];
    
    NSBezierPath *beak = [NSBezierPath bezierPath];
    [beak	moveToPoint:NSMakePoint(NSMidX(dimensionsBoxRect) - 5, NSMinY(dimensionsBoxRect))];
    [beak lineToPoint:NSMakePoint(NSMidX(dimensionsBoxRect), NSMinY(dimensionsBoxRect) - 5)];
    [beak lineToPoint:NSMakePoint(NSMidX(dimensionsBoxRect) + 5, NSMinY(dimensionsBoxRect))];
    [beak closePath];
    
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.75] set];
    [dimensionsBox fill];
    [beak fill];
    [dimensions drawInRect:textRect withAttributes:self.smallTextAttrs];
  }  
}


- (void)toggleColors
{
	self.switchedColors = !self.switchedColors;
  self.fillColor = (!self.switchedColors) ? [self.primaryColor colorWithAlphaComponent:self.fillOpacity] : [self.alternateColor colorWithAlphaComponent:self.fillOpacity];
  [CHPreferences setLastColor:self.fillColor];
  [CHPreferences setSwitchedColors:self.switchedColors];  
  
	[self.textAttrs setObject:[NSColor colorWithCalibratedWhite:!self.switchedColors alpha:1.0] forKey:NSForegroundColorAttributeName];
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:self.switchedColors alpha:1.0]];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	[self.textAttrs setObject:shadow forKey:NSShadowAttributeName];
  
	[self refresh];
}


// Overlay colors were changed in perferences
- (void)colorsDidChange:(NSNotification *)notification
{
  NSDictionary *userInfo = [notification userInfo];
  NSString *key = [[userInfo allKeys] objectAtIndex:0];
  
  if (key == CHPrimaryOverlayColorKey)
  {
    self.primaryColor = [userInfo objectForKey:key];
    
    if (!self.switchedColors)
    {
      self.fillColor = [self.primaryColor colorWithAlphaComponent:self.fillOpacity];
      [CHPreferences setLastColor:self.fillColor];
    }
  }
  else
  {
    self.alternateColor = [userInfo objectForKey:key];
    
    if (self.switchedColors)
    {
      self.fillColor = [self.alternateColor colorWithAlphaComponent:self.fillOpacity];
      [CHPreferences setLastColor:self.fillColor];
    }
  }
}


#pragma mark -
#pragma mark Rectangle generation/adjustment methods

// Override setter to refresh display
- (void)setOverlayRect:(NSRect)newRect
{
	// clears old drawing
	[self setNeedsDisplayInRect:[self drawingRect]];
	
	overlayRect = newRect;
	
	[self refresh];
}


// Rect that encompasses current drawing area
- (NSRect)drawingRect
{
	// overlay rect + padding for handles and dimensions
	float handles = (HANDLE_SIZE + 1) / 2;
	float xInset = -(handles);
	float yInset = -(handles + 15);
	
	NSRect drawingRect = NSOffsetRect(NSInsetRect(self.overlayRect, xInset, yInset), 0, 15);
	
	if (drawingRect.size.width < 80)
	{
    float deltaX = (80 - drawingRect.size.width) / 2;
		drawingRect = NSInsetRect(drawingRect, -deltaX, 0);
  }
	
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
