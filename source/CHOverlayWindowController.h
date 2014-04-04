//
//  CHOverlayWindowController.h
//  Crosshairs
//
//  Created by Zach Waugh on 11/4/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHOverlayView;

@interface CHOverlayWindowController : NSWindowController

@property (nonatomic, strong) CHOverlayView *view;

- (void)hideWindow;
- (NSRect)overlayDimensions;
- (void)takeScreenshot;
- (void)copyDimensionsToClipboard;

@end
