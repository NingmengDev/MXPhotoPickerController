//
//  MXImageEditController.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/24.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import "MXImageEditController.h"

#pragma mark - UIImage + fixOrientation

@implementation UIImage (MXImageEditController)

- (UIImage *)mx_fixOrientation
{
    UIImage *aImage = self;
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end


#pragma mark - MXImageEditController

#define ISIOS7_MXPPC ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define EDIT_SIZE [UIScreen mainScreen].bounds.size.width

#define TMPX 0.5

@interface MXImageEditController () <UIScrollViewDelegate>

@property (retain, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) MXImageEditDoneBlock doneBlock;

@end

@implementation MXImageEditController

/**
 *  将原图传进来进行编辑
 *
 *  @param image     原图
 *  @param doneBlock 完成回调
 *
 *  @return 实例
 */
- (id)initWithImage:(UIImage *)image doneBlock:(MXImageEditDoneBlock)doneBlock
{
    self = [super init];
    if (self) {
        self.doneBlock = doneBlock;
        self.image = [image mx_fixOrientation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    if (ISIOS7_MXPPC) [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    CGSize imageSize = self.image.size;
    CGFloat imageViewWidth, imageViewHeight;
    CGFloat scale = imageSize.height / imageSize.width;
    if (scale > 1.0) {
        imageViewWidth = EDIT_SIZE;
        imageViewHeight = imageViewWidth * scale;
    }
    else {
        imageViewHeight = EDIT_SIZE;
        imageViewWidth = imageViewHeight / scale;
    }
    
    CGRect imageViewRect = (CGRect){CGPointZero, imageViewWidth, imageViewHeight};
    self.imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
    self.imageView.image = self.image;
    
    CGRect frame = self.view.bounds;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    [scrollView setDelegate:self];
    [scrollView setMinimumZoomScale:1.0];
    [scrollView setMaximumZoomScale:5.0];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setContentSize:CGSizeMake(imageViewWidth + TMPX, imageViewHeight + TMPX)];
    
    CGFloat hInset = ABS(CGRectGetHeight(scrollView.bounds) - EDIT_SIZE) / 2;
    CGFloat wInset = ABS(CGRectGetWidth(scrollView.bounds) - EDIT_SIZE) / 2;
    [scrollView setContentInset:UIEdgeInsetsMake(hInset, wInset, hInset, wInset)];
    
    CGFloat vOffset = (imageViewHeight - CGRectGetHeight(scrollView.bounds)) / 2;
    CGFloat hOffset = (imageViewWidth - CGRectGetWidth(scrollView.bounds)) / 2;
    [scrollView setContentOffset:CGPointMake(hOffset, vOffset)];
    
    [scrollView addSubview:self.imageView];
    [self.view addSubview:scrollView];
    
    frame.size.height = (frame.size.height - EDIT_SIZE) / 2;
    UIView *topView = [[UIView alloc] initWithFrame:frame];
    [topView setUserInteractionEnabled:NO];
    [topView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view addSubview:topView];
    
    frame.origin.y += frame.size.height;
    frame.size.height = EDIT_SIZE;
    UIView *borderView = [[UIView alloc] initWithFrame:frame];
    [borderView setUserInteractionEnabled:NO];
    borderView.layer.borderWidth = 1.0;
    borderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:borderView.bounds];
    borderView.layer.shadowPath = path.CGPath;
    [self.view addSubview:borderView];
    
    frame.origin.y += frame.size.height;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    UIView *bottomView = [[UIView alloc] initWithFrame:frame];
    [bottomView setUserInteractionEnabled:NO];
    [bottomView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view addSubview:bottomView];
    
    CGRect bottomBarRect = self.view.bounds;
    bottomBarRect.size.height = 60.0;
    bottomBarRect.origin.y = CGRectGetHeight(self.view.bounds) - bottomBarRect.size.height;
    UIView *bottomBar = [[UIView alloc] initWithFrame:bottomBarRect];
    [bottomBar setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [self.view addSubview:bottomBar];
    
    CGRect buttonRect = bottomBar.bounds;
    buttonRect.size.width = buttonRect.size.height;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:buttonRect];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:backButton];
    
    buttonRect.origin.x = CGRectGetWidth(bottomBar.bounds) - buttonRect.size.width;
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:buttonRect];
    [doneButton setTitle:@"选取" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:doneButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Button Event

- (void)backButtonEvent:(UIButton *)button
{
    UIImagePickerControllerSourceType sourceType = [[self.navigationController valueForKey:@"sourceType"] integerValue];
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonEvent:(UIButton *)button
{
    CGSize imgViewSize = self.imageView.frame.size;
    CGSize imgSize = self.image.size;
    CGFloat scale = imgSize.width / imgViewSize.width;
    
    CGFloat w = EDIT_SIZE * scale;
    CGFloat h = EDIT_SIZE * scale;
    
    UIScrollView *scrollView = (UIScrollView *)self.imageView.superview;
    CGPoint offset = scrollView.contentOffset;
    CGFloat x = offset.x * scale;
    CGFloat y = (offset.y + scrollView.contentInset.top) * scale;
    
    CGRect cutRect = CGRectMake(x, y, w, h);
    CGImageRef originImageRef = self.image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(originImageRef, cutRect);
    UIImage *subImage = [UIImage imageWithCGImage:subImageRef];
    CFRelease(subImageRef);
    
    if (self.doneBlock) self.doneBlock(subImage, self.image, cutRect);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGSize contentSize = scrollView.contentSize;
    if (contentSize.width == EDIT_SIZE) {
        contentSize.width += TMPX;
        [scrollView setContentSize:contentSize];
    }
    
    if (contentSize.height == EDIT_SIZE) {
        contentSize.height += TMPX;
        [scrollView setContentSize:contentSize];
    }
    
    CGFloat hInset = ABS(CGRectGetHeight(scrollView.bounds) - EDIT_SIZE) / 2;
    CGFloat wInset = ABS(CGRectGetWidth(scrollView.bounds) - EDIT_SIZE) / 2;
    [scrollView setContentInset:UIEdgeInsetsMake(hInset, wInset, hInset, wInset)];
}

@end
