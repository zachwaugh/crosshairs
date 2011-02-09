//
//  CHHelpController.m
//  Crosshairs
//
//  Created by Zach Waugh on 2/5/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import "CHHelpController.h"


@implementation CHHelpController

@synthesize webView;

- (void)awakeFromNib
{
  NSString *helpFilePath = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
  NSURL *helpFileURL = [NSURL fileURLWithPath:helpFilePath];
  
  [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:helpFileURL]];
}

#pragma mark -
#pragma mark NSWindowDelegate

- (void)windowWillClose:(id)sender
{
  [NSApp hide:sender];
}

@end
