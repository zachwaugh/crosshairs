//
//  CHView.h
//  Crosshairs
//
//  Created by Zach Waugh on 9/23/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//#define TAB_KEY 48
//#define Q_KEY 12
//#define H_KEY 4

typedef NS_ENUM(NSInteger, CHResizeDirection) {
	CHResizeTopLeft,
	CHResizeTopCenter,
	CHResizeTopRight,
	CHResizeRightCenter,
	CHResizeBottomRight,
	CHResizeBottomCenter,
	CHResizeBottomLeft,
	CHResizeLeftCenter
};

@interface CHOverlayView : NSView

@property (nonatomic, assign) NSPoint startPoint;
@property (nonatomic, assign) NSPoint lastPoint;
@property (nonatomic, assign) NSRect overlayRect;
@property (nonatomic, strong) NSColor *fillColor;
@property (nonatomic, strong) NSColor *primaryColor;
@property (nonatomic, strong) NSColor *alternateColor;
@property (nonatomic, strong) NSImage *handleImage;
@property (nonatomic, strong) NSImage *bubbleImage;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSMutableDictionary *smallTextAttrs;
@property (nonatomic, assign) CHResizeDirection resizeDirection;
@property (nonatomic, assign) CGFloat fillOpacity;
@property (nonatomic, assign, getter=isDragging) BOOL dragging;
@property (nonatomic, assign, getter=isHovering) BOOL hovering;
@property (nonatomic, assign, getter=isDrawing) BOOL drawing;
@property (nonatomic, assign, getter=isInverted) BOOL inverted;
@property (nonatomic, assign, getter=isResizing) BOOL resizing;
@property (nonatomic, assign, getter=isShiftPressed) BOOL shiftPressed;
@property (nonatomic, assign, getter=isCommandPressed) BOOL commandPressed;
@property (nonatomic, assign) BOOL switchedColors;
@property (nonatomic, assign) BOOL lastPointInOverlay;
@property (nonatomic, assign) BOOL showDimensionsOutside;
@property (nonatomic, strong) NSImage *zoomImage;
@property (nonatomic, assign) BOOL zooming;
@property (nonatomic, assign) CGFloat zoomLevel;

- (void)clearOverlay;
- (void)toggleColors;
- (void)resetZoom;

@end
