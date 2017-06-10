//
//  ANView.m
//  CoreText
//
//  Created by Qianrun on 16/12/22.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import "CTView.h"
#import <CoreText/CoreText.h>
#import "ANMarkupParser.h"

@implementation CTView

@synthesize attString;
@synthesize frames;


/*
- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    // 0 翻转坐标，默认是笛卡尔坐标系
    CGContextSetTextMatrix(ref, CGAffineTransformIdentity);
    CGContextTranslateCTM(ref, 0, self.bounds.size.height);
    CGContextScaleCTM(ref, 1.0, -1.0);
    
    // 1
    CGPathAddRect(path, NULL, self.bounds);
    
    // 2
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attString);
    
    // 3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attString.length), path, NULL);
    
    // 4
    CTFrameDraw(frame, ref);
    
    // 5
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(frame);
    
}
*/

- (void)buildFrames
{
    // 1
    frameXOffset = 20; //1
    frameYOffset = 20;
    self.pagingEnabled = YES;
    self.delegate = self;
    self.frames = [NSMutableArray array];
    
    // 2
    CGMutablePathRef path = CGPathCreateMutable(); //2
    CGRect textFrame = CGRectInset(self.bounds, frameXOffset, frameYOffset);
    CGPathAddRect(path, NULL, textFrame );
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    // 3
    int textPos = 0; //3
    int columnIndex = 0;
    
    // 4
    while (textPos < [attString length]) { //4
        
        CGPoint colOffset = CGPointMake((columnIndex+1)*frameXOffset + columnIndex*(textFrame.size.width/2), 20);
        CGRect colRect = CGRectMake(0, 0 , textFrame.size.width/2-10, textFrame.size.height-40);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, colRect);
        
        //use the column path
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        
        // 5
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
        
        //create an empty column view
        CTColumnView* content = [[CTColumnView alloc]init]; // initWithFrame: CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
        content.backgroundColor = [UIColor whiteColor];
        content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height) ;
        
        
        // 6
        //set the column view contents and add it as subview
        [content setCTFrame:(__bridge id)frame];  //6
        [self.frames addObject: (__bridge id)frame];
        [self addSubview:content];
        
        //prepare for next frame
        textPos += frameRange.length;
        
        //CFRelease(frame);
        CFRelease(path);
        
        columnIndex++;
    }
    
    // 7
    //set the total width of the scroll view
    int totalPages = (columnIndex+1) / 2; //7
    self.contentSize = CGSizeMake(totalPages*self.bounds.size.width, textFrame.size.height);
}


- (void)dealloc {
    
    self.frames = nil;
    
}
@end
