/*
 Copyright (c) 2017 Coloridad Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


#import <UIKit/UIKit.h>
#import "CLRDSticker.h"

@class CLRDStickerView;

@protocol CLRDStickerViewDelegate <NSObject>

@optional
- (void)stickerView:(CLRDStickerView *)stickerView changeBeganForSticker:(CLRDSticker *)sticker;
- (void)stickerView:(CLRDStickerView *)stickerView changeEndedForSticker:(CLRDSticker *)sticker;
- (void)stickerView:(CLRDStickerView *)stickerView eligibilityBeganFor:(NSString *)event forSticker:(CLRDSticker *)sticker;
- (void)stickerView:(CLRDStickerView *)stickerView eligibilityEndedFor:(NSString *)event forSticker:(CLRDSticker *)sticker;

@end

@interface CLRDStickerView : UIView
@property id <CLRDStickerViewDelegate> delegate;

- (void)addSticker:(CLRDSticker *)sticker;
- (void)addSticker:(CLRDSticker *)sticker withFrame:(CGRect)frame;
- (void)removeSticker:(CLRDSticker *)sticker;

- (void)setFrame:(CGRect)frame forEvent:(NSString *)event;
- (BOOL)frameIntersects:(CGRect)frame withFrameForEvent:(NSString *)event;
- (void)removeFrameForEvent:(NSString *)event;
@end
