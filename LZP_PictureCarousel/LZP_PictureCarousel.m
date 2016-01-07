//
//  LZP_PictureCarousel.m
//  LZP_PictureCarousel
//
//  Created by zkey on 1/7/16.
//  Copyright © 2016 overcode. All rights reserved.
//

#import "LZP_PictureCarousel.h"

#define PAGE_CONTROL_BOTTOM_SPACE 15.0f
#define PAGE_MOVING_TIME_INTERVAL 3.0

@interface LZP_PictureCarousel () <UIScrollViewDelegate>

@property (nonatomic, strong, nonnull) NSArray<UIImage *> *images;

@property (nonatomic, strong, nonnull) UIScrollView *imageScrollView;
@property (nonatomic, strong, nonnull) NSArray *imageViewArray;
@property (nonatomic, strong, nonnull) UIPageControl *pageControl;

@property (nonatomic, strong, nullable) NSTimer *timer; // null when timer is invalidate

@end





@implementation LZP_PictureCarousel

#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame andImages:(nonnull NSArray<UIImage *> *)images
{
    // security checking...
    if (images == nil || images.count <= 0) {
        return nil;
    }
    
    for (id obj in images) {
        if (![obj isMemberOfClass:[UIImage class]]) {
            return nil;
        }
    }
    
    // custom initializer
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.images = images;
        
        [self customInitialization];
        
    }
    
    return self;
}

- (void)customInitialization
{
    [self addSubview:self.imageScrollView];
    [self.imageScrollView setContentOffset:CGPointMake(self.imageScrollView.frame.size.width, 0)];
    
    [self addImageViewToScrollView];
    [self addPageControl];
}

- (void)addPageControl
{
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
    self.pageControl.frame = CGRectMake((self.imageScrollView.frame.size.width - pageControlSize.width) / 2.0f, self.imageScrollView.frame.size.height - PAGE_CONTROL_BOTTOM_SPACE - pageControlSize.height, pageControlSize.width, pageControlSize.height);
    [self addSubview:self.pageControl];
}

- (void)addImageViewToScrollView
{
    self.imageScrollView.contentSize = CGSizeMake(self.frame.size.width * self.imageViewArray.count, self.frame.size.height);
    
    CGFloat imageViewWidth = self.imageScrollView.frame.size.width;
    CGFloat imageViewHeight = self.imageScrollView.frame.size.height;
    
    for (NSUInteger index = 0; index < self.imageViewArray.count; ++index) {
        
        UIImageView *imageView = [self.imageViewArray objectAtIndex:index];
        imageView.frame = CGRectMake(index * imageViewWidth, 0.0f, imageViewWidth, imageViewHeight);
        [self.imageScrollView addSubview:imageView];
        
    }
}

#pragma mark - auto playing
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self startPlaying];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    [self stopPlaying];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (hidden) {
        [self stopPlaying];
    } else {
        [self startPlaying];
    }
}

- (void)startPlaying
{
    [self.timer fire];
}

- (void)stopPlaying
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)moveToNextPage
{
    CGFloat contentOffsetX = self.imageScrollView.contentOffset.x + self.imageScrollView.frame.size.width;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.imageScrollView setContentOffset:CGPointMake(contentOffsetX, 0)];
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf adjustPageIndicatorAndContentOffset];
        }
    }];
}

- (void)adjustPageIndicatorAndContentOffset
{
    NSInteger currentPage = floorf(self.imageScrollView.contentOffset.x / self.imageScrollView.frame.size.width + 0.5);
    
    if (currentPage == 0) {
        // the last page
        [self.imageScrollView setContentOffset:CGPointMake(self.imageScrollView.frame.size.width * self.images.count, 0)];
        self.pageControl.currentPage = self.images.count;
    } else if (currentPage == self.images.count + 1) {
        // the first page
        [self.imageScrollView setContentOffset:CGPointMake(self.imageScrollView.frame.size.width, 0)];
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = currentPage - 1;
    }
}

#pragma mark - dragging the scroll view
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopPlaying];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger currentPage = floorf(self.imageScrollView.contentOffset.x / self.imageScrollView.frame.size.width + 0.5);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf.imageScrollView setContentOffset:CGPointMake(self.imageScrollView.frame.size.width * currentPage, 0)];
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf adjustPageIndicatorAndContentOffset];
        }
        
        [weakSelf performSelector:@selector(startPlaying) withObject:nil afterDelay:PAGE_MOVING_TIME_INTERVAL];
    }];
}

#pragma mark - custom getter
- (NSArray *)imageViewArray
{
    if (!_imageViewArray) {
        NSMutableArray *imageViewMutableArray = [NSMutableArray arrayWithCapacity:self.images.count];
        
        for (NSUInteger index = 0; index < self.images.count; ++index) {
            
            // for that we have checked the type of object(must be UIImage) in array 'images'
            // so we can directly use method 'objectAtIndex:' without cheching type
            UIImageView *imageView = [self newImageViewWithImage:[self.images objectAtIndex:index]];
            [imageViewMutableArray addObject:imageView];
            
        }
        
        // the extra imageView is used to support the function - playing picture by loop with sight animation.
        if (self.images.count > 1) {
            UIImageView *imageViewLast = [self newImageViewWithImage:[self.images lastObject]];
            [imageViewMutableArray insertObject:imageViewLast atIndex:0];
            
            UIImageView *imageViewFirst = [self newImageViewWithImage:[self.images firstObject]];
            [imageViewMutableArray addObject:imageViewFirst];
        }
        
        _imageViewArray = (NSArray *)imageViewMutableArray;
    }
    
    return _imageViewArray;
}

- (UIImageView *)newImageViewWithImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    imageView.backgroundColor = [UIColor blackColor];
    
    return imageView;
}

- (UIScrollView *)imageScrollView
{
    if (!_imageScrollView) {
        _imageScrollView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            
            scrollView.backgroundColor = [UIColor lightGrayColor];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.bounces = NO;
            scrollView.pagingEnabled = YES;
            scrollView.delegate = self;
            
            scrollView;
        });
    }
    
    return _imageScrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = ({
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            
            pageControl.numberOfPages = self.images.count;
            pageControl.hidesForSinglePage = YES;
            pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.7 alpha:0.2];
            pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
            
            pageControl;
        });
    }
    
    return _pageControl;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:PAGE_MOVING_TIME_INTERVAL target:self selector:@selector(moveToNextPage) userInfo:nil repeats:YES];
    }
    
    return _timer;
}

- (void)dealloc
{
    if (!_timer) {
        [_timer invalidate];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
