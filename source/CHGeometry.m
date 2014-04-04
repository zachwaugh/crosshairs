//
//  CHGeometry.m
//  Crosshairs
//
//  Created by Zach Waugh on 4/4/14.
//
//

#import "CHGeometry.h"

NSRect CHRectFromTwoPoints(NSPoint a, NSPoint b) {
	NSRect r;
	
	r.origin.x = MIN(a.x, b.x);
	r.origin.y = MIN(a.y, b.y);
	
	r.size.width = ABS(a.x - b.x);
	r.size.height = ABS(a.y - b.y);
	
	return r;
}

NSRect CHRectSquareFromTwoPoints(NSPoint a, NSPoint b) {
	NSRect r;
	
	r.origin.x = MIN(a.x, b.x);
	r.origin.y = MIN(a.y, b.y);
	
	float width;
	float height;
	
	width = ABS(a.x - b.x);
	height = ABS(a.y - b.y);
	
	r.size.width = MIN(width, height);
	r.size.height = MIN(width, height);
	
	return r;
}

NSPoint CHIntegralPoint(NSPoint p) {
	p.x = round(p.x);
	p.y = round(p.y);
	
	return p;
}