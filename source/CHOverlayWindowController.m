//
//  CHOverlayWindowController.m
//  Crosshairs
//
//  Created by Zach Waugh on 11/4/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import <Carbon/Carbon.h> // for key codes

#import "CHOverlayWindowController.h"
#import "CHAppDelegate.h"
#import "CHPreferences.h"
#import "CHOverlayWindow.h"
#import "CHOverlayView.h"

@implementation CHOverlayWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"CHOverlayWindowController"];
    if (!self) return nil;
    
    return self;
}

- (void)showWindow:(id)sender
{
    [self.view resetZoom];
    [[self window] makeKeyAndOrderFront:sender];
    [self.view updateTrackingAreas];
}

- (void)hideWindow
{
    // Clear zoom
    [self.view resetZoom];
    [self.window orderOut:nil];
}

- (void)keyDown:(NSEvent *)event
{
    NSString *characters = [event charactersIgnoringModifiers];
    
    if (([event modifierFlags] & NSCommandKeyMask) && [characters length] == 1 && [characters isEqualToString:@"c"]) {
        [self copyDimensionsToClipboard];
    } else if (event.keyCode == kVK_Space) {
		[self takeScreenshot];
	} else {
		[super keyDown:event];
	}
}

- (void)cancel:(id)sender
{
	[(CHAppDelegate *)[NSApp delegate] deactivateApp];
}

- (NSRect)overlayDimensions
{
    return self.view.overlayRect;
}

- (void)copyDimensionsToClipboard
{
    NSRect overlayRect = [self overlayDimensions];
    int width = (int)overlayRect.size.width;
    int height = (int)overlayRect.size.height;
    NSString *format = [CHPreferences clipboardFormat];
    
    NSString *dimensions = [format stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d", width]];
    dimensions = [dimensions stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d", height]];
    
	[[NSPasteboard generalPasteboard] declareTypes:@[NSStringPboardType] owner:self];
	[[NSPasteboard generalPasteboard] setString:dimensions forType:NSStringPboardType];
}

#pragma mark - Screenshot

- (void)takeScreenshot
{
    // Capture screenshot
    NSRect overlayRect = [self.view convertRectToBase:[self overlayDimensions]];
    overlayRect.origin = [[self window] convertBaseToScreen:overlayRect.origin];
    overlayRect.origin.y = NSMaxY([[NSScreen screens][0] frame]) - NSMaxY(overlayRect);
    
	CGImageRef screenShot = CGWindowListCreateImage(NSRectToCGRect(overlayRect), kCGWindowListOptionOnScreenBelowWindow, [[self window] windowNumber], kCGWindowImageDefault);
	NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithCGImage:screenShot];
    
    // Build screenshot filename
    int width = (int)overlayRect.size.width;
    int height = (int)overlayRect.size.height;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' h.mm.ss a"];
    NSString *timestamp = [NSString stringWithFormat:@"%@ (%d x %d)", [dateFormatter stringFromDate:[NSDate date]], width, height];
    
    NSString *filename = [NSString stringWithFormat:@"Screen shot %@.png", timestamp];
    
    // Write out screenshot png
    [[image representationUsingType:NSPNGFileType properties:nil] writeToFile:[NSString stringWithFormat:@"%@/Desktop/%@", NSHomeDirectory(), filename] atomically:NO];
    
	CGImageRelease(screenShot);
    
    // Notify
}

@end
