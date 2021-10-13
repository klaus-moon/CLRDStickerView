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

#import "CLRDStickerView.h"

@interface CLRDStickerView () <UIGestureRecognizerDelegate>
@property NSMutableSet<UIGestureRecognizer *> *activeGestureRecognizers;
@property NSMutableDictionary<NSString *, NSValue *> *eventDictionary;
@end

@implementation CLRDStickerView

- (id)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    _activeGestureRecognizers = [NSMutableSet set];
    _eventDictionary = [NSMutableDictionary dictionary];
}

- (void)addSticker:(CLRDSticker *)sticker {
    
    CGRect adjustedCenter = CGRectMake(self.center.x - (sticker.frame.size.width / 2),
                                       self.center.y - (sticker.frame.size.height / 2),
                                       sticker.frame.size.width,
                                       sticker.frame.size.height);
    
    [self addSticker:sticker withFrame:adjustedCenter];
    
}

- (void)addSticker:(CLRDSticker *)sticker withFrame:(CGRect)frame {

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [panRecognizer setDelegate:self];
    [sticker addGestureRecognizer:panRecognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [rotationRecognizer setDelegate:self];
    [sticker addGestureRecognizer:rotationRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [pinchRecognizer setDelegate:self];
    [sticker addGestureRecognizer:pinchRecognizer];
    
    sticker.userInteractionEnabled = YES;
    [self addSubview:sticker];

}

- (void)removeSticker:(CLRDSticker *)sticker {
    if ([sticker.superview isEqual:self]) {
        
        for (UIGestureRecognizer *recognizer in sticker.gestureRecognizers) {
            [recognizer setDelegate:nil];
            [sticker removeGestureRecognizer:recognizer];
        }
        
        sticker.userInteractionEnabled = NO;
        
        [sticker removeFromSuperview];
    }
}

- (void)handleGesture:(UIGestureRecognizer *)recognizer {

    CLRDSticker *targetSticker = (CLRDSticker *)(recognizer.view);
    
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if (_activeGestureRecognizers.count == 0) {
                targetSticker.referenceTransform = targetSticker.transform;
            }
            
            [_activeGestureRecognizers addObject:recognizer];
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(stickerView:changeBeganForSticker:)] == YES) {
                [self.delegate stickerView:self changeBeganForSticker:targetSticker];
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            targetSticker.referenceTransform = [self applyRecognizer:recognizer toTransform:targetSticker.referenceTransform];
            [_activeGestureRecognizers removeObject:recognizer];
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(stickerView:changeEndedForSticker:)] == YES) {
                [self.delegate stickerView:self changeEndedForSticker:targetSticker];
            }

            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGAffineTransform transform = targetSticker.referenceTransform;
            
            for (UIGestureRecognizer *recognizer in _activeGestureRecognizers) {
                transform = [self applyRecognizer:recognizer toTransform:transform];
            }
            
            targetSticker.transform = transform;
            break;
        }
            
        default:
            break;
    }
    
    for (NSString *event in _eventDictionary.allKeys) {
        CGRect frame = [_eventDictionary objectForKey:event].CGRectValue;
        
        BOOL eventDetected = CGRectIntersectsRect(frame, targetSticker.frame);
        
        if (eventDetected == YES && [targetSticker.associatedEvents containsObject:event] == NO) {
            
            [targetSticker.associatedEvents addObject:event];
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(stickerView:eligibilityBeganFor:forSticker:)]) {
                [self.delegate stickerView:self eligibilityBeganFor:event forSticker:targetSticker];
            }
        }
        
        else if (eventDetected == NO && [targetSticker.associatedEvents containsObject:event] == YES) {
            [targetSticker.associatedEvents removeObject:event];
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(stickerView:eligibilityEndedFor:forSticker:)]) {
                [self.delegate stickerView:self eligibilityEndedFor:event forSticker:targetSticker];
            }
        }
    }
}

- (CGAffineTransform)applyRecognizer:(UIGestureRecognizer *)recognizer toTransform:(CGAffineTransform)transform {
    if ([recognizer respondsToSelector:@selector(translationInView:)]) {
        CGPoint translation = [(UIPanGestureRecognizer *)recognizer translationInView:self];
        return CGAffineTransformTranslate(transform, translation.x, translation.y);
    }
    
    else if ([recognizer respondsToSelector:@selector(rotation)]) {
        return CGAffineTransformRotate(transform, [(UIRotationGestureRecognizer *)recognizer rotation]);
    }
    
    else if ([recognizer respondsToSelector:@selector(scale)]) {
        CGFloat scale = [(UIPinchGestureRecognizer *)recognizer scale];
        return CGAffineTransformScale(transform, scale, scale);
    }
    
    else {
        return transform;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setFrame:(CGRect)frame forEvent:(NSString *)event {
    [_eventDictionary setObject:[NSValue valueWithCGRect:frame] forKey:event];
}

- (BOOL)frameIntersects:(CGRect)frame withFrameForEvent:(NSString *)event {
    CGRect eventFrame = [_eventDictionary objectForKey:event].CGRectValue;
    return CGRectIntersectsRect(frame, eventFrame);
}

- (void)removeFrameForEvent:(NSString *)event {
    [_eventDictionary removeObjectForKey:event];
}

@end
