//
//  MXImageEditController.h
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/24.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  修正图片显示方向
 */
@interface UIImage (MXImageEditController)

- (UIImage *)mx_fixOrientation;

@end


/**
 *  编辑图片完成后的回调
 *
 *  @param image       选择区域中的图片
 *  @param originImage 图片原图
 *  @param cutRect     选中的区域
 */
typedef void (^MXImageEditDoneBlock)(UIImage *image, UIImage *originImage, CGRect cutRect);

@interface MXImageEditController : UIViewController

/**
 *  将原图传进来进行编辑
 *
 *  @param image     原图
 *  @param doneBlock 完成回调
 *
 *  @return 实例
 */
- (id)initWithImage:(UIImage *)image doneBlock:(MXImageEditDoneBlock)doneBlock;

@end
