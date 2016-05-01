//
//  MXImagePreviewController.h
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/10.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXImagePreviewController;

@protocol MXImagePreviewControllerDelegate <NSObject>

@optional
- (void)didChangeItemSelectionalState:(MXImagePreviewController *)imagePreviewController;

@end

@interface MXImagePreviewController : UIViewController

@property (assign, nonatomic) id <MXImagePreviewControllerDelegate> delegate;

- (id)initWithStartingItem:(NSInteger)item;

- (id)initWithSelectionalItemsOnly;

@end
