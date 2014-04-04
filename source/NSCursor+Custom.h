//
//  NSCursor+Custom.h
//  Dimensions
//
//  Created by Zach Waugh on 10/16/10.
//  Copyright 2010 zachwaugh.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSCursor (Custom)

+ (NSCursor *)crosshairsCursor;
+ (NSCursor *)resizeLeftDiagonalCursor;
+ (NSCursor *)resizeRightDiagonalCursor;

@end
