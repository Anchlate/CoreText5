//
//  ANView.h
//  CoreText
//
//  Created by Qianrun on 16/12/22.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTColumnView.h"

@interface CTView : UIScrollView<UIScrollViewDelegate> {
    float frameXOffset;
    float frameYOffset;
}
@property (nonatomic, copy) NSAttributedString *attString;

//CTView.h - as an ivar
//NSMutableArray* frames;

//CTView.h - declare property
@property (retain, nonatomic) NSMutableArray* frames;

//CTView.h - in method declarations
- (void)buildFrames;


@end
