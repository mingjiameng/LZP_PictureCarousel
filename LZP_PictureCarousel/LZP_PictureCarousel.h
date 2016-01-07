//
//  LZP_PictureCarousel.h
//  LZP_PictureCarousel
//
//  Created by zkey on 1/7/16.
//  Copyright © 2016 overcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZP_PictureCarousel : UIView

@property (nonatomic, strong, nonnull, readonly) NSArray<UIImage *> *images; // image array that you use to initialize this instance.

/*
 * you are supposed to use this initializer to get an instance.
 * if you try to get an instance by system initializer, you will fail.
 * param 'images' should contain only UIImage object, or you will receive a nil instance.
 * if array 'images' contain no object, you will receive a nil instance.
 */
- (nullable instancetype)initWithFrame:(CGRect)frame andImages:(nonnull NSArray<UIImage *> *)images;

@end
