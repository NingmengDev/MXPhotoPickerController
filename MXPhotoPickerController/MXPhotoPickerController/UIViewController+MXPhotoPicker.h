//
//  UIViewController+MXPhotoPicker.h
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/8.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UIViewController (MXPhotoPicker)

/**
 *  选择图片后的回调（单选）
 *
 *  @param image       选择区域中的图片
 *  @param originImage 图片原图
 *  @param cutRect     选中的区域
 */
typedef void (^MXPhotoPickerSingleBlock)(UIImage *image, UIImage *originImage, CGRect cutRect);

/**
 *  选择图片后的回调（多选）
 *
 *  @param assets 选择的图片数组（数组中是ALAsset对象）
 */
typedef void (^MXPhotoPickerMultipleBlock)(NSArray *assets);

/**
 *  照相 + 相册（均单选）
 *
 *  @param title      选择器标题
 *  @param needToEdit 选择图片后是否需要编辑
 *  @param completion 回调
 */
- (void)showMXPhotoPickerWithTitle:(NSString *)title
                        needToEdit:(BOOL)needToEdit
                        completion:(MXPhotoPickerSingleBlock)completion;

/**
 *  照相（单选）
 *
 *  @param needToEdit 选择图片后是否需要编辑
 *  @param completion 回调
 */
- (void)showMXPhotoCameraAndNeedToEdit:(BOOL)needToEdit
                            completion:(MXPhotoPickerSingleBlock)completion;

/**
 *  相册（单选）
 *
 *  @param needToEdit 选择图片后是否需要编辑
 *  @param completion 回调
 */
- (void)showMXPhotoPickerControllerAndNeedToEdit:(BOOL)needToEdit
                                      completion:(MXPhotoPickerSingleBlock)completion;

/**
 *  相册（多选）
 *
 *  @param maximumNumberOfSelectionalPhotos 最多允许选择的图片张数
 *  @param completion                       回调
 */
- (void)showMXPickerWithMaximumPhotosAllow:(NSInteger)maximumNumberOfSelectionalPhotos
                                completion:(MXPhotoPickerMultipleBlock)completion;

@end
