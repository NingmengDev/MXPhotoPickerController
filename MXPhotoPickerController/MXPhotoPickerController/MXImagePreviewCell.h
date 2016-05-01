//
//  MXImagePreviewCell.h
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/10.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXImageZoomView;
@class MXImagePreviewCell;

#pragma mark - MXImageZoomView

@protocol MXImageZoomViewDelegate <NSObject>

@optional
- (void)didSingleTapAtImageZoomView:(MXImageZoomView *)imageZoomView;

@end

@interface MXImageZoomView : UIView

@property (assign, nonatomic) id <MXImageZoomViewDelegate> delegate;

/**
 *  最小放大倍数（默认1.0）
 */
@property (assign, nonatomic) CGFloat minimumZoomScale;

/**
 *  最大放大倍数（默认2.0）
 */
@property (assign, nonatomic) CGFloat maximumZoomScale;

/**
 *  显示的图片控件
 */
@property (retain, readonly, nonatomic) UIImageView *imageView;

/**
 *  重用之前还原下默认
 */
- (void)reset;

@end

#pragma mark - MXImagePreviewCell

@protocol MXImagePreviewCellDelegate <NSObject>

@optional
- (void)didSingleTapAtImagePreviewCell:(MXImagePreviewCell *)cell;

@end

@interface MXImagePreviewCell : UICollectionViewCell <MXImageZoomViewDelegate>

@property (retain, nonatomic) MXImageZoomView *imageZoomView;

@property (assign, nonatomic) id <MXImagePreviewCellDelegate> delegate;

@property (assign, nonatomic) NSInteger indexPathItem;

@end
