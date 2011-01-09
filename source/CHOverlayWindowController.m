//
//  CHOverlayWindowController.m
//  Crosshairs
//
//  Created by Zach Waugh on 11/4/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//

#import "CHOverlayWindowController.h"
#import "CHPreferences.h"
#import "CHOverlayWindow.h"
#import "CHOverlayView.h"
#import "CHGlobals.h"

@implementation CHOverlayWindowController

@synthesize view;


- (void)dealloc
{
  self.view = nil;
  
  [super dealloc];
}

- (void)awakeFromNib
{
  [GrowlApplicationBridge setGrowlDelegate:self];
}


- (void)hideWindow
{
  [[self window] orderOut:nil];
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
  
	[[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[[NSPasteboard generalPasteboard] setString:dimensions forType:NSStringPboardType];
}


#pragma mark -
#pragma mark Screenshot

- (void)takeScreenshot
{
  // Capture screenshot
  NSRect overlayRect = [self overlayDimensions];
	CGRect captureRect = NSRectToCGRect(overlayRect);
	CGImageRef screenShot = CGWindowListCreateImage(captureRect, kCGWindowListOptionOnScreenBelowWindow, [[self window] windowNumber], kCGWindowImageDefault);
	NSBitmapImageRep *image = [[[NSBitmapImageRep alloc] initWithCGImage:screenShot] autorelease];
  
  // Build screenshot filename
  int width = (int)overlayRect.size.width;
  int height = (int)overlayRect.size.height;
  
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' h.mm.ss a"];
  NSString *timestamp = [NSString stringWithFormat:@"%@ (%d x %d)", [dateFormatter stringFromDate:[NSDate date]], width, height];
  
  NSString *filename = [NSString stringWithFormat:@"Screen shot %@.png", timestamp];
  
  // Write out screenshot png
  [[image representationUsingType:NSPNGFileType properties:nil] writeToFile:[NSString stringWithFormat:@"%@/Desktop/%@", NSHomeDirectory(), filename] atomically:NO];
  
	CGImageRelease(screenShot);
  
  [GrowlApplicationBridge notifyWithTitle:@"Screenshot Saved" description:filename notificationName:CHGrowlScreenshotSavedNotification iconData:nil priority:0 isSticky:NO clickContext:nil];
}

#pragma mark -
#pragma mark Growl Delegate

- (NSDictionary *)registrationDictionaryForGrowl
{
  NSArray *notifications = [NSArray arrayWithObject:CHGrowlScreenshotSavedNotification];
  return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], GROWL_TICKET_VERSION, notifications, GROWL_NOTIFICATIONS_ALL, notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}


@end
