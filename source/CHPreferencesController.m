//
//  CHPreferencesController.m
//  Crosshairs
//
//  Created by Zach Waugh on 10/5/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import "CHPreferencesController.h"
#import "CHPreferences.h"
#import "CHGlobals.h"
#import "MPLoginItems.h"
#import "DDHotKeyCenter.h"

@implementation CHPreferencesController

@synthesize primaryColorWell, alternateColorWell, shortcutRecorder;

- (void)awakeFromNib
{
  [self.shortcutRecorder setKeyCombo:SRMakeKeyCombo([CHPreferences globalHotKeyCode], [CHPreferences globalHotKeyFlags])];
}


- (void)dealloc
{
  self.alternateColorWell = nil;
  self.primaryColorWell = nil;
  self.shortcutRecorder = nil;
  
  [super dealloc];
}


- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
  KeyCombo keyCombo = [aRecorder keyCombo];
  [CHPreferences setGlobalHotKeyCode:keyCombo.code];
  [CHPreferences setGlobalHotKeyFlags:keyCombo.flags];
  
  DDHotKeyCenter *hotKeyCenter = [[[DDHotKeyCenter alloc] init] autorelease];
  
  [hotKeyCenter unregisterHotKeysWithTarget:[NSApp delegate]];
  [hotKeyCenter registerHotKeyWithKeyCode:keyCombo.code modifierFlags:keyCombo.flags target:[NSApp delegate] action:@selector(hotkeyWithEvent:) object:nil];
}


- (void)colorUpdated:(id)sender
{  
  if (sender == primaryColorWell)
  {
    [[NSNotificationCenter defaultCenter] postNotificationName:CHColorsDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:[primaryColorWell color] forKey:CHPrimaryOverlayColorKey]];
  }
  else if (sender == alternateColorWell)
  {
    [[NSNotificationCenter defaultCenter] postNotificationName:CHColorsDidChangeNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[alternateColorWell color] forKey:CHAlternateOverlayColorKey]];
  }
}


- (void)toggleStartAtLogin:(id)sender
{
  NSURL *appPath = [[NSBundle mainBundle] bundleURL];
  BOOL startAtLogin = [sender state];
  BOOL loginItemEnabled = [MPLoginItems loginItemExists:appPath];
  
  if (startAtLogin && !loginItemEnabled)
  {
    [MPLoginItems addLoginItemWithURL:appPath];
  }
  
  if (!startAtLogin && loginItemEnabled)
  {
    [MPLoginItems removeLoginItemWithURL:appPath];
  }
}


@end
