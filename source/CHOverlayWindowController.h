//
//  CHOverlayWindowController.h
//  Crosshairs
//
//  Created by Zach Waugh on 11/4/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@class CHOverlayView;

@interface CHOverlayWindowController : NSWindowController <GrowlApplicationBridgeDelegate>
{
  IBOutlet CHOverlayView *view;
}

@property (retain) CHOverlayView *view;

- (void)hideWindow;
- (NSRect)overlayDimensions;
- (void)takeScreenshot;
- (void)copyDimensionsToClipboard;

@end
