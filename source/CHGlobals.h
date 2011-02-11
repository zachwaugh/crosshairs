//
//  DMGlobals.h
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 Giant Comet. All rights reserved.
//


// User defaults keys
extern NSString * const CHClipboardFormatKey;
extern NSString * const CHPrimaryOverlayColorKey;
extern NSString * const CHAlternateOverlayColorKey;
extern NSString * const CHLastOverlayColorKey;
extern NSString * const CHSwitchedOverlayColorsKey;
extern NSString * const CHShowDimensionsOutsideKey;
extern NSString * const CHInvertedOverlayModeKey;
extern NSString * const CHStartAtLoginKey;
extern NSString * const CHGlobalHotKeyCode;
extern NSString * const CHGlobalHotKeyFlags;
extern NSString * const CHShowInDockKey;
extern NSString * const CHActivateAppKey;
extern NSString * const CHNumberOfLaunchesKey;
extern NSString * const CHFirstLaunchDateKey;
extern NSString * const CHTrialHashKey;
extern NSString * const CHRightMouseEscapeKey;

// Notifications
extern NSString * const CHColorsDidChangeNotification;

// Growl
extern NSString * const CHGrowlScreenshotSavedNotification;


typedef enum {
  CHStatusItemInactive,
  CHStatusItemHighlighted,
  CHStatusItemActive
} CHStatusItemState;