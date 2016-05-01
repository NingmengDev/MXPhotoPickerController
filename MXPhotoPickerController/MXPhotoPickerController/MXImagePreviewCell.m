//
//  MXImagePreviewCell.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/10.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import "MXImagePreviewCell.h"

@interface MXImageZoomView () <UIScrollViewDelegate>

@property (retain, nonatomic) UIScrollView *scrollView;

@property (retain, nonatomic) UIImageView *imageView;

@end

@implementation MXImageZoomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:_imageView];
        
        /**
         *  _imageView添加单击手势（用于显示和隐藏导航栏和底部栏）
         */
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
        [_imageView addGestureRecognizer:singleTapGesture];
        
        /**
         *  _imageView添加双击手势（用于双击放大和缩小）
         */
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [_imageView addGestureRecognizer:doubleTapGesture];
        
        /**
         *  双击失效了再执行单击
         */
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        /**
         *  设置图片放大缩小系数、默认图片
         */
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 2.0;
        [self reset];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_scrollView setFrame:self.bounds];
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale
{
    _minimumZoomScale = minimumZoomScale;
    self.scrollView.minimumZoomScale = minimumZoomScale;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
    _maximumZoomScale = maximumZoomScale;
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

/**
 *  重用之前还原下默认
 */
- (void)reset
{
    self.scrollView.zoomScale = self.minimumZoomScale;
    self.scrollView.contentOffset = CGPointZero;
    self.imageView.image = nil;
}

#pragma mark - UITapGestureRecognizer

#pragma mark - UITapGestureRecognizer

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSingleTapAtImageZoomView:)]) {
        [self.delegate didSingleTapAtImageZoomView:self];
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.scrollView.minimumZoomScale <= self.scrollView.zoomScale && self.scrollView.maximumZoomScale > self.scrollView.zoomScale) {
        [self.scrollView setZoomScale:self.maximumZoomScale animated:YES];
    }
    else {
        [self.scrollView setZoomScale:self.minimumZoomScale animated:YES];
    }
}

#pragma mark- UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end


@implementation MXImagePreviewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        self.imageZoomView = [[MXImageZoomView alloc] init];
        self.imageZoomView.delegate = self;
        [self.contentView addSubview:self.imageZoomView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    /**
     *  重用的时候重置一下
     */
    [self.imageZoomView reset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.contentView.bounds;
    [self.imageZoomView setFrame:rect];
}

- (void)setIndexPathItem:(NSInteger)indexPathItem
{
    _indexPathItem = indexPathItem;
}

#pragma mark - MXImageZoomViewDelegate

- (void)didSingleTapAtImageZoomView:(MXImageZoomView *)imageZoomView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSingleTapAtImagePreviewCell:)]) {
        [self.delegate didSingleTapAtImagePreviewCell:self];
    }
}

@end
