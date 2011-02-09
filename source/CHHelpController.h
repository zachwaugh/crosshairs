//
//  CHHelpController.h
//  Crosshairs
//
//  Created by Zach Waugh on 2/5/11.
//  Copyright 2011 Giant Comet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface CHHelpController : NSWindowController
{
  IBOutlet WebView *webView;
}

@property (assign) WebView *webView;

@end
