
//
//  ANMarkupParser.m
//  CoreText
//
//  Created by Qianrun on 16/12/22.
//  Copyright © 2016年 qianrun. All rights reserved.
//

#import "ANMarkupParser.h"

@implementation ANMarkupParser

- (id)init {
    
    if (self = [super init]) {
        
//        self.font = @"Arial";
        self.font = [self postscriptNameFromFullName:@"Times-BoldItalic"];
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor whiteColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
        
    }
    return self;
}

- (NSAttributedString*)attrStringFromMark:(NSString*)mark {
    
    NSMutableAttributedString* aString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSError* error = nil;
    
    //(.*?).通配符 *？匹配上一个元素零次或多次，但次数尽可能少。
    //^匹配必须从字符串或一行的开头开始。
    //<>的位置
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators;
    NSRegularExpression* regex = [[NSRegularExpression alloc]initWithPattern:@"(.*?)(<[^>]+>|\\Z)"
                                                                     options:options
                                                                       error:&error];
    
    NSArray* chunks = [regex matchesInString:mark
                                     options:0
                                       range:NSMakeRange(0, mark.length)];
    
    // 1
    if (error) {
        
        NSLog(@"解析标签出现错误:%@\n%@",[error userInfo],error);
        //返回原来的字符串
        return [[NSAttributedString alloc] initWithString:mark];
    }
    
    for (NSTextCheckingResult* result in chunks) {
        
        //字符串切割
        NSArray* parts = [[mark substringWithRange:result.range] componentsSeparatedByString:@"<"];
        
        //1;
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.font, 12.0f, NULL);
        
        //apply the current text style
        //2
        NSDictionary* attrs = @{(id)kCTForegroundColorAttributeName: (id)self.color.CGColor,
                                (id)kCTFontAttributeName:(__bridge id)fontRef,
                                (id)kCTStrokeColorAttributeName:(__bridge id)self.strokeColor.CGColor,
                                (id)kCTStrokeWidthAttributeName:[NSNumber numberWithFloat:self.strokeWidth]};
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:parts[0] attributes:attrs]];
        
        CFRelease(fontRef);
        
        //是否带属性，处理新的样式 3
        if (parts.count>1) {
            
            NSString *tag = parts[1];
            
            if ([tag hasPrefix:@"font"]) {
            
                //stroke color
                NSRegularExpression* scReg = [[NSRegularExpression alloc]initWithPattern:@"(?<=strokeColor=\")\\w+"
                                                                                 options:0
                                                                                   error:nil];
                [scReg enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    
                    if ([[tag substringWithRange:result.range] isEqualToString:@"none"]) {
                         
                         self.strokeWidth = 0.0;
                         
                     } else {
                         
                         self.strokeWidth = -3.0;
                         SEL colorSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[tag substringWithRange:result.range]]);
                         self.strokeColor = [UIColor performSelector:colorSel];
                     }
                 }];
                
                //Color
                NSRegularExpression* colorReg = [[NSRegularExpression alloc] initWithPattern:@"(?<=color=\")\\w+" options:0 error:nil];

                [colorReg enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    
                    NSString *colorStrrr = [NSString stringWithFormat: @"%@Color", [tag substringWithRange:result.range]];
                    NSLog(@"tag:%@", tag);
                    NSLog(@"reange: %@", [tag substringWithRange:result.range]);
                    NSLog(@"colorStrrr: %@", colorStrrr);
                    
                    SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:result.range]]);
                    self.color = [UIColor performSelector:colorSel];
                    
                 }];
                
                //face
                NSRegularExpression* faceRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=face=\")[^\"]+" options:0 error:NULL];
                
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                     self.font = [tag substringWithRange:match.range];
                 }];
            }
        }
    }
    //end of font parsing 结束字体解析
    return aString;
    
}

- (NSString *)postscriptNameFromFullName:(NSString *)fullName
{
    UIFont *font = [UIFont fontWithName:fullName size:1];
    return (__bridge NSString *)(CTFontCopyPostScriptName((__bridge CTFontRef)(font)));
}

- (void)dealloc {
    
    self.font = nil;
    self.color = nil;
    self.strokeColor = nil;
    self.images = nil;
}

@end
