//
//  MXPhotoPickerController.h
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/8.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXPhotoPickerController;

@protocol MXPhotoPickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(MXPhotoPickerController *)picker didFinishPickingWithAssets:(NSArray *)assets;

@end

@interface MXPhotoPickerController : UINavigationController

@property (assign, nonatomic) id <MXPhotoPickerControllerDelegate> finishedDelegate;

/**
 *  可以选择照片的最多数量（默认是0张）
 */
@property (assign, nonatomic) NSInteger maximumNumberOfSelectionalPhotos;

@end
