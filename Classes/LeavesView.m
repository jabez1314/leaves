//
//  LeavesView.m
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//

#import "LeavesView.h"

@interface LeavesView () 

@property (assign) CGFloat leafEdge;
@property (assign) NSUInteger currentPageIndex;

@end


@implementation LeavesView

@synthesize dataSource, delegate;
@synthesize leafEdge, currentPageIndex;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		topPage = [[CALayer alloc] init];
		topPage.backgroundColor = [[UIColor whiteColor] CGColor];
		
		topPageImage = [[CALayer alloc] init];
		topPageImage.masksToBounds = YES;
		topPageImage.contentsGravity = kCAGravityLeft;
		
		topPageShadow = [[CAGradientLayer alloc] init];
		topPageShadow.colors = [NSArray arrayWithObjects:
										(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
										(id)[[UIColor clearColor] CGColor],
										nil];
		topPageShadow.startPoint = CGPointMake(1,0.5);
		topPageShadow.endPoint = CGPointMake(0,0.5);
		
		topPageReverse = [[CALayer alloc] init];
		topPageReverse.backgroundColor = [[UIColor whiteColor] CGColor];
		topPageReverse.masksToBounds = YES;
		
		topPageReverseImage = [[CALayer alloc] init];
		topPageReverseImage.masksToBounds = YES;
		topPageReverseImage.contentsGravity = kCAGravityRight;
		
		topPageReverseOverlay = [[CALayer alloc] init];
		topPageReverseOverlay.backgroundColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] CGColor];
		
		topPageReverseShading = [[CAGradientLayer alloc] init];
		topPageReverseShading.colors = [NSArray arrayWithObjects:
								(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
								(id)[[UIColor clearColor] CGColor],
								nil];
		topPageReverseShading.startPoint = CGPointMake(1,0.5);
		topPageReverseShading.endPoint = CGPointMake(0,0.5);
		
		bottomPage = [[CALayer alloc] init];
		bottomPage.backgroundColor = [[UIColor whiteColor] CGColor];
		bottomPage.masksToBounds = YES;
		
		bottomPageShadow = [[CAGradientLayer alloc] init];
		bottomPageShadow.colors = [NSArray arrayWithObjects:
										(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
										(id)[[UIColor clearColor] CGColor],
										nil];
		bottomPageShadow.startPoint = CGPointMake(0,0.5);
		bottomPageShadow.endPoint = CGPointMake(1,0.5);
		
		[topPage addSublayer:topPageImage];
		[topPage addSublayer:topPageShadow];
		[topPageReverse addSublayer:topPageReverseImage];
		[topPageReverse addSublayer:topPageReverseOverlay];
		[topPageReverse addSublayer:topPageReverseShading];
		[bottomPage addSublayer:bottomPageShadow];
		[self.layer addSublayer:bottomPage];
		[self.layer addSublayer:topPage];
		[self.layer addSublayer:topPageReverse];
		
		self.leafEdge = 1.0;
    }
    return self;
}

- (void)dealloc {
	[topPage release];
	[topPageImage release];
	[topPageShadow release];
	[topPageReverse release];
	[topPageReverseImage release];
	[topPageReverseOverlay release];
	[topPageReverseShading release];
	[bottomPage release];
	[bottomPageShadow release];
    [super dealloc];
}

- (CGImageRef) imageForPageIndex:(NSUInteger)pageIndex {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, 
												 self.bounds.size.width, 
												 self.bounds.size.height, 
												 8,									/* bits per component*/
												 (int)self.bounds.size.width * 4, 	/* bytes per row */
												 colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextClipToRect(context, self.bounds);
	
	[dataSource renderPageAtIndex:pageIndex inContext:context];
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	[UIImage imageWithCGImage:image];
	CGImageRelease(image);
	
	return image;
}

- (void) reloadData {
	numberOfPages = [dataSource numberOfPagesInLeavesView:self];
	self.currentPageIndex = 0;
}

- (void) setLayerFrames {
	topPage.frame = CGRectMake(self.layer.bounds.origin.x, 
							   self.layer.bounds.origin.y, 
							   leafEdge * self.bounds.size.width, 
							   self.layer.bounds.size.height);
	topPageReverse.frame = CGRectMake(self.layer.bounds.origin.x + (2*leafEdge-1) * self.bounds.size.width, 
									  self.layer.bounds.origin.y, 
									  (1-leafEdge) * self.bounds.size.width, 
									  self.layer.bounds.size.height);
	bottomPage.frame = self.layer.bounds;
	topPageImage.frame = topPage.bounds;
	topPageShadow.frame = CGRectMake(topPageReverse.frame.origin.x - 40, 
									 0, 
									 40, 
									 bottomPage.bounds.size.height);
	topPageReverseImage.frame = topPageReverse.bounds;
	topPageReverseImage.transform = CATransform3DMakeScale(-1, 1, 1);
	topPageReverseOverlay.frame = topPageReverse.bounds;
	topPageReverseShading.frame = CGRectMake(topPageReverse.bounds.size.width - 50, 
											 0, 
											 50 + 1, 
											 topPageReverse.bounds.size.height);
	bottomPageShadow.frame = CGRectMake(leafEdge * self.bounds.size.width, 
										0, 
										40, 
										bottomPage.bounds.size.height);
}

#pragma mark properties

- (void) setLeafEdge:(CGFloat)aLeafEdge {
	leafEdge = aLeafEdge;
	topPageShadow.opacity = MIN(1.0, 4*(1-leafEdge));
	bottomPageShadow.opacity = MIN(1.0, 4*leafEdge);
	[self setLayerFrames];
}

- (void) setCurrentPageIndex:(NSUInteger)aCurrentPageIndex {
	currentPageIndex = aCurrentPageIndex;
	if (currentPageIndex < numberOfPages) {
		topPageImage.contents = (id)[self imageForPageIndex:currentPageIndex];
		topPageReverseImage.contents = (id)[self imageForPageIndex:currentPageIndex];
		if (currentPageIndex < numberOfPages - 1)
			bottomPage.contents = (id)[self imageForPageIndex:currentPageIndex + 1];
	} else {
		topPageImage.contents = nil;
		topPageReverseImage.contents = nil;
		bottomPage.contents = nil;
	}
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	self.leafEdge = 1.0;
	[CATransaction commit];
}

#pragma mark UIView methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	[CATransaction begin];
//	[CATransaction setValue:(id)kCFBooleanTrue
//					 forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:0.07]
					 forKey:kCATransactionAnimationDuration];
	self.leafEdge = touchPoint.x / self.bounds.size.width;
	[CATransaction commit];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[CATransaction begin];
	if (self.leafEdge < 0.5) {
		self.leafEdge = 0;
		[CATransaction setValue:[NSNumber numberWithFloat:leafEdge]
						 forKey:kCATransactionAnimationDuration];
	}
	else {
		self.leafEdge = 1.0;
		[CATransaction setValue:[NSNumber numberWithFloat:1-leafEdge]
						 forKey:kCATransactionAnimationDuration];
	}
	[CATransaction commit];
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	[self setLayerFrames];
	[CATransaction commit];
}

@end