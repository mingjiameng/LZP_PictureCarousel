//
//  ViewController.m
//  LZP_PictureCarousel
//
//  Created by zkey on 1/7/16.
//  Copyright © 2016 overcode. All rights reserved.
//

#import "ViewController.h"

#import "LZP_PictureCarousel.h"

@interface ViewController ()

@property (nonatomic, strong, nonnull) NSArray *imageNameArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadImageView];
}

- (void)loadImageView
{
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:self.imageNameArray.count];
    
    for (NSUInteger index = 0; index < self.imageNameArray.count; ++index) {
        NSString *imageName = [self.imageNameArray objectAtIndex:index];
        NSString *pathOfImage = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
        if (pathOfImage != nil) {
            UIImage *image = [UIImage imageWithContentsOfFile:pathOfImage];
            if (image != nil) {
                [imageArray addObject:image];
            } else {
                NSLog(@"fail to load image");
            }
        } else {
            NSLog(@"fail to find image resource");
        }
    }
    
    LZP_PictureCarousel *pictureCarousel = [[LZP_PictureCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200.0f) andImages:imageArray];
    
    [self.view addSubview:pictureCarousel];
}

- (NSArray *)imageNameArray
{
    if (!_imageNameArray) {
        _imageNameArray = @[@"01", @"02", @"03", @"04", @"05"];
    }
    
    return _imageNameArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

