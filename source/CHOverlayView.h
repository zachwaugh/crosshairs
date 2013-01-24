//
//  CHView.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TAB_KEY 48
#define Q_KEY 12
#define H_KEY 4

typedef enum
{
	CHResizeTopLeft,
	CHResizeTopCenter,
	CHResizeTopRight,
	CHResizeRightCenter,
	CHResizeBottomRight,
	CHResizeBottomCenter,
	CHResizeBottomLeft,
	CHResizeLeftCenter
} CHResizeDirection;


@interface CHOverlayView : NSView

@property(assign) NSPoint startPoint;
@property(assign) NSPoint lastPoint;
@property(nonatomic, assign) NSRect overlayRect;
@property(retain) NSColor *fillColor;
@property(retain) NSColor *primaryColor;
@property(retain) NSColor *alternateColor;
@property(retain) NSImage *handleImage;
@property(retain) NSImage *bubbleImage;
@property(retain) NSTrackingArea *trackingArea;
@property(retain) NSMutableDictionary *smallTextAttrs;
@property(assign) CHResizeDirection resizeDirection;
@property(assign) float fillOpacity;
@property(assign, getter=isDragging) BOOL dragging;
@property(assign, getter=isHovering) BOOL hovering;
@property(assign, getter=isDrawing) BOOL drawing;
@property(assign, getter=isInverted) BOOL inverted;
@property(assign, getter=isResizing) BOOL resizing;
@property(assign, getter=isShiftPressed) BOOL shiftPressed;
@property(assign, getter=isCommandPressed) BOOL commandPressed;
@property(assign) BOOL switchedColors;
@property(assign) BOOL lastPointInOverlay;
@property(assign) BOOL showDimensionsOutside;

- (void)clearOverlay;
- (void)toggleColors;

@end
