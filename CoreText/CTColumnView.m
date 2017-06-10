
//
//  CTColumnView.m
//  CoreText
//
//  Created by Qianrun on 16/12/22.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import "CTColumnView.h"
#import <CoreText/CoreText.h>

@implementation CTColumnView

-(void)setCTFrame: (id)f {
    ctFrame = f;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw((CTFrameRef)ctFrame, context);
}

@end
