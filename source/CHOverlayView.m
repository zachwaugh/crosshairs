//
//  CHView.m
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#define HANDLE_SIZE 17
#define HANDLE_CENTER 8
#define DIMENSIONS_HEIGHT 44

#import "CHOverlayView.h"
#import "CHGlobals.h"
#import "NSCursor+Custom.h"
#import "CHPreferences.h"
#import "CHAppDelegate.h"

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
- (void)fullRefresh;
- (void)conditionalRefresh;
- (void)switchInvertedOverlayMode;

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
@synthesize smallTextAttrs, fillColor, primaryColor, alternateColor, handleImage, bubbleImage, trackingArea;

// assigned
@synthesize startPoint, lastPoint, lastPointInOverlay, overlayRect, dragging, drawing, inverted, hovering, resizing, shiftPressed, commandPressed, resizeDirection, switchedColors, fillOpacity, showDimensionsOutside;


- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.overlayRect = NSZeroRect;
		self.fillColor = [CHPreferences lastOverlayColor];
    self.primaryColor = [CHPreferences primaryOverlayColor];
    self.alternateColor = [CHPreferences alternateOverlayColor];
    self.fillOpacity = [self.fillColor alphaComponent];
		self.handleImage = [NSImage imageNamed:@"handle.png"];
    self.bubbleImage = [NSImage imageNamed:@"bubble.png"];
		self.switchedColors = [CHPreferences switchedColors];
		self.dragging = NO;
    self.hovering = NO;
		self.drawing = NO;
		self.resizing = NO;
		self.shiftPressed = NO;
		self.commandPressed = NO;
    self.inverted = [CHPreferences invertedOverlayMode];
		self.lastPointInOverlay = NO;

    // setup dimensions bubble text attrs
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowColor:[NSColor blackColor]];
		[shadow setShadowOffset:NSMakeSize(0, 1)];
    
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
	self.smallTextAttrs = nil;
	self.fillColor = nil;
  self.primaryColor = nil;
  self.alternateColor = nil;
  self.handleImage = nil;
  self.bubbleImage = nil;
  [self removeTrackingArea:self.trackingArea];
  self.trackingArea = nil;
	
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
	[super dealloc];
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}


- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
  return YES;
}


- (BOOL)needsPanelToBecomeKey
{
  return YES;
}


- (BOOL)isFlipped
{
	return YES;
}


- (void)resetCursorRects
{
	[self addCursorRect:[self bounds] cursor:[NSCursor crosshairsCursor]];
}


- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	[self removeTrackingArea:self.trackingArea];
	self.trackingArea = nil;
	
  self.trackingArea = [[[NSTrackingArea alloc] initWithRect:[self bounds] options:(NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil] autorelease];
  [self addTrackingArea:self.trackingArea];
}


#pragma mark -
#pragma mark Keyboard handling

- (void)keyDown:(NSEvent *)event
{
  NSString *characters = [event charactersIgnoringModifiers];
  
  if ([characters isEqualToString:@"i"])
  {
    [self switchInvertedOverlayMode];
  }
  else
  {
    [super keyDown:event];
  }
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
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
		self.fillOpacity = (self.fillOpacity < 1) ? self.fillOpacity + 0.05 : 1.0;
		self.fillColor = [self.fillColor colorWithAlphaComponent:self.fillOpacity];
    [CHPreferences setLastColor:self.fillColor];
    
		[self conditionalRefresh];
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
		self.fillOpacity = ((self.fillOpacity - 0.05) > 0.05) ? self.fillOpacity - 0.05 : 0.05;
		self.fillColor = [self.fillColor colorWithAlphaComponent:self.fillOpacity];
		[CHPreferences setLastColor:self.fillColor];
    
    [self conditionalRefresh];
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
	BOOL empty = NSIsEmptyRect(self.overlayRect);
  
	if (!empty && NSPointInRect(point, [self leftCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeLeftCenter;
		[[NSCursor resizeLeftRightCursor] set];
	}
	else if (!empty && NSPointInRect(point, [self rightCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeRightCenter;
		[[NSCursor resizeLeftRightCursor] set];
	}
	else if (!empty && NSPointInRect(point, [self topCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopCenter;
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (!empty && NSPointInRect(point, [self bottomCenter]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomCenter;
		[[NSCursor resizeUpDownCursor] set];
	}
	else if (!empty && NSPointInRect(point, [self topLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopLeft;
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (!empty && NSPointInRect(point, [self topRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeTopRight;
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (!empty && NSPointInRect(point, [self bottomLeft]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomLeft;
		[[NSCursor resizeRightDiagonalCursor] set];
	}
	else if (!empty && NSPointInRect(point, [self bottomRight]))
	{
		self.resizing = YES;
		self.resizeDirection = CHResizeBottomRight;
		[[NSCursor resizeLeftDiagonalCursor] set];
	}
	else if (!empty && NSPointInRect(point, self.overlayRect))
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


- (void)rightMouseDown:(NSEvent *)theEvent
{
  // Support for disabled users
  if ([CHPreferences rightMouseEscape])
  {
    [(CHAppDelegate *)[NSApp delegate] deactivateApp];
  }
}


- (void)cursorUpdate:(NSEvent *)event
{
	//NSLog(@"cursorUpdate:");
	[[NSCursor crosshairsCursor] set];
}


// Cursor handling
- (void)updateCursorsForPoint:(NSPoint)point
{
  if (NSIsEmptyRect(self.overlayRect))
  {
    [[NSCursor crosshairsCursor] set];
  }
  else
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


// redraw affected area
- (void)refresh
{
  [self setNeedsDisplayInRect:[self drawingRect]];
}


// Redraw entire screen
- (void)fullRefresh
{
  [self setNeedsDisplay:YES];
}


// Redraw region based on drawing mode
- (void)conditionalRefresh
{
  if (self.inverted)
  {
    [self fullRefresh];
  }
  else
  {
    [self refresh];
  }
}


- (void)drawRect:(NSRect)dirtyRect
{
  if (self.isInverted)
  {
    [self.fillColor set];
    NSRectFill([self bounds]);
  }

  
	if (!NSIsEmptyRect(self.overlayRect))
	{
    if (self.isInverted)
    {
      [[NSColor clearColor] set];
      NSRectFill([self overlayRect]);
    }
    else
    {
      [self.fillColor set];
      NSRectFill(self.overlayRect);
    }
		
		if (!self.isDrawing && !self.isDragging && !self.isResizing && self.isHovering)
		{
			// draw handles if enough room
      if (self.overlayRect.size.height > HANDLE_SIZE && self.overlayRect.size.width > HANDLE_SIZE)
      {
        [self drawHandleInRect:[self topLeft]];	
        [self drawHandleInRect:[self topRight]];
        [self drawHandleInRect:[self bottomRight]];	
        [self drawHandleInRect:[self bottomLeft]]; 
      }
			
      // don't draw middle handles if not enough vertical room
      if (self.overlayRect.size.height > (HANDLE_SIZE * 2))
      {
        [self drawHandleInRect:[self rightCenter]];
        [self drawHandleInRect:[self leftCenter]];
      }
      
      // Don't draw middle handles if not enough horizontal room
      if (self.overlayRect.size.width > (HANDLE_SIZE * 2))
      {
        [self drawHandleInRect:[self topCenter]];
        [self drawHandleInRect:[self bottomCenter]];	
      }
		}
		
    [self drawDimensionsBox];		
	}
}


// Draw a resize handle in the specified rect
- (void)drawHandleInRect:(NSRect)rect
{
  rect = NSIntegralRect(rect);
  [self.handleImage drawInRect:NSMakeRect(rect.origin.x, rect.origin.y, HANDLE_SIZE, HANDLE_SIZE) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
}


// bubble that shows dimensions
- (void)drawDimensionsBox
{
  NSString *dimensions = [NSString stringWithFormat:@"%d x %d", (int)round(self.overlayRect.size.width), (int)round(self.overlayRect.size.height)];
  
  NSSize dimensionsSize = [dimensions sizeWithAttributes:self.smallTextAttrs];
	
  float totalWidth = dimensionsSize.width + 18;
  float bodyWidth = round((dimensionsSize.width - 18) / 2);
  
	int startX = round(NSMidX(self.overlayRect) - (totalWidth / 2)) - 1;
  
  if ((int)self.overlayRect.size.width % 2 == 0)
  {
    startX += 1;
  }
  
	int startY = round(NSMaxY(self.overlayRect) + 6);
	
  NSRect dimensionsRect = NSMakeRect(startX + 9, startY + 15, dimensionsSize.width, 41);
    	
	// left cap
  [self.bubbleImage drawInRect:NSMakeRect(startX, startY, 9, 41) fromRect:NSMakeRect(0, 0, 9, 41) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
  
	// width
	[self.bubbleImage drawInRect:NSMakeRect(startX + 9, startY, bodyWidth, 41) fromRect:NSMakeRect(12, 0, 1, 41) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	
	// beak
	[self.bubbleImage drawInRect:NSMakeRect(startX + 9 + bodyWidth, startY, 18, 41) fromRect:NSMakeRect(46, 0, 18, 41) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	
	// height
	[self.bubbleImage drawInRect:NSMakeRect(startX + 9 + bodyWidth + 18, startY, bodyWidth, 41) fromRect:NSMakeRect(12, 0, 1, 41) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	
	// right cap
	[self.bubbleImage drawInRect:NSMakeRect(startX + 9 + bodyWidth + 18 + bodyWidth, startY, 9, 41) fromRect:NSMakeRect(101, 0, 9, 41) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];

  [dimensions drawInRect:dimensionsRect withAttributes:self.smallTextAttrs];
}


// TAB between primary and alternate colors
- (void)toggleColors
{
	self.switchedColors = !self.switchedColors;
  self.fillColor = (!self.switchedColors) ? [self.primaryColor colorWithAlphaComponent:self.fillOpacity] : [self.alternateColor colorWithAlphaComponent:self.fillOpacity];
  [CHPreferences setLastColor:self.fillColor];
  [CHPreferences setSwitchedColors:self.switchedColors];
  
	[self conditionalRefresh];
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


- (void)switchInvertedOverlayMode
{
  self.inverted = !self.inverted;
  [CHPreferences setInvertedOverlayMode:self.inverted];
  [self setNeedsDisplay:YES]; // full refresh
  [self refresh];
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
  if (NSIsEmptyRect(self.overlayRect)) return NSZeroRect;
  
	// overlay rect + padding for handles and dimensions
	float handles = (HANDLE_SIZE + 1) / 2;
	float xInset = -handles;
	float yInset = -(handles + (DIMENSIONS_HEIGHT / 2));
	
	NSRect drawingRect = NSOffsetRect(NSInsetRect(self.overlayRect, xInset, yInset), 0, 20);
	
  // Leave enough space for bubble to be bigger than overlay
	if (drawingRect.size.width < 120)
	{
    float deltaX = (120 - drawingRect.size.width) / 2;
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
